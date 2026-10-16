import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../state/spotcheck_state.dart';

class WrapperScrollCoordinator extends StatefulWidget {
  const WrapperScrollCoordinator({
    super.key,
    required this.store,
    required this.child,
  });

  final SpotcheckStore store;
  final Widget child;

  @override
  State<WrapperScrollCoordinator> createState() =>
      _WrapperScrollCoordinatorState();
}

class _WrapperScrollCoordinatorState extends State<WrapperScrollCoordinator>
    with WidgetsBindingObserver {
  double _lastTextPositionForScroll = double.negativeInfinity;
  double _lastKeyboardHeight = 0;
  Timer? _keyboardSettle;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _keyboardSettle?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  // Metrics change every frame while the keyboard animates; scroll once it settles (legacy got only the final height).
  @override
  void didChangeMetrics() {
    final kb = _keyboardHeight();
    if (kb == _lastKeyboardHeight) return;
    _lastKeyboardHeight = kb;
    _keyboardSettle?.cancel();
    _keyboardSettle = Timer(const Duration(milliseconds: 150), () {
      _keyboardSettle = null;
      if (!mounted) return;
      _applyLegacyWrapperScroll();
    });
  }

  double _keyboardHeight() {
    final view = PlatformDispatcher.instance.views.first;
    return MediaQueryData.fromView(view).viewInsets.bottom;
  }

  void _onStoreChanged() {
    final tp = (widget.store.state.spotCheckDetails['textPosition'] as num?)
            ?.toDouble() ??
        double.negativeInfinity;
    if (tp == _lastTextPositionForScroll) return;
    _lastTextPositionForScroll = tp;
    // The settle timer scrolls with the latest position once the keyboard stops moving.
    if (_keyboardSettle != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyLegacyWrapperScroll();
    });
  }

  void _applyLegacyWrapperScroll() {
    if (!Platform.isAndroid) return;

    final kb = _keyboardHeight();
    if (kb <= 0) return;

    final sd = widget.store.state.spotCheckDetails;
    // Classic: Android and the WebView already bring the focused field into view; a second scroll made it bounce.
    if (sd['spotCheckType'] != 'chat') return;
    final c = widget.store.wrapperListScrollController;
    if (!c.hasClients) return;

    c.animateTo(
      kb.clamp(0.0, c.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
