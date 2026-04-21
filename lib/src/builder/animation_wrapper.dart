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

class _ExitTargetSnapshot {
  final double toOpacity;
  final double toTX;
  final double toTY;
  final double toScale;
  final Alignment alignment;

  const _ExitTargetSnapshot({
    required this.toOpacity,
    required this.toTX,
    required this.toTY,
    required this.toScale,
    required this.alignment,
  });
}

class _EnterEndpointSnapshot {
  final double fromOpacity;
  final double fromTX;
  final double fromTY;
  final double fromScale;
  final double toOpacity;
  final double toTX;
  final double toTY;
  final double toScale;
  final Alignment alignment;

  const _EnterEndpointSnapshot({
    required this.fromOpacity,
    required this.fromTX,
    required this.fromTY,
    required this.fromScale,
    required this.toOpacity,
    required this.toTX,
    required this.toTY,
    required this.toScale,
    required this.alignment,
  });
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

  _ExitTargetSnapshot? _exitSnapshot;
  _EnterEndpointSnapshot? _enterSnapshot;

  final ValueNotifier<int> _manualTick = ValueNotifier<int>(0);

  Alignment _alignEnter = Alignment.center;
  Alignment _alignExit = Alignment.center;

  Listenable get _animationListenable {
    final e = _enterController;
    final x = _exitController;
    if (e != null && x != null) {
      return Listenable.merge(<Listenable>[e, x, _manualTick]);
    }
    if (e != null) {
      return Listenable.merge(<Listenable>[e, _manualTick]);
    }
    if (x != null) {
      return Listenable.merge(<Listenable>[x, _manualTick]);
    }
    return _manualTick;
  }

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

