import 'package:flutter/material.dart';
import '../builder/builder.dart';
import '../builder/component_registry.dart';
import '../state/spotcheck_state.dart';
import '../state/component_state.dart';
import '../execute/executables.dart';

class SpotCheckButtonComponent extends StatefulWidget {
  final SpotcheckStore spotcheckStore;
  final ComponentStore componentStore;
  final Executables executables;

  const SpotCheckButtonComponent({
    super.key,
    required this.spotcheckStore,
    required this.componentStore,
    required this.executables,
  });

  @override
  State<SpotCheckButtonComponent> createState() =>
      _SpotCheckButtonComponentState();
}

class _SpotCheckButtonComponentState extends State<SpotCheckButtonComponent> {
  Map<String, dynamic> _styles = {};
  bool _styleLoading = false;
  String _lastStyleKey = '';
  String? _lastMediaKey;

  /// Bumps when the button is shown again after being hidden (nav away + back).
  /// Keys [SchemaBuilder] so the subtree remounts — fresh [AnimationWrapper] state (Expo remount parity).
  int _buttonShowSession = 0;
  bool _wasSpotCheckButton = false;

  @override
  void initState() {
    super.initState();
    widget.spotcheckStore.addListener(_onStateChanged);
    final isBtn =
        widget.spotcheckStore.state.spotCheckDetails['isSpotCheckButton'] ==
            true;
    _wasSpotCheckButton = isBtn;
    if (isBtn) _buttonShowSession = 1;
    _loadStyles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Side-tab translateX/Y depend on width/height; re-fetch styles after orientation/size change.
    final size = MediaQuery.sizeOf(context);
    final key = '${size.width}_${size.height}';
    if (_lastMediaKey == key) return;
    final hadPrevious = _lastMediaKey != null;
    _lastMediaKey = key;
    if (hadPrevious) {
      _lastStyleKey = '';
      _loadStyles();
    }
  }

  @override
  void dispose() {
    widget.spotcheckStore.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;

    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final isBtn = sd['isSpotCheckButton'] == true;
    final shouldBumpSession = isBtn && !_wasSpotCheckButton;
    _wasSpotCheckButton = isBtn;

    setState(() {
      if (shouldBumpSession) _buttonShowSession++;
    });

    final key = '${sd['isSpotCheckButton']}|${sd['spotCheckButtonConfig']}'
        '|${sd['isVisible']}|${sd['mode']}|${sd['position']}'
        '|${sd['sideTabButtonWidth']}';

    if (key == _lastStyleKey) return;
    _lastStyleKey = key;
    _loadStyles();
  }

  void _loadStyles() async {
    if (_styleLoading) return;
    _styleLoading = true;

    final result = await widget.executables.execute(
      'spotCheckButton.getSpotCheckButtonStyles',
    );

    _styleLoading = false;
    if (result is Map<String, dynamic> && mounted) {
      setState(() => _styles = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = widget.componentStore.getSchema('spotCheckButton');
    if (schema == null || !widget.componentStore.isLoaded) {
      return const SizedBox.shrink();
    }

    final rawState = widget.spotcheckStore.getState()['SpotCheckState'];
    final state = rawState is Map
        ? rawState.map<String, dynamic>((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final builderContext = BuilderContext(
      state: state,
      styles: _styles,
      handlers: {
        'handleSpotCheckButtonPress': () {
          widget.executables
              .execute('spotCheckButton.handleSpotCheckButtonPress');
        },
        'handleSideTabLayout': ([dynamic event]) {
          widget.executables.execute(
            'spotCheckButton.handleSideTabLayout',
            {'event': event},
          );
        },
        'executeFunction': (String name) => widget.executables.execute(name),
      },
    );

    return SchemaBuilder(
      key: ValueKey<String>('spotcheck-btn-$_buttonShowSession'),
      schema: schema,
      context: builderContext,
    );
  }
}

void registerSpotCheckButtonComponent(
    SpotcheckStore store, ComponentStore componentStore, Executables exec) {
  ComponentRegistry.instance.register(
    'SpotCheckButton',
    (props, children, {String? content}) => SpotCheckButtonComponent(
      spotcheckStore: store,
      componentStore: componentStore,
      executables: exec,
    ),
  );
}
