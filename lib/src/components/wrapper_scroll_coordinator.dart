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

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  // Legacy re-scrolled whenever the keyboard height changed.
  @override
  void didChangeMetrics() {
    final kb = _keyboardHeight();
    if (kb == _lastKeyboardHeight) return;
    _lastKeyboardHeight = kb;
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final textPos = (sd['textPosition'] as num?)?.toDouble() ?? 0;
    final spotType = sd['spotCheckType'] as String?;
    final c = widget.store.wrapperListScrollController;
    if (!c.hasClients) return;

    if (spotType == 'chat') {
      c.animateTo(
        kb.clamp(0.0, c.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final target = textPos - kb - 175;
      if (target > 0) {
        c.animateTo(
          target.clamp(0.0, c.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