    _checkEnterTrigger();
  }

  void _checkEnterTrigger() {
    final enterConfig = _safeMapOrNull(widget.animation['enter']);
    if (enterConfig == null || _enterController == null) return;

    final trigger = enterConfig['trigger'];
    final shouldAnimate =
        trigger != null ? evaluateCondition(trigger, widget.context) : true;

    if (shouldAnimate && !_hasTriggeredEnter) {
      _enterSnapshot = _buildEnterSnapshot(enterConfig);
      _hasTriggeredEnter = true;

      _enterController!.reset();
      _enterController!.forward();
    } else if (!shouldAnimate) {
      _hasTriggeredEnter = false;
      _enterSnapshot = null;
    }
  }

  _EnterEndpointSnapshot _buildEnterSnapshot(Map<String, dynamic> enterConfig) {
    final to = _safeMapOrNull(enterConfig['to']);
    final fromMap = _safeMapOrNull(enterConfig['from']);
    final align = _resolveTransformOrigin(
          enterConfig['transformOrigin'],
          widget.context,
        ) ??
        _alignEnter;
    return _EnterEndpointSnapshot(
      fromOpacity: _resolveNum(fromMap?['opacity'], widget.context) ?? 0.0,
      fromTX: _resolveNum(fromMap?['translateX'], widget.context) ?? 0.0,
      fromTY: _resolveNum(fromMap?['translateY'], widget.context) ?? 0.0,
      fromScale: _resolveNum(fromMap?['scale'], widget.context) ?? 1.0,
      toOpacity: _resolveNum(to?['opacity'], widget.context) ?? 1.0,
      toTX: _resolveNum(to?['translateX'], widget.context) ?? 0.0,
      toTY: _resolveNum(to?['translateY'], widget.context) ?? 0.0,
      toScale: _resolveNum(to?['scale'], widget.context) ?? 1.0,
      alignment: align,
    );
  }

  void _setupExitAnimation() {
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    if (exitConfig == null) return;

    final duration = (exitConfig['duration'] as num?)?.toInt() ?? 300;
    _exitController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

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

  _ExitTargetSnapshot _buildExitSnapshot(Map<String, dynamic> exitConfig) {
    final to = _safeMapOrNull(exitConfig['to']);
    final align = _resolveTransformOrigin(
          exitConfig['transformOrigin'],
          widget.context,
        ) ??
        _alignExit;
    return _ExitTargetSnapshot(
      toOpacity: _resolveNum(to?['opacity'], widget.context) ?? 0.0,
      toTX: _resolveNum(to?['translateX'], widget.context) ?? 0.0,
      toTY: _resolveNum(to?['translateY'], widget.context) ?? 0.0,
      toScale: _resolveNum(to?['scale'], widget.context) ?? 1.0,
      alignment: align,
    );
  }

  void _snapExitIfInterrupted() {
    final c = _exitController;
    if (c == null) return;
    final v = c.value;
    if (v <= 0 || v >= 1.0) return;
    c.reset();
    _exitSnapshot = null;
    _manualTick.value++;
  }

  bool _shouldHoldExitPoseDuringTeardown() {
    final exitC = _exitController;
    if (exitC == null || _exitSnapshot == null) return false;
    if (_shouldExitTrigger()) return false;
    final show = widget.context.state?['showSpotCheck'];
    if (show == true) return false;
    final v = exitC.value;
    final completed =
        exitC.status == AnimationStatus.completed && v >= 1.0;
    final midFlight = v > 0.0 && v < 1.0;
    final running =
        exitC.isAnimating || exitC.status == AnimationStatus.forward;
    return completed || midFlight || running;
  }

  void _checkExitTrigger() {
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    if (exitConfig == null || _exitController == null) return;

    final trigger = exitConfig['trigger'];
    final shouldExit =
        trigger != null ? evaluateCondition(trigger, widget.context) : false;

    if (_prevExitTrigger && !shouldExit) {
      final show = widget.context.state?['showSpotCheck'];
      if (show == true) {
        _snapExitIfInterrupted();
      }
    }

    if (shouldExit && !_prevExitTrigger) {
      _exitSnapshot = _buildExitSnapshot(exitConfig);
      _exitController!.reset();
      _exitController!.forward();
    }

    if (!shouldExit) {
      if (!_shouldHoldExitPoseDuringTeardown()) {
        _exitSnapshot = null;
      }
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

  bool _shouldExitTrigger() {
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    if (exitConfig == null) return false;
    final trigger = exitConfig['trigger'];
    if (trigger == null) return false;
    return evaluateCondition(trigger, widget.context);
  }

  bool _shouldEnterTrigger() {
    final enterConfig = _safeMapOrNull(widget.animation['enter']);
    if (enterConfig == null) return false;
    final trigger = enterConfig['trigger'];
    if (trigger == null) return true;
    return evaluateCondition(trigger, widget.context);
  }

  _AnimValues _computeAnimatedValues() {
    final enterConfig = _safeMapOrNull(widget.animation['enter']);
    final exitConfig = _safeMapOrNull(widget.animation['exit']);
    final enterC = _enterController;
    final exitC = _exitController;

    final shouldExit = _shouldExitTrigger();
    final shouldEnter = _shouldEnterTrigger();

    final holdExitFinalFrame = _shouldHoldExitPoseDuringTeardown();

    final exitMotionActive = shouldExit &&
        exitC != null &&
        (exitC.isAnimating ||
            exitC.status == AnimationStatus.forward ||
            (exitC.status == AnimationStatus.completed && exitC.value >= 1.0));

    final enterMotionActive = shouldEnter &&
        enterC != null &&
        (enterC.isAnimating ||
            enterC.status == AnimationStatus.forward ||
            (enterC.status == AnimationStatus.completed &&
                enterC.value >= 1.0 &&
                _hasTriggeredEnter));

    if (exitConfig != null &&
        exitC != null &&
        (exitMotionActive || holdExitFinalFrame)) {
      final snap = _exitSnapshot;
      final t = holdExitFinalFrame && !shouldExit
          ? 1.0
          : _getCurve(exitConfig['easing'])
              .transform(exitC.value.clamp(0.0, 1.0));
      if (snap != null) {
        return _AnimValues(
          opacity: 1.0 + (snap.toOpacity - 1.0) * t,
          translateX: snap.toTX * t,
          translateY: snap.toTY * t,
          scale: 1.0 + (snap.toScale - 1.0) * t,
          alignment: snap.alignment,
        );
      }
      final to = _safeMapOrNull(exitConfig['to']);
      final toOpacity = _resolveNum(to?['opacity'], widget.context) ?? 0.0;
      final toTY = _resolveNum(to?['translateY'], widget.context) ?? 0.0;
      final toTX = _resolveNum(to?['translateX'], widget.context) ?? 0.0;
      final toScale = _resolveNum(to?['scale'], widget.context) ?? 1.0;
      return _AnimValues(
        opacity: 1.0 + (toOpacity - 1.0) * t,
        translateX: toTX * t,
        translateY: toTY * t,
        scale: 1.0 + (toScale - 1.0) * t,
        alignment: _alignExit,
      );
    }

    if (enterConfig != null && enterC != null && enterMotionActive) {
      final snap = _enterSnapshot;
      final t = _getCurve(enterConfig['easing'])
          .transform(enterC.value.clamp(0.0, 1.0));
      if (snap != null) {
        return _AnimValues(
          opacity: snap.fromOpacity + (snap.toOpacity - snap.fromOpacity) * t,
          translateY: snap.fromTY + (snap.toTY - snap.fromTY) * t,
          translateX: snap.fromTX + (snap.toTX - snap.fromTX) * t,
          scale: snap.fromScale + (snap.toScale - snap.fromScale) * t,
          alignment: snap.alignment,
        );
      }
      final to = _safeMapOrNull(enterConfig['to']);
      final fromMap = _safeMapOrNull(enterConfig['from']);
      final fromOpacity =
          _resolveNum(fromMap?['opacity'], widget.context) ?? 0.0;
      final toOpacity = _resolveNum(to?['opacity'], widget.context) ?? 1.0;
      final fromTY = _resolveNum(fromMap?['translateY'], widget.context) ?? 0.0;
      final toTY = _resolveNum(to?['translateY'], widget.context) ?? 0.0;
      final fromTX = _resolveNum(fromMap?['translateX'], widget.context) ?? 0.0;
      final toTX = _resolveNum(to?['translateX'], widget.context) ?? 0.0;
      final fromScale = _resolveNum(fromMap?['scale'], widget.context) ?? 1.0;
      final toScale = _resolveNum(to?['scale'], widget.context) ?? 1.0;
      return _AnimValues(
        opacity: fromOpacity + (toOpacity - fromOpacity) * t,
        translateY: fromTY + (toTY - fromTY) * t,
        translateX: fromTX + (toTX - fromTX) * t,
        scale: fromScale + (toScale - fromScale) * t,
        alignment: _alignEnter,
      );
    }

    final enterCfg = _safeMapOrNull(widget.animation['enter']);
    if (enterCfg != null) {
      final from = _safeMapOrNull(enterCfg['from']);
      if (from != null && !_hasTriggeredEnter) {
        return _AnimValues(
          opacity: _resolveNum(from['opacity'], widget.context) ?? 1.0,
          translateY: _resolveNum(from['translateY'], widget.context) ?? 0.0,
          translateX: _resolveNum(from['translateX'], widget.context) ?? 0.0,
          scale: _resolveNum(from['scale'], widget.context) ?? 1.0,
          alignment: _alignEnter,
        );
      }
    }

    return _AnimValues.identity(alignment: _alignEnter);
  }

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
    _manualTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationListenable,
      builder: (context, child) {
        final v = _computeAnimatedValues();
        final o = v.opacity.clamp(0.0, 1.0);
        final content = child ?? const SizedBox.shrink();
        final scaled = Transform.scale(
          alignment: v.alignment,
          scale: v.scale.clamp(0.01, 10.0),
          child: o >= 0.999 ? content : Opacity(opacity: o, child: content),
        );
        return Transform.translate(
          offset: Offset(v.translateX, v.translateY),
          child: scaled,
        );
      },
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _AnimValues {
  final double opacity;
  final double translateX;
  final double translateY;
  final double scale;
  final Alignment alignment;

  const _AnimValues({
    required this.opacity,
    required this.translateX,
    required this.translateY,
    required this.scale,
    required this.alignment,
  });

  factory _AnimValues.identity({Alignment alignment = Alignment.center}) {
    return _AnimValues(
      opacity: 1.0,
      translateX: 0.0,
      translateY: 0.0,
      scale: 1.0,
      alignment: alignment,
    );
  }
}
