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

class _WrapperScrollCoordinatorState extends State<WrapperScrollCoordinator> {
  double _lastTextPositionForScroll = double.negativeInfinity;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
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

    final view = PlatformDispatcher.instance.views.first;
    final kb = MediaQueryData.fromView(view).viewInsets.bottom;
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
