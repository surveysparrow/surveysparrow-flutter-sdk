import 'dart:async';
import 'dart:convert';
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../state/spotcheck_state.dart';
import '../state/function_state.dart';
import '../adapters/storage_adapter.dart';
import '../adapters/sentry_adapter.dart';
import '../adapters/keyboard_adapter.dart';
import '../adapters/listener_adapter.dart';

dynamic _deepCastMap(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), _deepCastMap(v)),
    );
  }
  if (value is List) {
    return value.map(_deepCastMap).toList();
  }
  return value;
}

class Executables {
  final SpotcheckStore spotcheckStore;
  final FunctionStore functionStore;
  final StorageAdapter storage;
  final SentryAdapter sentry;
  final KeyboardAdapter keyboard;
  final ListenerAdapter listener;

  void Function()? onAfterBatchDispatch;

  bool _widgetInitializationComplete = false;

  final List<({String functionName, Map<String, dynamic>? params})>
      _pendingExecutes = [];

  JavascriptRuntime? _jsRuntime;
  bool _runtimeReady = false;

  Future<void>? _jsExecutionChain;

  Executables({
    required this.spotcheckStore,
    required this.functionStore,
    required this.storage,
    required this.sentry,
    required this.keyboard,
    required this.listener,
  });

  static const String _fetchPolyfill = r'''
(function() {
  var _fetchId = 0;
  if (typeof globalThis._fetchCallbacks === 'undefined') {
    globalThis._fetchCallbacks = {};
  }
  globalThis.fetch = function(url, options) {
    return new Promise(function(resolve, reject) {
      var id = _fetchId++;
      globalThis._fetchCallbacks[id] = { resolve: resolve, reject: reject };
      try {
        sendMessage('fetch', JSON.stringify({
          id: id,
          url: String(url),
          method: (options && options.method) ? String(options.method) : 'GET',
          headers: (options && options.headers) ? options.headers : {},
          body: (options && options.body) ? String(options.body) : null,
        }));
      } catch(e) {
        delete globalThis._fetchCallbacks[id];
        reject(new Error('fetch bridge failed: ' + e));
      }
    });
  };
})();
''';

  static const String _urlSearchParamsPolyfill = '''
var URLSearchParams = function(init) {
  this._entries = [];
  if (typeof init === 'object' && init !== null) {
    var keys = Object.keys(init);
    for (var i = 0; i < keys.length; i++) {
      this._entries.push([keys[i], String(init[keys[i]])]);
    }
  } else if (typeof init === 'string') {
    var s = init.charAt(0) === '?' ? init.substring(1) : init;
    var pairs = s.split('&');
    for (var j = 0; j < pairs.length; j++) {
      var idx = pairs[j].indexOf('=');
      if (idx > -1) {
        this._entries.push([decodeURIComponent(pairs[j].substring(0, idx)), decodeURIComponent(pairs[j].substring(idx + 1))]);
      } else if (pairs[j]) {
        this._entries.push([decodeURIComponent(pairs[j]), '']);
      }
    }
  }
};
URLSearchParams.prototype.toString = function() {
  return this._entries.map(function(e) {
    return encodeURIComponent(e[0]) + '=' + encodeURIComponent(e[1]);
  }).join('&');
};
URLSearchParams.prototype.get = function(name) {
  for (var i = 0; i < this._entries.length; i++) {
    if (this._entries[i][0] === name) return this._entries[i][1];
  }
  return null;
};
URLSearchParams.prototype.append = function(name, value) {
  this._entries.push([name, String(value)]);
};
''';

  Future<JavascriptRuntime> _getJsRuntime() async {
    if (_jsRuntime != null && _runtimeReady) return _jsRuntime!;
    _jsRuntime = getJavascriptRuntime(xhr: false);
    _jsRuntime!.enableHandlePromises();
    _registerFetchBridge(_jsRuntime!);
    _jsRuntime!.evaluate(_fetchPolyfill);
    _jsRuntime!.evaluate(_urlSearchParamsPolyfill);
    _runtimeReady = true;
    return _jsRuntime!;
  }

  void _registerFetchBridge(JavascriptRuntime runtime) {
    runtime.onMessage('fetch', (args) {
      try {
        final data = args is Map
            ? args.map<String, dynamic>((k, v) => MapEntry(k.toString(), v))
            : jsonDecode(args.toString()) as Map<String, dynamic>;
        final id = data['id'];
        final url = data['url']?.toString() ?? '';
        final method = data['method']?.toString() ?? 'GET';
        final rawHeaders = data['headers'];
        final body = data['body']?.toString();

        final headers = <String, String>{};
        if (rawHeaders is Map) {
          rawHeaders.forEach((k, v) => headers[k.toString()] = v.toString());
        }

        _handleFetchRequest(runtime, id, url, method, headers, body);
      } catch (_) {}
      return null;
    });
  }

