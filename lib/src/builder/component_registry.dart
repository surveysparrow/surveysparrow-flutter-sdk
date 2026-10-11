import 'package:flutter/material.dart';

typedef WidgetBuilder = Widget Function(
    Map<String, dynamic> props, List<Widget>? children, {String? content});

class ComponentRegistry {
  static final ComponentRegistry _instance = ComponentRegistry._();
  final Map<String, WidgetBuilder> _registry = {};

  ComponentRegistry._();

  static ComponentRegistry get instance => _instance;

  void register(String name, WidgetBuilder builder) {
    _registry[name] = builder;
  }

  WidgetBuilder? get(String name) => _registry[name];

  bool has(String name) => _registry.containsKey(name);

  List<String> list() => _registry.keys.toList();
}

// Marks a widget that builds a Positioned, so Stack builders place it as an overlay.
class PositionedSlot extends StatelessWidget {
  final Widget child;
  const PositionedSlot({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
