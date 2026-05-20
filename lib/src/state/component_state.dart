import 'package:flutter/foundation.dart';

dynamic _deepCast(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), _deepCast(v)),
    );
  }
  if (value is List) {
    return value.map(_deepCast).toList();
  }
  return value;
}

class ComponentStore extends ChangeNotifier {
  bool _isLoaded = false;
  Map<String, dynamic>? _schemas;

  bool get isLoaded => _isLoaded;
  Map<String, dynamic>? get schemas => _schemas;

  void loadSchemas(Map<String, dynamic> data) {
    _schemas = _deepCast(data) as Map<String, dynamic>;
    _isLoaded = true;
    notifyListeners();
  }

  Map<String, dynamic>? getSchema(String name) {
    final schema = _schemas?[name];
    if (schema is Map) {
      return _deepCast(schema) as Map<String, dynamic>;
    }
    return null;
  }
}
