import 'package:flutter/material.dart';
import '../builder/component_registry.dart';
import '../state/spotcheck_state.dart';
import '../state/component_state.dart';
import '../execute/executables.dart';
import '../spotcheck_sdk.dart';

/// Default until `getCloseButtonStyles` returns (matches backend `closeButtonMinimumTapTarget`).
const double _kDefaultMinTap = 44;

Color _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.black;
  final h = hex.startsWith('#') ? hex.substring(1) : hex;
  if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  if (h.length == 8) return Color(int.parse(h, radix: 16));
  return Colors.black;
}

class CloseButtonComponent extends StatefulWidget {
  final SpotcheckStore spotcheckStore;
  final ComponentStore componentStore;
  final Executables executables;

  const CloseButtonComponent({
    super.key,
    required this.spotcheckStore,
    required this.componentStore,
    required this.executables,
  });

  @override
  State<CloseButtonComponent> createState() => _CloseButtonComponentState();
}

class _CloseButtonComponentState extends State<CloseButtonComponent> {
  /// From backend `closeButtonMinimumTapTarget` (logical px).
  double _minTapW = _kDefaultMinTap;
  double _minTapH = _kDefaultMinTap;

  String _lastStyleKey = '';
  bool _styleLoading = false;

  @override
  void initState() {
    super.initState();
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    _lastStyleKey =
        '${sd['mode']}|${cb is Map ? '${cb['color']}_${cb['isEnabled']}' : cb}';
    widget.spotcheckStore.addListener(_onStateChanged);
    _loadCloseStyles();
  }

  @override
  void dispose() {
    widget.spotcheckStore.removeListener(_onStateChanged);
    super.dispose();
  }

  Future<void> _loadCloseStyles() async {
    if (_styleLoading) return;
    _styleLoading = true;
    final result = await widget.executables.execute('closeButton.getCloseButtonStyles');
    _styleLoading = false;
    if (!mounted) return;

    Map<String, dynamic>? map;
    if (result is Map<String, dynamic>) {
      map = result;
    } else if (result is Map) {
      map = Map<String, dynamic>.from(result);
    }
    if (map == null) return;

    final t = map['closeButtonMinimumTapTarget'];
    double w = _kDefaultMinTap;
    double h = _kDefaultMinTap;
    if (t is Map) {
      final mw = t['minWidth'];
      final mh = t['minHeight'];
      if (mw is num && mw > 0) w = mw.toDouble();
      if (mh is num && mh > 0) h = mh.toDouble();
    }
    setState(() {
      _minTapW = w;
      _minTapH = h;
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    final key =
        '${sd['mode']}|${cb is Map ? '${cb['color']}_${cb['isEnabled']}' : cb}';
    if (key != _lastStyleKey) {
      _lastStyleKey = key;
      _loadCloseStyles();
    }
    setState(() {});
  }

  Future<void> _handleClose() async {
    await widget.executables.execute('closeButton.handleCloseButton');
    SpotCheckSDK.instance.injectUnmountApp();
  }

  @override
  Widget build(BuildContext context) {
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    final isMiniCard = sd['mode'] == 'miniCard';
    final color = (cb is Map ? cb['color'] as String? : null) ?? '#000000';

    final iconColor = isMiniCard ? Colors.black : _parseHexColor(color);

    if (isMiniCard) {
      const visual = 32.0;
      final padH = ((_minTapW - visual) / 2).clamp(0.0, double.infinity);
      final padV = ((_minTapH - visual) / 2).clamp(0.0, double.infinity);
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleClose,
                child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ),
            ),
            ),
          ),
        ],
      );
    }

    return IconButton(
      onPressed: _handleClose,
      icon: Icon(Icons.close, size: 20, color: iconColor),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: _minTapW,
        minHeight: _minTapH,
      ),
      style: IconButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        overlayColor: Colors.transparent,
      ),
    );
  }
}

void registerCloseButtonComponent(
    SpotcheckStore store, ComponentStore componentStore, Executables exec) {
  ComponentRegistry.instance.register(
    'CloseButton',
    (props, children, {String? content}) {
      final sd = store.state.spotCheckDetails;
      final isMiniCard = sd['mode'] == 'miniCard';

      final child = CloseButtonComponent(
        spotcheckStore: store,
        componentStore: componentStore,
        executables: exec,
      );

      // miniCard: flow above the WebView as a flex-end row (not overlaid).
      // card/fullScreen: overlay with Positioned so it appears on top.
      if (isMiniCard) {
        return child;
      }

      return Positioned(
        top: 6,
        right: 8,
        child: child,
      );
    },
  );
}
