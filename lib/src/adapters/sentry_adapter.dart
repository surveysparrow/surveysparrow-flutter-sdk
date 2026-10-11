import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sentry/sentry.dart' as sentry_pkg;

/// Keep in sync with `version` in pubspec.yaml.
const String sdkVersion = '1.2.9-beta.1';

/// Expo pattern: an isolated Sentry hub (dummy DSN, never the global
/// Sentry.init) enriches errors; beforeSend routes them to our backend and
/// returns null, so nothing reaches Sentry servers or the host app's Sentry.
class SentryAdapter {
  String? _domainName;
  String? _targetToken;

  Future<dynamic> Function(String functionName, Map<String, dynamic>? params)?
      _executeFn;
  bool Function()? _functionsLoaded;

  static const int _maxBreadcrumbs = 30;
  static const String _hintKey = 'spotcheck';
  final List<Map<String, dynamic>> _breadcrumbs = [];

  sentry_pkg.Hub? _hub;
  bool _hubFailed = false;

  void addBreadcrumb(String message, [Map<String, dynamic>? data]) {
    _breadcrumbs.add({
      'category': 'spotcheck',
      'message': message,
      if (data != null) 'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
    });
    if (_breadcrumbs.length > _maxBreadcrumbs) _breadcrumbs.removeAt(0);
  }

  void configure({String? domainName, String? targetToken}) {
    _domainName = domainName;
    _targetToken = targetToken;
  }

  void wireExecute({
    required Future<dynamic> Function(String, Map<String, dynamic>?) execute,
    required bool Function() functionsLoaded,
  }) {
    _executeFn = execute;
    _functionsLoaded = functionsLoaded;
  }

  void captureP0Error(dynamic error, String source,
      [Map<String, dynamic>? context, StackTrace? stackTrace]) {
    _capture(error, source, 'P0', context, stackTrace ?? StackTrace.current);
  }

  void captureP1Error(dynamic error, String source,
      [Map<String, dynamic>? context, StackTrace? stackTrace]) {
    _capture(error, source, 'P1', context, stackTrace ?? StackTrace.current);
  }

  /// Errors reported by bundled JS (`payload.sentry.captureP0/P1`).
  Future<void> reportFromJsBridge({
    required String priority,
    required String errorMessage,
    required String source,
    Map<String, dynamic>? context,
  }) async =>
      _capture(errorMessage, source, priority, context, null);

  // Isolated hub; created once, never global.
  sentry_pkg.Hub? _ensureHub() {
    if (_hub != null || _hubFailed) return _hub;
    try {
      final options = sentry_pkg.SentryOptions(dsn: 'https://dummy@sentry.io/0')
        ..sendDefaultPii = false
        ..sendClientReports = false
        ..attachStacktrace = true
        ..beforeSend = _beforeSend;
      // Public API only (no internal enricher) so sentry 8.x-10.x all compile.
      _hub = sentry_pkg.Hub(options);
    } catch (_) {
      _hubFailed = true;
    }
    return _hub;
  }

  void _capture(dynamic error, String source, String priority,
      Map<String, dynamic>? context, StackTrace? stackTrace) {
    final hub = _ensureHub();
    final info = <String, dynamic>{
      'priority': priority,
      'source': source,
      'context': context ?? <String, dynamic>{},
    };
    if (hub == null) {
      scheduleMicrotask(() => _route(_basicEvent(error, info)));
      return;
    }
    unawaited(hub
        .captureException(
          error,
          stackTrace: stackTrace,
          hint: sentry_pkg.Hint.withMap({_hintKey: info}),
        )
        .then<void>((_) {})
        .catchError((_) => _route(_basicEvent(error, info))));
  }

  // Sentry-enriched event → backend; returning null stops any send to Sentry.
  Future<sentry_pkg.SentryEvent?> _beforeSend(
      sentry_pkg.SentryEvent event, sentry_pkg.Hint hint) async {
    final info = (hint.get(_hintKey) as Map<String, dynamic>?) ?? const {};
    final priority = info['priority'] as String? ?? 'P1';
    final exception = event.exceptions?.isNotEmpty == true ? event.exceptions!.first : null;
    await _route(<String, dynamic>{
      'errorMessage': exception?.value ?? event.message?.formatted ?? event.throwable?.toString() ?? 'Unknown error',
      'tags': _tags(priority, info['source'] as String? ?? 'GENERAL'),
      'contexts': event.contexts.toJson(),
      'extra': info['context'] ?? <String, dynamic>{},
      'breadcrumbs': List<Map<String, dynamic>>.from(_breadcrumbs),
      'exceptions': event.exceptions
          ?.map((e) => <String, dynamic>{
                'type': e.type,
                'value': e.value,
                'stacktrace': e.stackTrace?.frames.reversed.take(10).map((f) => f.toJson()).toList(),
              })
          .toList(),
      'eventId': event.eventId.toString(),
      'timestamp': event.timestamp?.millisecondsSinceEpoch == null
          ? DateTime.now().millisecondsSinceEpoch / 1000
          : event.timestamp!.millisecondsSinceEpoch / 1000,
      'platform': 'flutter',
    });
    return null;
  }

  Map<String, dynamic> _basicEvent(dynamic error, Map<String, dynamic> info) => {
        'errorMessage': _stringifyError(error),
        'tags': _tags(info['priority'] as String, info['source'] as String),
        'contexts': <String, dynamic>{},
        'extra': info['context'],
        'breadcrumbs': List<Map<String, dynamic>>.from(_breadcrumbs),
        'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        'platform': 'flutter',
      };

  static Map<String, dynamic> _tags(String priority, String source) => {
        'error_priority': priority,
        'severity': priority == 'P0' ? 'CRITICAL' : 'HIGH',
        'errorType': source,
      };

  static String _stringifyError(dynamic error) {
    if (error is Exception) return error.toString();
    return error?.toString() ?? 'Unknown error';
  }

  // processSentryError first; direct POST to /sdkErrors as fallback.
  Future<void> _route(Map<String, dynamic> normalizedEvent) async {
    if (_domainName == null || _domainName!.isEmpty) return;

    final exec = _executeFn;
    final loaded = _functionsLoaded?.call() ?? false;
    if (exec != null && loaded) {
      try {
        final r = await exec('sentry.processSentryError', <String, dynamic>{
          'event': normalizedEvent,
          'sdkType': 'flutter',
          'sdkVersion': sdkVersion,
        });
        if (r == true) return;
      } catch (_) {}
    }

    await _postDirectToBackend(normalizedEvent);
  }

  Future<void> _postDirectToBackend(Map<String, dynamic> event) async {
    try {
      final url = Uri.parse(
          'https://$_domainName/api/internal/spotcheck/sdkErrors');
      final tags = Map<String, dynamic>.from(event['tags'] as Map);
      final extra = event['extra'];
      final body = <String, dynamic>{
        'errorMessage': event['errorMessage'],
        'sdkType': 'flutter',
        'sdkVersion': sdkVersion,
        'level': tags['error_priority'] == 'P0' ? 'fatal' : 'error',
        'tags': tags,
        if (extra is Map && extra.isNotEmpty) 'extra': extra,
        'breadcrumbs': event['breadcrumbs'],
        'contexts': <String, dynamic>{
          ...?(event['contexts'] as Map<String, dynamic>?),
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
