import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../scroll/spotcheck_scroll_binding.dart';
import 'component_registry.dart';

Map<String, dynamic> _safeMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), v is Map ? _safeMap(v) : v),
    );
  }
  return {};
}

Alignment? _alignmentWhenSized(
    Alignment? alignment, double? width, double? height) {
  if (alignment == null) return null;
  if (width != null || height != null) return alignment;
  return null;
}

void registerDefaultComponents() {
  final registry = ComponentRegistry.instance;

  registry.register('Container', _buildContainer);
  registry.register('SafeArea', _buildSafeArea);
  registry.register('GestureDetector', _buildGestureDetector);
  registry.register('Text', _buildText);
  registry.register('Image', _buildImage);
  registry.register('SvgPicture', _buildSvgPicture);
  registry.register('ListView', _buildListView);
}

Widget _buildListView(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final shrinkWrap = props['shrinkWrap'] as bool? ?? true;
  final primary = props['primary'] as bool? ?? true;
  final physicsRaw = props['physics'];
  ScrollPhysics physics = const ClampingScrollPhysics();
  if (physicsRaw == 'bouncing') {
    physics = const BouncingScrollPhysics();
  } else if (physicsRaw == 'clamping') {
    physics = const ClampingScrollPhysics();
  }
  final scrollController = SpotcheckScrollBinding.wrapperList;
  return ListView(
    controller: scrollController,
    shrinkWrap: shrinkWrap,
    primary: primary && scrollController == null,
    physics: physics,
    children: children ?? const <Widget>[],
  );
}

bool _isPositionedLike(Widget w) {
  if (w is Positioned || w is Align) return true;
  if (w is KeyedSubtree) return _isPositionedLike(w.child);
  return false;
}

class _MeasureSize extends StatefulWidget {
  final Widget child;
  final void Function(dynamic event)? onLayout;

