import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'component_registry.dart';
import 'animation_wrapper.dart';

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

class BuilderContext {
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? styles;
  final Map<String, Widget>? slots;
  final Map<String, Function>? handlers;

  const BuilderContext({this.state, this.styles, this.slots, this.handlers});
}

class SchemaBuilder extends StatelessWidget {
  final dynamic schema;
  final BuilderContext context;

  const SchemaBuilder({
    super.key,
    required this.schema,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    if (schema == null) return const SizedBox.shrink();

    if (schema is List) {
      final children = (schema as List)
          .asMap()
          .entries
          .map((e) => _renderNode(e.value, 'root-${e.key}'))
          .where((w) => w != null)
          .cast<Widget>()
          .toList();
      if (children.isEmpty) return const SizedBox.shrink();
      if (children.length == 1) return children.first;
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    }

    if (schema is Map) {
      return _renderNode(schema, 'root') ?? const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  Widget? _renderNode(dynamic rawNode, String key) {
    final node = _deepCast(rawNode) as Map<String, dynamic>;

    if (node.containsKey('slot') && context.slots != null) {
      return context.slots![node['slot'] as String];
    }

    if (node.containsKey('if')) {
      final conditionResult = evaluateCondition(node['if'], context);
      if (!conditionResult) return null;
    }

    final type = node['type'] as String?;
    if (type == null) return null;

    final builder = ComponentRegistry.instance.get(type);
    if (builder == null) return null;

    final rawProps = node['props'] as Map<String, dynamic>?;
    final resolvedProps =
        rawProps != null ? _resolveBindingMap(rawProps) : <String, dynamic>{};

    final hasContent = node.containsKey('content');
    final content =
        hasContent ? resolveBinding(node['content'], context) : null;

    final childNodes = node['children'] as List?;
    final children = childNodes
        ?.asMap()
        .entries
        .map((e) => _renderNode(e.value, '$key-${e.key}'))
        .where((w) => w != null)
        .cast<Widget>()
        .toList();

    final animation = node['animation'] as Map<String, dynamic>?;

    Widget widget = builder(
      resolvedProps,
      hasContent ? null : children,
      content: hasContent ? content?.toString() : null,
    );

    widget = KeyedSubtree(key: ValueKey(key), child: widget);

    if (animation != null) {
      widget = AnimationWrapper(
        key: ValueKey('anim-$key'),
        animation: animation,
        context: context,
        child: widget,
      );
    }

    return widget;
  }

  Map<String, dynamic> _resolveBindingMap(Map<String, dynamic> props) {
    final resolved = <String, dynamic>{};
    for (final entry in props.entries) {
      resolved[entry.key] = resolveBinding(entry.value, context);
    }
    return resolved;
  }
}

dynamic resolveBinding(dynamic value, BuilderContext context) {
  if (value == null || value is num || value is bool || value is String) {
    return value;
  }

  if (value is List) {
    return value.map((item) => resolveBinding(item, context)).toList();
  }

  if (value is Map) {
    final m = _deepCast(value) as Map<String, dynamic>;

    if (m.containsKey('\$expr')) {
      return evaluateExpression(m['\$expr'] as String, context);
    }

    if (m.containsKey('\$ref')) {
      final path = (m['\$ref'] as String).split('.');
      dynamic result = <String, dynamic>{
        'state': context.state,
        'styles': context.styles,
        'slots': null,
        'handlers': null,
      };
      for (final k in path) {
        if (result is Map) {
          result = result[k];
        } else {
          return null;
        }
      }
      return result;
    }

    if (m.containsKey('\$path')) {
      final path = (m['\$path'] as String).split('.');
      dynamic result = context.state;
      for (final k in path) {
        if (result is Map) {
          result = result[k];
        } else {
          return null;
        }
      }
      return result;
    }

    if (m.containsKey('\$handler') && context.handlers != null) {
      return context.handlers![m['\$handler'] as String];
    }

    if (m.containsKey('\$handlers') && context.handlers != null) {
      final handlerNames = m['\$handlers'] as List;
      return () {
        for (final name in handlerNames) {
          final handler = context.handlers![name as String];
          if (handler != null) handler();
        }
      };
    }

    final resolved = <String, dynamic>{};
    for (final entry in m.entries) {
      resolved[entry.key] = resolveBinding(entry.value, context);
    }
    return resolved;
  }

  return value;
}

dynamic evaluateExpression(String expr, BuilderContext context) {
  try {
    final stateJson = jsonEncode(context.state ?? {});
    final stylesJson = jsonEncode(context.styles ?? {});

    final runtime = getJavascriptRuntime();
    try {
      final script = '''
(function() {
  var state = $stateJson;
  var styles = $stylesJson;
  try {
    var result = ($expr);
    return JSON.stringify({r: result});
  } catch(e) {
    return JSON.stringify({e: e.message});
  }
})()
''';
      final result = runtime.evaluate(script);
      if (result.isError) return _exprFallback(expr);

      final parsed = jsonDecode(result.stringResult);
      if (parsed is Map && parsed.containsKey('e')) return _exprFallback(expr);
      return parsed['r'];
    } finally {
      runtime.dispose();
    }
  } catch (_) {
    return _exprFallback(expr);
  }
}

dynamic _exprFallback(String expr) {
  if (expr.contains('translateY') || expr.contains('translateX')) return 0;
  if (expr.contains('scale')) return 1;
  if (expr.contains('opacity')) return 1;
  return null;
}

bool evaluateCondition(dynamic condition, BuilderContext context) {
  if (condition == null) return true;

  if (condition is Map) {
    final condition_ = _deepCast(condition) as Map<String, dynamic>;

    if (condition_.containsKey('\$path') ||
        condition_.containsKey('\$ref') ||
        condition_.containsKey('\$expr')) {
      final resolved = resolveBinding(condition_, context);
      if (resolved == null ||
          resolved == false ||
          resolved == 0 ||
          resolved == '') {
        return false;
      }
      return true;
    }

    return _evaluateConditionMap(condition_, context);
  }

  final resolved = resolveBinding(condition, context);
  if (resolved == null ||
      resolved == false ||
      resolved == 0 ||
      resolved == '') {
    return false;
  }
  return true;
}

bool _evaluateConditionMap(
    Map<String, dynamic> condition, BuilderContext context) {
  if (condition.containsKey('\$and')) {
    final list = condition['\$and'] as List;
    return list.every((c) => evaluateCondition(c, context));
  }
  if (condition.containsKey('\$or')) {
    final list = condition['\$or'] as List;
    return list.any((c) => evaluateCondition(c, context));
  }
  if (condition.containsKey('\$not')) {
    return !evaluateCondition(condition['\$not'], context);
  }
  if (condition.containsKey('\$eq')) {
    final pair = condition['\$eq'] as List;
    if (pair.length == 2) {
      final left = resolveBinding(pair[0], context);
      final right = resolveBinding(pair[1], context);
      return left == right;
    }
  }
  if (condition.containsKey('\$ne')) {
    final pair = condition['\$ne'] as List;
    if (pair.length == 2) {
      final left = resolveBinding(pair[0], context);
      final right = resolveBinding(pair[1], context);
      return left != right;
    }
  }
  if (condition.containsKey('\$gt')) {
    final pair = condition['\$gt'] as List;
    if (pair.length == 2) {
      final left = resolveBinding(pair[0], context);
      final right = resolveBinding(pair[1], context);
      if (left is num && right is num) return left > right;
      return false;
    }
  }
  if (condition.containsKey('\$lt')) {
    final pair = condition['\$lt'] as List;
    if (pair.length == 2) {
      final left = resolveBinding(pair[0], context);
      final right = resolveBinding(pair[1], context);
      if (left is num && right is num) return left < right;
      return false;
    }
  }
  return true;
}
