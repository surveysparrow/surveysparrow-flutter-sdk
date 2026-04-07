import 'package:flutter/material.dart';
import 'builder.dart';

Map<String, dynamic>? _safeMapOrNull(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), v is Map ? _safeMapOrNull(v) ?? {} : v),
    );
  }
  return null;
}

class AnimationWrapper extends StatefulWidget {
  final Map<String, dynamic> animation;
  final BuilderContext context;
  final Widget child;

  const AnimationWrapper({
    super.key,
    required this.animation,
    required this.context,
    required this.child,
  });

  @override
  State<AnimationWrapper> createState() => _AnimationWrapperState();
}

class _AnimationWrapperState extends State<AnimationWrapper>
    with TickerProviderStateMixin {
  AnimationController? _enterController;
  AnimationController? _exitController;
  bool _prevExitTrigger = false;
  bool _hasTriggeredEnter = false;

  double _opacity = 1.0;
  double _translateX = 0.0;
  double _translateY = 0.0;
  double _scale = 1.0;

  /// RN `transformOrigin` → [Transform.scale] alignment (Expo parity: center card uses `100% 100%`).
  Alignment _alignEnter = Alignment.center;
  Alignment _alignExit = Alignment.center;

  @override
  void initState() {
    super.initState();
    _syncScaleAlignments();
    _setupEnterAnimation();
    _setupExitAnimation();
  }

  @override
  void didUpdateWidget(AnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.context.state != widget.context.state) {
      _syncScaleAlignments();
    }
    _checkEnterTrigger();
    _checkExitTrigger();
  }

  void _syncScaleAlignments() {
    final enter = _safeMapOrNull(widget.animation['enter']);
    final exit = _safeMapOrNull(widget.animation['exit']);
    _alignEnter =
        _resolveTransformOrigin(enter?['transformOrigin'], widget.context) ??
            Alignment.center;
    _alignExit =
        _resolveTransformOrigin(exit?['transformOrigin'], widget.context) ??
            Alignment.center;
  }

  void _setupEnterAnimation() {
    final enterConfig = _safeMapOrNull(widget.animation['enter']);
    if (enterConfig == null) return;

    final duration = (enterConfig['duration'] as num?)?.toInt() ?? 300;
    _enterController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    final trigger = enterConfig['trigger'];
    final shouldAnimate =
        trigger != null ? evaluateCondition(trigger, widget.context) : true;

    if (shouldAnimate) {
      final from = _safeMapOrNull(enterConfig['from']);
      if (from != null) {
        _opacity = _resolveNum(from['opacity'], widget.context) ?? 0.0;
        _translateY = _resolveNum(from['translateY'], widget.context) ?? 0.0;
        _translateX = _resolveNum(from['translateX'], widget.context) ?? 0.0;
        _scale = _resolveNum(from['scale'], widget.context) ?? 1.0;
      }
    }

    _enterController!.addListener(() {
      if (!mounted) return;
      final to = _safeMapOrNull(enterConfig['to']);
      final fromMap = _safeMapOrNull(enterConfig['from']);
      final t =
          _getCurve(enterConfig['easing']).transform(_enterController!.value);

      setState(() {
        final fromOpacity =
            _resolveNum(fromMap?['opacity'], widget.context) ?? 0.0;
        final toOpacity = (to?['opacity'] as num?)?.toDouble() ?? 1.0;
        _opacity = fromOpacity + (toOpacity - fromOpacity) * t;

        final fromTY =
            _resolveNum(fromMap?['translateY'], widget.context) ?? 0.0;
        final toTY = (to?['translateY'] as num?)?.toDouble() ?? 0.0;
        _translateY = fromTY + (toTY - fromTY) * t;

        final fromTX =
            _resolveNum(fromMap?['translateX'], widget.context) ?? 0.0;
        final toTX = (to?['translateX'] as num?)?.toDouble() ?? 0.0;
        _translateX = fromTX + (toTX - fromTX) * t;

        final fromScale = _resolveNum(fromMap?['scale'], widget.context) ?? 1.0;
        final toScale = (to?['scale'] as num?)?.toDouble() ?? 1.0;
        _scale = fromScale + (toScale - fromScale) * t;
      });
    });

    _checkEnterTrigger();
  }

  void _checkEnterTrigger() {
    final enterConfig = _safeMapOrNull(widget.animation['enter']);
    if (enterConfig == null || _enterController == null) return;

    final trigger = enterConfig['trigger'];
    final shouldAnimate =
        trigger != null ? evaluateCondition(trigger, widget.context) : true;

    if (shouldAnimate && !_hasTriggeredEnter) {
      _hasTriggeredEnter = true;

      final from = _safeMapOrNull(enterConfig['from']);
      if (from != null) {
        _opacity = _resolveNum(from['opacity'], widget.context) ?? 0.0;
        _translateY = _resolveNum(from['translateY'], widget.context) ?? 0.0;
        _translateX = _resolveNum(from['translateX'], widget.context) ?? 0.0;
        _scale = _resolveNum(from['scale'], widget.context) ?? 1.0;
      }

      _enterController!.reset();
      _enterController!.forward();
    } else if (!shouldAnimate) {
      _hasTriggeredEnter = false;
    }
  }

  void _setupExitAnimation() {
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    if (exitConfig == null) return;

    final duration = (exitConfig['duration'] as num?)?.toInt() ?? 300;
    _exitController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _exitController!.addListener(() {
      if (!mounted) return;
      final to = _safeMapOrNull(exitConfig['to']);
      final t =
          _getCurve(exitConfig['easing']).transform(_exitController!.value);

      setState(() {
        final toOpacity = _resolveNum(to?['opacity'], widget.context) ?? 0.0;
        _opacity = 1.0 + (toOpacity - 1.0) * t;

        final toTY = _resolveNum(to?['translateY'], widget.context) ?? 0.0;
        _translateY = toTY * t;

        final toTX = _resolveNum(to?['translateX'], widget.context) ?? 0.0;
        _translateX = toTX * t;

        final toScale = _resolveNum(to?['scale'], widget.context) ?? 1.0;
        _scale = 1.0 + (toScale - 1.0) * t;
      });
    });

    _exitController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final onComplete = exitConfig['onComplete'] as String?;
        if (onComplete != null && widget.context.handlers != null) {
          final handler = widget.context.handlers!['executeFunction'];
          if (handler != null) {
            handler(onComplete);
          }
        }
      }
    });

    _checkExitTrigger();
  }

  /// When exit is cancelled (e.g. [spotCheckDetails.isExiting] cleared by trackScreen)
  /// mid-animation, snap back so the next show does not flash exit frames.
  void _snapExitIfInterrupted() {
    final c = _exitController;
    if (c == null) return;
    final v = c.value;
    if (v <= 0 || v >= 1.0) return;
    c.reset();
    setState(() {
      _opacity = 1.0;
      _translateX = 0.0;
      _translateY = 0.0;
      _scale = 1.0;
    });
  }

  void _checkExitTrigger() {
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    if (exitConfig == null || _exitController == null) return;

    final trigger = exitConfig['trigger'];
    final shouldExit =
        trigger != null ? evaluateCondition(trigger, widget.context) : false;

    if (_prevExitTrigger && !shouldExit) {
      _snapExitIfInterrupted();
    }

    if (shouldExit && !_prevExitTrigger) {
      _exitController!.reset();
      _exitController!.forward();
    }

    _prevExitTrigger = shouldExit;
  }

  double? _resolveNum(dynamic value, BuilderContext ctx) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is Map) {
      final m = _safeMapOrNull(value);
      if (m != null && m.containsKey('\$expr')) {
        final result = evaluateExpression(m['\$expr'] as String, ctx);
        if (result is num) return result.toDouble();
      }
    }
    return null;
  }

  /// Parses CSS-style origins e.g. `100% 100%` (maps to [Alignment.bottomRight]).
  Alignment? _resolveTransformOrigin(dynamic raw, BuilderContext ctx) {
    if (raw == null) return null;
    if (raw is String) return _parseTransformOriginString(raw);
    if (raw is Map && raw.containsKey('\$expr')) {
      final r = evaluateExpression(raw['\$expr'] as String, ctx);
      if (r is String) return _parseTransformOriginString(r);
    }
    return null;
  }

  static Alignment? _parseTransformOriginString(String s) {
    final m =
        RegExp(r'(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%').firstMatch(s.trim());
    if (m == null) return null;
    final xPct = double.tryParse(m.group(1)!) ?? 50;
    final yPct = double.tryParse(m.group(2)!) ?? 50;
    final x = 2.0 * (xPct / 100.0) - 1.0;
    final y = 2.0 * (yPct / 100.0) - 1.0;
    return Alignment(x, y);
  }

  Curve _getCurve(dynamic easing) {
    switch (easing?.toString()) {
      case 'linear':
        return Curves.linear;
      case 'ease':
        return Curves.ease;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
      case 'easeInEaseOut':
        return Curves.easeInOut;
      default:
        return Curves.easeOut;
    }
  }

  @override
  void dispose() {
    _enterController?.dispose();
    _exitController?.dispose();
    super.dispose();
  }

  Alignment get _activeScaleAlignment {
    final exitAnim = _exitController?.isAnimating ?? false;
    final enterAnim = _enterController?.isAnimating ?? false;
    if (exitAnim) return _alignExit;
    if (enterAnim) return _alignEnter;
    return _alignEnter;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_translateX, _translateY),
      child: Transform.scale(
        alignment: _activeScaleAlignment,
        scale: _scale.clamp(0.01, 10.0),
        child: Opacity(
          opacity: _opacity.clamp(0.0, 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}