  const _MeasureSize({required this.child, this.onLayout});

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  final GlobalKey _key = GlobalKey();
  Size? _lastReportedSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(_MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  void _reportSize() {
    if (widget.onLayout == null) return;
    final object = _key.currentContext?.findRenderObject();
    final box = object as RenderBox?;
    if (box != null && box.hasSize) {
      final size = box.size;
      if (_lastReportedSize != size) {
        _lastReportedSize = size;
        widget.onLayout!({
          'nativeEvent': {
            'layout': {'width': size.width, 'height': size.height}
          },
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

Widget _buildContainer(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final style = _safeMap(props['style']);
  final pointerEvents =
      props['pointerEvents'] as String? ?? style['pointerEvents'] as String?;

  final width = _toDouble(style['width']);
  final height = _toDouble(style['height']);
  final bgColor = _parseColor(style['color'] ?? style['backgroundColor']);
  final borderRadius = _toDouble(style['borderRadius']);
  final opacity = _toDouble(style['opacity']);
  final padding = _parsePadding(style);
  final margin = _parseMargin(style);
  final alignment = _parseAlignment(style['alignment']);

  Widget child;
  if (children != null && children.isNotEmpty) {
    final hasPositioned = children.any(_isPositionedLike);
    if (children.length == 1 && !hasPositioned) {
      child = children.first;
    } else if (hasPositioned) {
      // P-032 / Stack: multiple non-positioned children must not share one Stack slot
      // (they would all align to topLeft and overlap). Column them, then overlay Positioned.
      final nonPositioned = <Widget>[];
      final positioned = <Widget>[];
      for (final w in children) {
        if (_isPositionedLike(w)) {
          positioned.add(w);
        } else {
          nonPositioned.add(w);
        }
      }
      late final Widget stackBase;
      if (nonPositioned.isEmpty) {
        stackBase = const SizedBox.shrink();
      } else if (nonPositioned.length == 1) {
        stackBase = nonPositioned.first;
      } else {
        stackBase = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: nonPositioned,
        );
      }
      child = Stack(
        clipBehavior: Clip.none,
        alignment: alignment ?? Alignment.topLeft,
        children: [
          stackBase,
          ...positioned,
        ],
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
  } else {
    child = const SizedBox.shrink();
  }

  Widget result = Container(
    width: width == -1 ? double.infinity : width,
    height: height == -1 ? double.infinity : height,
    padding: padding,
    margin: margin,
    alignment: _alignmentWhenSized(alignment, width, height),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius:
          borderRadius != null ? BorderRadius.circular(borderRadius) : null,
    ),
    clipBehavior: style['clipBehavior'] == 'antiAlias'
        ? Clip.antiAlias
        : style['clipBehavior'] == 'hardEdge'
            ? Clip.hardEdge
            : Clip.none,
    child: child,
  );

  final rotation = _toDouble(style['rotation']);
  if (rotation != null && rotation != 0) {
    result = Transform.rotate(angle: rotation, child: result);
  }

  final translateX = _toDouble(style['translateX']) ?? 0.0;
  final translateY = _toDouble(style['translateY']) ?? 0.0;
  if (translateX != 0 || translateY != 0) {
    result = Transform.translate(
        offset: Offset(translateX, translateY), child: result);
  }

  if (opacity != null && opacity < 1.0) {
    result = Opacity(opacity: opacity.clamp(0.0, 1.0), child: result);
  }

  if (pointerEvents == 'none') {
    result = IgnorePointer(ignoring: true, child: result);
  }
  // box-none: no wrapper needed (default behavior)

  if (style['positioned'] == true) {
    final hasPercentTop = _isPercent(style['top']);
    final hasPercentLeft = _isPercent(style['left']);
    if (hasPercentTop || hasPercentLeft) {
      final pctY = hasPercentTop ? _parsePercent(style['top']) : null;
      final pctX = hasPercentLeft ? _parsePercent(style['left']) : null;
      final alignX = pctX != null ? (pctX / 50.0) - 1.0 : -1.0;
      final alignY = pctY != null ? (pctY / 50.0) - 1.0 : -1.0;
      return Align(alignment: Alignment(alignX, alignY), child: result);
    }
    final l = _toDouble(style['left']);
    final r = _toDouble(style['right']);
    final t = _toDouble(style['top']);
    final b = _toDouble(style['bottom']);
    final cv = style['centerVertical'] == true;
    final ch = style['centerHorizontal'] == true;
    if (cv || ch) {
      final Alignment align;
      if (cv && ch) {
        align = Alignment.center;
      } else if (cv && !ch) {
        if (l != null && r == null) {
          align = Alignment.centerLeft;
        } else if (r != null && l == null) {
          align = Alignment.centerRight;
        } else {
          align = Alignment.center;
        }
      } else {
        if (t != null && b == null) {
          align = Alignment.topCenter;
        } else if (b != null && t == null) {
          align = Alignment.bottomCenter;
        } else {
          align = Alignment.topCenter;
        }
      }
      return Positioned.fill(
        child: Align(
          alignment: align,
          child: Padding(
            padding: EdgeInsets.only(
              left: l ?? 0,
              right: r ?? 0,
              top: t ?? 0,
              bottom: b ?? 0,
            ),
            child: result,
          ),
        ),
      );
    }
    if (l == null && r == null && t == null && b == null) {
      return Align(alignment: Alignment.center, child: result);
    }
    return Positioned(left: l, right: r, top: t, bottom: b, child: result);
  }

  // flex in schema is ignored: Expanded/SizedBox.expand fail when the container
  // is a Stack child (unconstrained). Container sizes to its child instead.
  return result;
}

Widget _buildSafeArea(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final style = _safeMap(props['style']);
  final pointerEvents =
      props['pointerEvents'] as String? ?? style['pointerEvents'] as String?;

  Widget child;
  if (children != null && children.isNotEmpty) {
    if (children.length == 1) {
      child = children.first;
    } else {
      child = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children);
    }
  } else {
    child = const SizedBox.shrink();
  }

  final bgColor = _parseColor(style['color'] ?? style['backgroundColor']);
  final positioned = style['positioned'] == true;
  final alignment = _parseAlignment(style['alignment']);
  final topOffset = _toDouble(style['top']);
  final saWidth = _toDouble(style['width']);
  final saHeight = _toDouble(style['height']);

  Widget result = SafeArea(
    child: Container(
      color: bgColor,
      width: saWidth == -1 ? double.infinity : saWidth,
      height: saHeight == -1 ? double.infinity : saHeight,
      alignment: _alignmentWhenSized(alignment, saWidth, saHeight),
      transform: topOffset != null && topOffset != 0
          ? Matrix4.translationValues(0, topOffset, 0)
          : null,
      child: child,
    ),
  );

  if (pointerEvents == 'none') {
    result = IgnorePointer(ignoring: true, child: result);
  }

  // sideTab: containerStyle has translateX/translateY for edge alignment
  final translateX = _toDouble(style['translateX']) ?? 0.0;
  final translateY = _toDouble(style['translateY']) ?? 0.0;
  if (translateX != 0 || translateY != 0) {
    result = Transform.translate(
        offset: Offset(translateX, translateY), child: result);
  }
  // box-none: no wrapper needed (default behavior)

  if (positioned) {
    final cv = style['centerVertical'] == true;
    final ch = style['centerHorizontal'] == true;
    final w = _toDouble(style['width']);
    final h = _toDouble(style['height']);
    final l = _toDouble(style['left']);
    final r = _toDouble(style['right']);
    final t = _toDouble(style['top']);
    final b = _toDouble(style['bottom']);

    if (cv || ch) {
      final Alignment align;
      if (cv && ch) {
        align = Alignment.center;
      } else if (cv && !ch) {
        if (l != null && r == null) {
          align = Alignment.centerLeft;
        } else if (r != null && l == null) {
          align = Alignment.centerRight;
        } else {
          align = Alignment.center;
        }
      } else {
        if (t != null && b == null) {
          align = Alignment.topCenter;
        } else if (b != null && t == null) {
          align = Alignment.bottomCenter;
        } else {
          align = Alignment.topCenter;
        }
      }
      return Positioned.fill(
        child: Align(
          alignment: align,
          child: Padding(
            padding: EdgeInsets.only(
              left: l ?? 0,
              right: r ?? 0,
              top: t ?? 0,
              bottom: b ?? 0,
            ),
            child: result,
          ),
        ),
      );
    }

    // When no explicit size, use position values (e.g. bottom/right for bottom_right).
    if ((w == 0 || w == null) && (h == 0 || h == null)) {
      if (l == null && r == null && t == null && b == null) {
        return Positioned(left: 0, top: 0, child: result);
      }
      return Positioned(left: l, right: r, top: t, bottom: b, child: result);
    }
    return Positioned.fill(child: result);
  }

  return result;
}

Widget _buildGestureDetector(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final onTap = props['onTap'] as Function?;
  final onPress = props['onPress'] as Function?;
  final onLayout = props['onLayout'] as void Function(dynamic)?;
  final style = _safeMap(props['style']);

  final bgColor = _parseColor(style['color'] ?? style['backgroundColor']);
  final width = _toDouble(style['width']);
  final height = _toDouble(style['height']);
  final borderRadius = _toDouble(style['borderRadius']);
  // Expo/backend use borderTopLeftRadius; older Flutter style blobs used borderRadiusTopLeft — accept both.
  final borderTopLeftRadius = _toDouble(style['borderTopLeftRadius']) ??
      _toDouble(style['borderRadiusTopLeft']);
  final borderTopRightRadius = _toDouble(style['borderTopRightRadius']) ??
      _toDouble(style['borderRadiusTopRight']);
  final padding = _parsePadding(style);
  final margin = _parseMargin(style);
  final alignment = _parseAlignment(style['alignment']);
  final rotation = _toDouble(style['rotation']);
  final gap = _toDouble(style['gap']);
  final elevation = _toDouble(style['elevation']);

  Widget child;
  if (children != null && children.isNotEmpty) {
    if (gap != null && gap > 0) {
      final spaced = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        spaced.add(children[i]);
        if (i < children.length - 1) spaced.add(SizedBox(width: gap));
      }
      child = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: spaced);
    } else if (style['flexDirection'] == 'row') {
      child = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children);
    } else if (children.length == 1) {
      child = children.first;
    } else {
      child = Column(mainAxisSize: MainAxisSize.min, children: children);
    }
  } else {
    child = const SizedBox.shrink();
  }

  BorderRadius? br;
  if (borderRadius != null) {
    br = BorderRadius.circular(borderRadius);
  } else if (borderTopLeftRadius != null || borderTopRightRadius != null) {
    br = BorderRadius.only(
      topLeft: Radius.circular(borderTopLeftRadius ?? 0),
      topRight: Radius.circular(borderTopRightRadius ?? 0),
    );
  }

  final shadowColor = _parseColor(style['shadowColor']);
  final shadowBlurRadius = _toDouble(style['shadowBlurRadius']) ?? 0;
  final shadowOffsetY = _toDouble(style['shadowOffsetY']) ?? 0;
  final shadowOpacity = _toDouble(style['shadowOpacity']) ?? 1.0;

  final hasRotation = rotation != null && rotation != 0;

  Widget result = GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap != null
        ? () => onTap()
        : onPress != null
            ? () => onPress()
            : null,
    child: Container(
      width: width == -1 ? double.infinity : width,
      height: height == -1 ? double.infinity : height,
      padding: padding,
      margin: margin,
      alignment: _alignmentWhenSized(alignment, width, height),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: br,
        boxShadow: (elevation != null && elevation > 0) || shadowColor != null
            ? [
                BoxShadow(
                  color: (shadowColor ?? Colors.black)
                      .withValues(alpha: shadowOpacity),
                  blurRadius: shadowBlurRadius,
                  offset: Offset(0, shadowOffsetY),
                ),
              ]
            : null,
      ),
      child: child,
    ),
  );

  // Measure pre-rotation size so sideTabButtonWidth reports the pre-rotation width.
  if (onLayout != null) {
    result = _MeasureSize(onLayout: onLayout, child: result);
  }

  if (hasRotation) {
    // RotatedBox updates the layout dimensions (unlike Transform.rotate which
    // doesn't), so the hit area correctly covers the rotated visual extent.
    final quarterTurns = (rotation * 2 / math.pi).round();
    result = RotatedBox(quarterTurns: quarterTurns, child: result);
  }

  if (style['positioned'] == true) {
    return Positioned(
      left: _toDouble(style['left']),
      right: _toDouble(style['right']),
      top: _toDouble(style['top']),
      bottom: _toDouble(style['bottom']),
      child: result,
    );
  }

  return result;
}

Widget _buildText(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final style = _safeMap(props['style']);
  final textContent = content ?? '';

  return Text(
    textContent,
    style: TextStyle(
      color: _parseColor(style['color']),
      fontSize: _toDouble(style['fontSize']),
      fontWeight: _parseFontWeight(style['fontWeight']),
      height: _toDouble(style['lineHeight']) != null
          ? _toDouble(style['lineHeight'])! /
              (_toDouble(style['fontSize']) ?? 14.0)
          : null,
    ),
  );
}

Widget _buildImage(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final style = _safeMap(props['style']);
  final source = props['source'] is Map ? _safeMap(props['source']) : null;
  final uriRaw = source?['uri'];
  final String? uri = uriRaw == null
      ? null
      : uriRaw is String
          ? uriRaw
          : uriRaw.toString();

  if (uri == null || uri.isEmpty) {
    return const SizedBox.shrink();
  }

  final width = _toDouble(style['width']);
  final height = _toDouble(style['height']);
  final borderRadius = _toDouble(style['borderRadius']);
  final margin = _parseMargin(style);

  Widget image = CachedNetworkImage(
    imageUrl: uri,
    width: width,
    height: height,
    fit: BoxFit.cover,
    errorWidget: (_, url, error) {
      return const SizedBox.shrink();
    },
  );

  if (borderRadius != null) {
    image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius), child: image);
  }

  if (margin != null) {
    image = Padding(padding: margin, child: image);
  }

  return image;
}

