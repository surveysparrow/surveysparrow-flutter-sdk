import 'dart:convert';
import 'package:flutter_js/flutter_js.dart';

class JsEngine {
  static JsEngine? _instance;
  late JavascriptRuntime _runtime;

  JsEngine._() {
    _runtime = getJavascriptRuntime();
  }

  static JsEngine get instance {
    _instance ??= JsEngine._();
    return _instance!;
  }

  Future<dynamic> executeFunction(
      String functionString, Map<String, dynamic> payload) async {
    try {
      final payloadJson = jsonEncode(payload);
      final script = '''
(async function() {
  var module = {exports: {}};
  var exports = module.exports;
  var func = ($functionString);
  var payload = $payloadJson;

  var dispatchUpdates = [];
  payload.dispatchWrapper = function(update) {
    dispatchUpdates.push(JSON.parse(JSON.stringify(update)));
  };

  payload.storage = {
    saveData: function(data) { return "__STORAGE_SAVE__" + JSON.stringify(data); },
    loadData: function(isUuid) { return "__STORAGE_LOAD__" + (isUuid ? "uuid" : "data"); },
  };

  payload.sentry = {
    captureP0Error: function(error, source, context) {},
    captureP1Error: function(error, source, context) {},
  };

  payload.keyboard = {
    pauseDefaultKeyboardBehavior: function() {},
    resumeDefaultKeyboardBehavior: function() {},
  };

  payload.listener = payload.listener || {};

  var result;
  try {
    result = await func(payload);
  } catch(e) {
    return JSON.stringify({ __error: e.message || String(e), __dispatches: dispatchUpdates });
  }

  return JSON.stringify({
    __result: result,
    __dispatches: dispatchUpdates,
  });
})()
''';

      final result = _runtime.evaluate(script);
      if (result.isError) {
        return null;
      }

      final stringVal = result.stringResult;
      if (stringVal.isEmpty) return null;

      try {
        return jsonDecode(stringVal);
      } catch (_) {
        return stringVal;
      }
    } catch (e) {
      return null;
    }
  }

  dynamic evaluateExpression(
      String expr, Map<String, dynamic> state, Map<String, dynamic> styles) {
    try {
      final stateJson = jsonEncode(state);
      final stylesJson = jsonEncode(styles);

      final script = '''
(function() {
  var state = $stateJson;
  var styles = $stylesJson;
  try {
    return JSON.stringify({ result: ($expr) });
  } catch(e) {
    return JSON.stringify({ error: e.message || String(e) });
  }
})()
''';

      final result = _runtime.evaluate(script);
      if (result.isError) return null;

      final stringVal = result.stringResult;
      if (stringVal.isEmpty) return null;

      try {
        final parsed = jsonDecode(stringVal);
        if (parsed is Map && parsed.containsKey('error')) return null;
        return parsed['result'];
      } catch (_) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _runtime.dispose();
    _instance = null;
  }
}
