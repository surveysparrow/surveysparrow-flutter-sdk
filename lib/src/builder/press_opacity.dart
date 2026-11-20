import 'package:flutter/widgets.dart';

/// Uniform tap feedback on every platform: dim while pressed.
class PressOpacity extends StatefulWidget {
  const PressOpacity({
    super.key,
    required this.child,
    this.onTap,
    this.pressedOpacity = 0.6,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;
  final HitTestBehavior behavior;

  @override
  State<PressOpacity> createState() => _PressOpacityState();
}

class _PressOpacityState extends State<PressOpacity> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: Opacity(opacity: _pressed ? widget.pressedOpacity : 1, child: widget.child),
    );
  }
}