Widget _buildSvgPicture(Map<String, dynamic> props, List<Widget>? children,
    {String? content}) {
  final xml = props['xml'] as String?;
  final width = _toDouble(props['width']);
  final height = _toDouble(props['height']);

  if (xml == null || xml.isEmpty) return const SizedBox.shrink();

  return SvgPicture.string(
    xml,
    width: width,
    height: height,
  );
}

// --- Utility functions ---

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.endsWith('%')) return null;
    return double.tryParse(value);
  }
  return null;
}

bool _isPercent(dynamic value) => value is String && value.endsWith('%');

double _parsePercent(dynamic value) {
  final s = (value as String).replaceAll('%', '');
  return double.tryParse(s) ?? 0;
}

Color? _parseColor(dynamic value) {
  if (value == null) return null;
  if (value is! String) return null;

  final str = value.trim();
  if (str.startsWith('rgba(')) {
    final inner = str.substring(5, str.length - 1);
    final parts = inner.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 4) {
      return Color.fromRGBO(
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 0,
        int.tryParse(parts[2]) ?? 0,
        double.tryParse(parts[3]) ?? 1.0,
      );
    }
  }

  if (str.startsWith('#')) {
    final hex = str.substring(1);
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    if (hex.length == 3) {
      final full = hex.split('').map((c) => '$c$c').join('');
      return Color(int.parse('FF$full', radix: 16));
    }
  }

  final named = {
    'white': Colors.white,
    'black': Colors.black,
    'transparent': Colors.transparent,
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
  };
  return named[str.toLowerCase()];
}

