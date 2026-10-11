import 'package:flutter/foundation.dart';

class FunctionStore extends ChangeNotifier {
  bool _isLoaded = false;
  final Map<String, dynamic> _functions = {};

  bool get isLoaded => _isLoaded;

  void loadFunctions(Map<String, dynamic> data) {
    _functions.clear();
    _functions.addAll(data);
    _isLoaded = true;
    notifyListeners();
  }

  dynamic getFunction(String path) {
    final parts = path.split('.');
    dynamic result = _functions;
    for (final part in parts) {
      if (result is Map) {
        result = result[part];
      } else {
        return null;
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'functionState': {
          'isLoaded': _isLoaded,
          ..._functions,
        },
      };
}