  void _handleFetchRequest(JavascriptRuntime runtime, dynamic id, String url,
      String method, Map<String, String> headers, String? body) async {
    try {
      final uri = Uri.parse(url);
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      final escapedBody = _escapeForJs(response.body);
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      runtime.evaluate('''
        (function() {
          var cb = globalThis._fetchCallbacks[$id];
          if (cb) {
            cb.resolve({
              ok: $ok,
              status: ${response.statusCode},
              statusText: '${response.reasonPhrase ?? 'OK'}',
              headers: { get: function(n) { return null; } },
              json: function() { return Promise.resolve(JSON.parse('$escapedBody')); },
              text: function() { return Promise.resolve('$escapedBody'); },
            });
            delete globalThis._fetchCallbacks[$id];
          }
        })();
      ''');
    } catch (e) {
      final errorMsg = e.toString().replaceAll("'", "\\'");
      runtime.evaluate('''
        (function() {
          var cb = globalThis._fetchCallbacks[$id];
          if (cb) {
            cb.reject(new Error('$errorMsg'));
            delete globalThis._fetchCallbacks[$id];
          }
        })();
      ''');
    }
  }

  static String _escapeForJs(String json) {
    return json
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }

  void dispatchWrapper(Map<String, dynamic> stateUpdate) {
    try {
      spotcheckStore.dispatch(stateUpdate);
    } catch (e) {
      sentry.captureP1Error(e, 'GENERAL', {'action': 'dispatchWrapper'});
    }
  }

  void resetInitializationGate() {
    _widgetInitializationComplete = false;
  }

  void abandonPendingInitialization() {
    _widgetInitializationComplete = true;
    _pendingExecutes.clear();
  }

  Future<void> flushPendingExecutes() async {
    _widgetInitializationComplete = true;
    while (_pendingExecutes.isNotEmpty) {
      final item = _pendingExecutes.removeAt(0);
      await execute(item.functionName, item.params);
    }
  }

  static bool _isTrackScreenOrEvent(String functionName) {
    return functionName == 'trackScreen' || functionName == 'trackEvent';
  }

  Future<dynamic> execute(String functionName,
      [Map<String, dynamic>? params]) async {
    try {
      final isTrack = _isTrackScreenOrEvent(functionName);
      final isInitComponent = functionName == 'initializeSpotcheckComponent';

      // Only trackScreen / trackEvent are queued; everything else keeps prior behavior.
      if (isTrack) {
        if (!functionStore.isLoaded || !_widgetInitializationComplete) {
          _pendingExecutes.add((functionName: functionName, params: params));
          return null;
        }
      } else if (!isInitComponent) {
        if (!functionStore.isLoaded) return null;
      } else if (!functionStore.isLoaded) {
        return null;
      }

      final functionString = functionStore.getFunction(functionName);
      if (functionString == null || functionString is! String) {
        return null;
      }

      final payload = _buildPayload(params);
      return await _enqueueJsExecution(
        () => _runFunction(functionName, functionString, payload),
      );
    } catch (e) {
      sentry.captureP1Error(e, 'GENERAL',
          {'action': 'execute:setup', 'functionName': functionName});
      return null;
    }
  }

