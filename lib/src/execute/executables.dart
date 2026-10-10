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

  /// Backend-driven script injection into the classic/chat webview.
  void Function(String target, String script)? onWebViewInject;

  static const Duration _executeTimeout = Duration(seconds: 15);
  final Map<int, Timer> _timers = {};

  bool _widgetInitializationComplete = false;
  // Bounds the track queue while init is failing (RN parity).
  static const int _maxPendingExecutes = 20;

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

  static const String _bridgePolyfill = r'''
(function() {
  var timers = {};
  var nextTimerId = 0;
  globalThis.setTimeout = function(fn, ms) {
    var id = ++nextTimerId;
    timers[id] = fn;
    sendMessage('ssTimer', JSON.stringify({ id: id, ms: Number(ms) || 0 }));
    return id;
  };
  globalThis.clearTimeout = function(id) {
    if (timers[id]) {
      delete timers[id];
      sendMessage('ssClearTimer', JSON.stringify({ id: id }));
    }
  };
  globalThis.__ssFireTimer = function(id) {
    var fn = timers[id];
    delete timers[id];
    if (!fn) return;
    try { fn(); } catch (e) {
      sendMessage('ssSentry', JSON.stringify({ priority: 'P1', error: String((e && e.message) || e), source: 'GENERAL', context: { action: 'timer' } }));
    }
  };
})();
''';

  Future<JavascriptRuntime> _getJsRuntime() async {
    if (_jsRuntime != null && _runtimeReady) return _jsRuntime!;
    final runtime = getJavascriptRuntime(xhr: false);
    _jsRuntime = runtime;
    runtime.enableHandlePromises();
    _registerFetchBridge(runtime);
    _registerPayloadBridges(runtime);
    runtime.evaluate(_fetchPolyfill);
    runtime.evaluate(_urlSearchParamsPolyfill);
    runtime.evaluate(_bridgePolyfill);
    _runtimeReady = true;
    return runtime;
  }

  static Map<String, dynamic> _decodeArgs(dynamic args) {
    if (args is Map) return _deepCastMap(args) as Map<String, dynamic>;
    final decoded = jsonDecode(args.toString());
    return decoded is Map ? _deepCastMap(decoded) as Map<String, dynamic> : {};
  }

  void _registerPayloadBridges(JavascriptRuntime runtime) {
    void on(String channel, void Function(Map<String, dynamic> data) handler) {
      runtime.onMessage(channel, (args) {
        try {
          handler(_decodeArgs(args));
        } catch (e) {
          sentry.captureP1Error(e, 'GENERAL', {'action': 'bridge:$channel'});
        }
        return null;
      });
    }

    on('ssDispatch', (data) {
      spotcheckStore.dispatch(data['update']);
    });
    on('ssStorageSave', (data) {
      final value = data['value'];
      if (value is String && value.isNotEmpty) unawaited(storage.saveData(value));
    });
    on('ssListener', (data) {
      final response = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : <String, dynamic>{};
      switch (data['name']) {
        case 'onSurveyLoaded':
          unawaited(listener.onSurveyLoaded(response));
          break;
        case 'onSurveyResponse':
          unawaited(listener.onSurveyResponse(response));
          break;
        case 'onPartialSubmission':
          unawaited(listener.onPartialSubmission(response));
          break;
        case 'onCloseButtonTap':
          unawaited(listener.onCloseButtonTap());
          break;
      }
    });
    // Reported outside the JS queue so a report never waits on itself.
    on('ssSentry', (data) {
      unawaited(sentry.reportFromJsBridge(
        priority: data['priority']?.toString() ?? 'P1',
        errorMessage: data['error']?.toString() ?? 'Unknown',
        source: data['source']?.toString() ?? 'GENERAL',
        context: data['context'] is Map
            ? Map<String, dynamic>.from(data['context'] as Map)
            : null,
      ));
    });
    on('ssKeyboard', (data) {
      if (data['action'] == 'pause') {
        keyboard.pauseDefaultKeyboardBehavior();
      } else {
        keyboard.resumeDefaultKeyboardBehavior();
      }
    });
    on('ssWebViewInject', (data) {
      final target = data['target']?.toString() ?? 'classic';
      final script = data['script']?.toString() ?? '';
      if (script.isNotEmpty) onWebViewInject?.call(target, script);
    });
    on('ssTimer', (data) {
      final id = (data['id'] as num).toInt();
      final ms = (data['ms'] as num?)?.toInt() ?? 0;
      _timers[id]?.cancel();
      _timers[id] = Timer(Duration(milliseconds: ms < 0 ? 0 : ms), () {
        _timers.remove(id);
        if (_jsRuntime != runtime) return;
        runtime.evaluate('__ssFireTimer($id);');
        runtime.executePendingJob();
      });
    });
    on('ssClearTimer', (data) {
      final id = (data['id'] as num).toInt();
      _timers.remove(id)?.cancel();
    });
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

      // Runtime may be disposed while the request was in flight.
      if (_jsRuntime != runtime) return;
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      runtime.evaluate('''
        (function() {
          var cb = globalThis._fetchCallbacks[$id];
          if (cb) {
            var body = ${jsonEncode(response.body)};
            cb.resolve({
              ok: $ok,
              status: ${response.statusCode},
              statusText: ${jsonEncode(response.reasonPhrase ?? 'OK')},
              headers: { get: function(n) { return null; } },
              json: function() { return Promise.resolve(JSON.parse(body)); },
              text: function() { return Promise.resolve(body); },
            });
            delete globalThis._fetchCallbacks[$id];
          }
        })();
      ''');
      runtime.executePendingJob();
    } catch (e) {
      if (_jsRuntime != runtime) return;
      runtime.evaluate('''
        (function() {
          var cb = globalThis._fetchCallbacks[$id];
          if (cb) {
            cb.reject(new Error(${jsonEncode(e.toString())}));
            delete globalThis._fetchCallbacks[$id];
          }
        })();
      ''');
      runtime.executePendingJob();
    }
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
          if (_pendingExecutes.length > _maxPendingExecutes) _pendingExecutes.removeAt(0);
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

      if (_isBreadcrumbWorthy(functionName)) {
        sentry.addBreadcrumb('execute', {
          'functionName': functionName,
          ..._describeParams(functionName, params),
        });
      }
      // Payload built when the call runs, so queued calls see the latest state.
      return await _enqueueJsExecution(
        () => _runFunction(functionName, functionString, _buildPayload(params)),
      );
    } catch (e) {
      if (!_isSentryFunction(functionName)) {
        sentry.captureP1Error(e, 'GENERAL',
            {'action': 'execute:setup', 'functionName': functionName});
      }
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
    final reportErrors = !_isSentryFunction(functionName);
    try {
      final storedUuid = await storage.loadData() ?? '';
      final traceId = _generateTraceId();

      final script = '''
(async function() {
  var module = {exports: {}};
  var exports = module.exports;
  var func = ($functionString);
  var payload = ${jsonEncode(payload)};
  var send = function(channel, data) { sendMessage(channel, JSON.stringify(data)); };
  var report = function(priority, error, source, context) {
    send('ssSentry', {
      priority: priority,
      error: (error && error.message) ? String(error.message) : String(error),
      source: String(source || 'GENERAL'),
      context: context && typeof context === 'object' ? context : {},
    });
  };
  var notify = function(name) {
    return function(data) { send('ssListener', { name: name, data: data || {} }); return Promise.resolve(); };
  };

  payload.dispatchWrapper = function(update) { send('ssDispatch', { update: update }); };
  payload.storage = {
    saveData: function(data) {
      send('ssStorageSave', { value: typeof data === 'string' ? data : JSON.stringify(data) });
      return Promise.resolve();
    },
    loadData: function(isUuid) {
      return Promise.resolve(isUuid ? ${jsonEncode(traceId)} : ${jsonEncode(storedUuid)});
    },
  };
  payload.sentry = {
    captureP0Error: function(error, source, context) { report('P0', error, source, context); },
    captureP1Error: function(error, source, context) { report('P1', error, source, context); },
  };
  payload.keyboard = {
    pauseDefaultKeyboardBehavior: function() { send('ssKeyboard', { action: 'pause' }); },
    resumeDefaultKeyboardBehavior: function() { send('ssKeyboard', { action: 'resume' }); },
  };
  payload.listener = {
    onSurveyLoaded: notify('onSurveyLoaded'),
    onSurveyResponse: notify('onSurveyResponse'),
    onPartialSubmission: notify('onPartialSubmission'),
    onCloseButtonTap: notify('onCloseButtonTap'),
  };
  payload.webview = {
    inject: function(target, js) { send('ssWebViewInject', { target: String(target), script: String(js) }); },
  };

  try {
    var result = await func(payload);
    return JSON.stringify({ __result: result === undefined ? null : result });
  } catch (e) {
    return JSON.stringify({ __error: (e && e.message) || String(e) });
  }
})()
''';

      final runtime = await _getJsRuntime();
      final evalResult = runtime.evaluate(script);
      final asyncResult =
          await runtime.handlePromise(evalResult, timeout: _executeTimeout);

      if (asyncResult.isError) {
        if (reportErrors) {
          sentry.captureP1Error(
            asyncResult.stringResult.isNotEmpty
                ? asyncResult.stringResult
                : 'JS runtime evaluate failed',
            'GENERAL',
            {'action': 'execute:evaluate', 'functionName': functionName},
          );
        }
        return null;
      }

      final stringVal = asyncResult.stringResult;
      if (stringVal.isEmpty) return null;

      var decoded = jsonDecode(stringVal);
      // Some engines return the JSON string quoted once more.
      if (decoded is String) decoded = jsonDecode(decoded);
      final parsed = _deepCastMap(decoded);
      if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('__error')) {
          if (reportErrors) {
            sentry.captureP1Error(
              parsed['__error']?.toString() ?? 'Unknown',
              'GENERAL',
              {'action': 'execute:runtime', 'functionName': functionName},
            );
          }
          return null;
        }
        return parsed['__result'];
      }
      return parsed;
    } on TimeoutException {
      if (reportErrors) {
        sentry.captureP1Error('Execution timed out', 'GENERAL',
            {'action': 'execute:timeout', 'functionName': functionName});
      }
      return null;
    } catch (e) {
      if (reportErrors) {
        sentry.captureP1Error(e, 'GENERAL',
            {'action': 'execute:runtime', 'functionName': functionName});
      }
      return null;
    }
  }

  // Reporting failures are not reported again (avoids loops).
  static bool _isSentryFunction(String functionName) =>
      functionName.startsWith('sentry.');

  // Style getters run on every rebuild; they would push useful breadcrumbs out.
  static bool _isBreadcrumbWorthy(String functionName) =>
      !_isSentryFunction(functionName) &&
      !RegExp(r'\.get\w*Styles$').hasMatch(functionName);

  // Message type only; never survey content.
  static Map<String, dynamic> _describeParams(
      String functionName, Map<String, dynamic>? params) {
    if (functionName != 'webviewComponent.handleWebViewMessage') return {};
    try {
      final data = (params?['event'] as Map?)?['nativeEvent']?['data'];
      if (data == 'captureImage') return {'messageType': data};
      final decoded = jsonDecode(data.toString());
      return decoded is Map ? {'messageType': decoded['type']} : {};
    } catch (_) {
      return {};
    }
  }

  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _jsRuntime?.dispose();
    _jsRuntime = null;
    _runtimeReady = false;
  }
}
