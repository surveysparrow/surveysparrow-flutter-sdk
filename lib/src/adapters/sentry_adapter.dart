import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Keep in sync with [sdkVersion] in `execute/executables.dart`.
const String _spotcheckSdkVersion = '2.0.0-beta.1';

/// Expo/Android parity: prefer bundled `sentry.processSentryError`, then direct `POST …/sdkErrors`.
class SentryAdapter {
  String? _domainName;
  String? _targetToken;

  Future<dynamic> Function(String functionName, Map<String, dynamic>? params)?
      _executeFn;
  bool Function()? _functionsLoaded;

  void configure({String? domainName, String? targetToken}) {
    _domainName = domainName;
    _targetToken = targetToken;
  }

  /// Wire after [Executables] exists; avoids circular imports by using callbacks.
  void wireExecute({
    required Future<dynamic> Function(String, Map<String, dynamic>?) execute,
    required bool Function() functionsLoaded,
  }) {
    _executeFn = execute;
    _functionsLoaded = functionsLoaded;
  }

  void captureP0Error(dynamic error, String source,
      [Map<String, dynamic>? context]) {
    final msg = _stringifyError(error);
    scheduleMicrotask(
        () => _reportError(msg, source, 'P0', context));
  }

  void captureP1Error(dynamic error, String source,
      [Map<String, dynamic>? context]) {
    final msg = _stringifyError(error);
    scheduleMicrotask(
        () => _reportError(msg, source, 'P1', context));
  }

  /// Flushes reports collected from bundled JS (`payload.sentry.captureP0/P1`).
  Future<void> reportFromJsBridge({
    required String priority,
    required String errorMessage,
    required String source,
    Map<String, dynamic>? context,
  }) =>
      _reportError(errorMessage, source, priority, context);

  static String _stringifyError(dynamic error) {
    if (error is Exception) return error.toString();
    return error?.toString() ?? 'Unknown error';
  }

  Future<void> _reportError(
    String errorMessage,
    String source,
    String priority,
    Map<String, dynamic>? context,
  ) async {
    if (_domainName == null || _domainName!.isEmpty) return;

    final normalizedEvent = <String, dynamic>{
      'errorMessage': errorMessage,
      'tags': <String, dynamic>{
        'error_priority': priority,
        'severity': priority == 'P0' ? 'CRITICAL' : 'HIGH',
        'errorType': source,
      },
      'contexts': context ?? <String, dynamic>{},
    };

    final exec = _executeFn;
    final loaded = _functionsLoaded?.call() ?? false;
    if (exec != null && loaded) {
      try {
        final r = await exec('sentry.processSentryError', <String, dynamic>{
          'event': normalizedEvent,
          'sdkType': 'flutter',
          'sdkVersion': _spotcheckSdkVersion,
        });
        if (_isProcessSentrySuccess(r)) return;
      } catch (_) {}
    }

    await _postDirectToBackend(errorMessage, source, priority, context);
  }

  bool _isProcessSentrySuccess(dynamic r) => r == true;

  Future<void> _postDirectToBackend(
    String errorMessage,
    String source,
    String priority,
    Map<String, dynamic>? context,
  ) async {
    if (_domainName == null || _domainName!.isEmpty) return;

    try {
      final url = Uri.parse(
          'https://$_domainName/api/internal/spotcheck/sdkErrors');
      final level = priority == 'P0' ? 'fatal' : 'error';
      final body = <String, dynamic>{
        'errorMessage': errorMessage,
        'sdkType': 'flutter',
        'sdkVersion': _spotcheckSdkVersion,
        'level': level,
        'tags': <String, dynamic>{
          'error_priority': priority,
          'severity': priority == 'P0' ? 'CRITICAL' : 'HIGH',
          'errorType': source,
        },
        if (context != null && context.isNotEmpty) 'extra': context,
        'contexts': <String, dynamic>{
          'user': <String, dynamic>{
            'spotcheck_token': _targetToken ?? '',
            'spotcheck_domain_name': _domainName ?? '',
          },
        },
      };
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {}
  }
}