  /// Runs [run] after any prior JS execution completes (success or failure).
  Future<T> _enqueueJsExecution<T>(Future<T> Function() run) {
    final previous = _jsExecutionChain ?? Future<void>.value();
    final completer = Completer<T>();
    _jsExecutionChain = previous.catchError((_) {}).then((_) async {
      try {
        final result = await run();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Map<String, dynamic> _buildPayload(Map<String, dynamic>? params) {
    final p = spotcheckStore.state.params;
    final mergedParams = <String, dynamic>{
      'sdkVersion': sdkVersion,
      'platform': 'flutter',
      if (p['framework'] != null) 'framework': p['framework'],
      if (p['userAgent'] != null &&
          (p['userAgent'] as String).trim().isNotEmpty)
        'userAgent': p['userAgent'],
      ...?params,
    };

    return {
      'params': mergedParams,
      'state': spotcheckStore.getState(),
      'listener': listener.toJson(),
    };
  }

  String _generateTraceId() {
    final uuidString = const Uuid().v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$uuidString-$timestamp';
  }

  Future<dynamic> _runFunction(
    String functionName,
    String functionString,
    Map<String, dynamic> payload,
  ) async {
    try {
      final storedUuid = await storage.loadData() ?? '';
      final traceId = _generateTraceId();

      final storedUuidJson = jsonEncode(storedUuid);
      final traceIdJson = jsonEncode(traceId);
      final payloadJson = jsonEncode(payload);

      final script = '''
(async function() {
  var module = {exports: {}};
  var exports = module.exports;
  var func = ($functionString);
  var payload = $payloadJson;

  var dispatchUpdates = [];
  var storageSaves = [];
  var pendingTimers = [];

  var _origSetTimeout = typeof setTimeout !== 'undefined' ? setTimeout : null;
  setTimeout = function(fn, delay) {
    pendingTimers.push({ fn: fn, delay: delay || 0 });
    return pendingTimers.length;
  };

  payload.dispatchWrapper = function(update) {
    dispatchUpdates.push(JSON.parse(JSON.stringify(update)));
  };

  payload.storage = {
    saveData: function(data) {
      storageSaves.push(typeof data === 'string' ? data : JSON.stringify(data));
      return Promise.resolve();
    },
    loadData: function(isUuid) {
      if (isUuid) return Promise.resolve($traceIdJson);
      return Promise.resolve($storedUuidJson);
    },
  };

  var sentryReports = [];
  payload.sentry = {
    captureP0Error: function(error, source, context) {
      var msg = (error && error.message) ? String(error.message) : String(error);
      sentryReports.push({
        priority: 'P0',
        error: msg,
        source: String(source || 'GENERAL'),
        context: context && typeof context === 'object' ? context : {},
      });
    },
    captureP1Error: function(error, source, context) {
      var msg = (error && error.message) ? String(error.message) : String(error);
      sentryReports.push({
        priority: 'P1',
        error: msg,
        source: String(source || 'GENERAL'),
        context: context && typeof context === 'object' ? context : {},
      });
    },
  };

  payload.keyboard = {
    pauseDefaultKeyboardBehavior: function() {},
    resumeDefaultKeyboardBehavior: function() {},
  };

  payload.listener = {
    onSurveyLoaded: function() { return Promise.resolve(); },
    onSurveyResponse: function() { return Promise.resolve(); },
    onPartialSubmission: function() { return Promise.resolve(); },
    onCloseButtonTap: function() { return Promise.resolve(); },
  };

  async function flushPendingTimers() {
    if (pendingTimers.length === 0) return;
    var flushOne = function(t) {
      return new Promise(function(resolve) {
        var ms = Math.max(0, Number(t.delay) || 0);
        var run = function() {
          try { t.fn(); } catch (te) {}
          resolve();
        };
        if (_origSetTimeout) {
          _origSetTimeout(run, ms);
        } else {
          run();
        }
      });
    };
    await Promise.all(pendingTimers.map(flushOne));
  }

  try {
    var result = await func(payload);
    await flushPendingTimers();

    if (_origSetTimeout) setTimeout = _origSetTimeout;
    return JSON.stringify({ __result: result || null, __dispatches: dispatchUpdates, __storageSaves: storageSaves, __sentryReports: sentryReports });
  } catch(e) {
    await flushPendingTimers();

    if (_origSetTimeout) setTimeout = _origSetTimeout;
    return JSON.stringify({ __error: e.message || String(e), __dispatches: dispatchUpdates, __storageSaves: storageSaves, __sentryReports: sentryReports });
  }
})()
''';

      final runtime = await _getJsRuntime();
      final evalResult = runtime.evaluate(script);
      final asyncResult = await runtime.handlePromise(evalResult);

      if (asyncResult.isError) {
        sentry.captureP1Error(
          asyncResult.stringResult.isNotEmpty
              ? asyncResult.stringResult
              : 'JS runtime evaluate failed',
          'GENERAL',
          {
            'action': 'execute:evaluate',
            'functionName': functionName,
          },
        );
        return null;
      }

      final stringVal = asyncResult.stringResult;
      if (stringVal.isEmpty) {
        sentry.captureP1Error(
          'Empty JS result',
          'GENERAL',
          {
            'action': 'execute:emptyResult',
            'functionName': functionName,
          },
        );
        return null;
      }

      final parsed = _deepCastMap(jsonDecode(stringVal));

      if (parsed is Map<String, dynamic>) {
        final storageSaves = parsed['__storageSaves'];
        if (storageSaves is List) {
          for (final saveValue in storageSaves) {
            if (saveValue is String && saveValue.isNotEmpty) {
              await storage.saveData(saveValue);
            }
          }
        }

        final dispatches = parsed['__dispatches'];
        if (dispatches is List && dispatches.isNotEmpty) {
          final batch = <dynamic>[];
          for (final dispatch in dispatches) {
            if (dispatch is Map) batch.add(dispatch);
          }
          if (batch.isNotEmpty) {
            spotcheckStore.batchDispatch(batch);
            onAfterBatchDispatch?.call();
          }
        }

        await _flushJsSentryReports(parsed['__sentryReports']);

        if (parsed.containsKey('__error')) {
          final errMsg = parsed['__error']?.toString() ?? 'Unknown';
          sentry.captureP1Error(
            errMsg,
            'GENERAL',
            {
              'action': 'execute:runtime',
              'functionName': functionName,
            },
          );
          return null;
        }
        return parsed['__result'];
      }

      return parsed;
    } catch (e) {
      sentry.captureP1Error(
        e,
        'GENERAL',
        {
          'action': 'execute:runtime',
          'functionName': functionName,
        },
      );
      return null;
    }
  }

  Future<void> _flushJsSentryReports(dynamic raw) async {
    if (raw is! List) return;
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final p = m['priority']?.toString() ?? 'P1';
      final err = m['error']?.toString() ?? 'Unknown';
      final src = m['source']?.toString() ?? 'GENERAL';
      Map<String, dynamic>? ctx;
      final c = m['context'];
      if (c is Map) {
        ctx = c.map((k, v) => MapEntry(k.toString(), v));
      }
      await sentry.reportFromJsBridge(
        priority: p,
        errorMessage: err,
        source: src,
        context: ctx,
      );
    }
  }

  void dispose() {
    _jsRuntime?.dispose();
    _jsRuntime = null;
  }
}