FontWeight? _parseFontWeight(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  switch (str) {
    case '100':
      return FontWeight.w100;
    case '200':
      return FontWeight.w200;
    case '300':
      return FontWeight.w300;
    case '400':
    case 'normal':
      return FontWeight.w400;
    case '500':
      return FontWeight.w500;
    case '600':
      return FontWeight.w600;
    case '700':
    case 'bold':
      return FontWeight.w700;
    case '800':
      return FontWeight.w800;
    case '900':
      return FontWeight.w900;
    default:
      return null;
  }
}

Alignment? _parseAlignment(dynamic value) {
  if (value == null) return null;
  switch (value.toString()) {
    case 'center':
      return Alignment.center;
    case 'topCenter':
      return Alignment.topCenter;
    case 'bottomCenter':
      return Alignment.bottomCenter;
    case 'centerLeft':
      return Alignment.centerLeft;
    case 'centerRight':
      return Alignment.centerRight;
    case 'topLeft':
      return Alignment.topLeft;
    case 'topRight':
      return Alignment.topRight;
    case 'bottomLeft':
      return Alignment.bottomLeft;
    case 'bottomRight':
      return Alignment.bottomRight;
    default:
      return null;
  }
}

EdgeInsets? _parsePadding(Map style) {
  final pt = _toDouble(style['paddingTop']) ??
      _toDouble(style['paddingVertical']) ??
      0;
  final pb = _toDouble(style['paddingBottom']) ??
      _toDouble(style['paddingVertical']) ??
      0;
  final pl = _toDouble(style['paddingLeft']) ??
      _toDouble(style['paddingHorizontal']) ??
      0;
  final pr = _toDouble(style['paddingRight']) ??
      _toDouble(style['paddingHorizontal']) ??
      0;
  if (pt == 0 && pb == 0 && pl == 0 && pr == 0) return null;
  return EdgeInsets.fromLTRB(pl, pt, pr, pb);
}

EdgeInsets? _parseMargin(Map style) {
  final mt =
      _toDouble(style['marginTop']) ?? _toDouble(style['marginVertical']) ?? 0;
  final mb = _toDouble(style['marginBottom']) ??
      _toDouble(style['marginVertical']) ??
      0;
  final ml = _toDouble(style['marginLeft']) ??
      _toDouble(style['marginHorizontal']) ??
      0;
  final mr = _toDouble(style['marginRight']) ??
      _toDouble(style['marginHorizontal']) ??
      0;
  if (mt == 0 && mb == 0 && ml == 0 && mr == 0) return null;
  return EdgeInsets.fromLTRB(ml, mt, mr, mb);
}
