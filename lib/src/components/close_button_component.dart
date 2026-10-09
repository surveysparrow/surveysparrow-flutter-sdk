import 'dart:async';
import 'package:flutter/material.dart';
import '../builder/builder.dart';
import '../builder/component_registry.dart';
import '../builder/press_opacity.dart';
import '../state/spotcheck_state.dart';
import '../state/component_state.dart';
import '../execute/executables.dart';

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
  double _minTapW = _kDefaultMinTap;
  double _minTapH = _kDefaultMinTap;

  String _lastStyleKey = '';
  bool _styleLoading = false;
  bool _styleReloadPending = false;
  Map<String, dynamic> _containerStyle = const {};
  Map<String, dynamic> _allStyles = const {};

  @override
  void initState() {
    super.initState();
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    _lastStyleKey =
        '${sd['mode']}|${sd['isRTLLanguage']}|${cb is Map ? '${cb['color']}_${cb['isEnabled']}_${cb['isMiniCard']}' : cb}';
    widget.spotcheckStore.addListener(_onStateChanged);
    _loadCloseStyles();
  }

  @override
  void dispose() {
    widget.spotcheckStore.removeListener(_onStateChanged);
    super.dispose();
  }

  Future<void> _loadCloseStyles() async {
    if (_styleLoading) {
      _styleReloadPending = true;
      return;
    }
    _styleLoading = true;
    final result = await widget.executables.execute('closeButton.getCloseButtonStyles');
    _styleLoading = false;
    if (_styleReloadPending && mounted) {
      _styleReloadPending = false;
      unawaited(_loadCloseStyles());
    }
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
    final container = map['closeButtonContainerStyle'];
    setState(() {
      _minTapW = w;
      _minTapH = h;
      _containerStyle =
          container is Map ? Map<String, dynamic>.from(container) : const {};
      _allStyles = map!;
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    final key =
        '${sd['mode']}|${sd['isRTLLanguage']}|${cb is Map ? '${cb['color']}_${cb['isEnabled']}_${cb['isMiniCard']}' : cb}';
    if (key != _lastStyleKey) {
      _lastStyleKey = key;
      _loadCloseStyles();
    }
    setState(() {});
  }

  Future<void> _handleClose() async {
    await widget.executables.execute('closeButton.handleCloseButton');
  }

  @override
  Widget build(BuildContext context) {
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final cb = sd['closeButton'];
    final isMiniCard = sd['mode'] == 'miniCard';
    final color = (cb is Map ? cb['color'] as String? : null) ?? '#000000';

    final iconColor = isMiniCard ? Colors.black : _parseHexColor(color);

    // Backend-driven look when the backend sends it; hard-coded fallback otherwise.
    final schema = widget.componentStore.getSchema('closeButton');
    if (schema != null && _allStyles.containsKey('closeButtonTapStyle')) {
      final rawState = widget.spotcheckStore.getState()['SpotCheckState'];
      final built = SchemaBuilder(
        schema: schema,
        context: BuilderContext(
          state: rawState is Map
              ? rawState.map<String, dynamic>((k, v) => MapEntry(k.toString(), v))
              : <String, dynamic>{},
          styles: _allStyles,
          handlers: {'handleClosePress': () => _handleClose()},
        ),
      );
      if (!isMiniCard) return built;
      return Row(
        mainAxisAlignment: _containerStyle['alignSelf'] == 'flex-start'
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [built],
      );
    }

    if (isMiniCard) {
      const visual = 32.0;
      final padH = ((_minTapW - visual) / 2).clamp(0.0, double.infinity);
      final padV = ((_minTapH - visual) / 2).clamp(0.0, double.infinity);
      // Backend style flips the row for RTL (flex-start) — legacy parity.
      return Row(
        mainAxisAlignment: _containerStyle['alignSelf'] == 'flex-start'
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          // Legacy row is 48 (32 + 8 each side); tap padding counts toward it.
          Padding(
            padding: EdgeInsets.symmetric(vertical: (8 - padV).clamp(0.0, 8.0)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              child: PressOpacity(
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

    final button = PressOpacity(
      onTap: _handleClose,
      child: SizedBox(
        width: _minTapW,
        height: _minTapH,
        child: Center(child: Icon(Icons.close, size: 20, color: iconColor)),
      ),
    );

    return button;
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

      // miniCard flows above the WebView; card/fullScreen overlays (left in RTL).
      if (isMiniCard) return child;
      final isRtl = sd['isRTLLanguage'] == true;
      return Positioned(
        top: 6,
        left: isRtl ? 8 : null,
        right: isRtl ? null : 8,
        child: child,
      );
    },
  );
}
