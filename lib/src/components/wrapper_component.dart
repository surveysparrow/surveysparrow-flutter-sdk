import 'dart:async';

import 'package:flutter/material.dart';
import '../builder/builder.dart';
import '../state/spotcheck_state.dart';
import '../state/component_state.dart';
import '../execute/executables.dart';

Map<String, dynamic> _deepCopyMap(Map<dynamic, dynamic> raw) {
  return raw.map((k, v) => MapEntry(k.toString(), _deepCopyValue(v)));
}

dynamic _deepCopyValue(dynamic v) {
  if (v is Map) return _deepCopyMap(v);
  if (v is List) return v.map(_deepCopyValue).toList();
  return v;
}

const String kSpotcheckDefaultAvatarUrl =
    'https://static.surveysparrow.com/application/images/profile.png';

Map<String, dynamic> _effectiveSpotCheckStateForBuilder(SpotcheckStore store) {
  final top = store.getState()['SpotCheckState'];
  if (top is! Map) return <String, dynamic>{};
  final state = _deepCopyMap(top);
  final details = Map<String, dynamic>.from(
      state['spotCheckDetails'] as Map? ?? <String, dynamic>{});
  final current = state['currentSpotcheck'] as Map? ?? {};
  Map<String, dynamic> appearance = {};
  final app = current['appearance'];
  if (app is Map) {
    appearance = app.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), v is Map ? _deepCopyMap(v) : v));
  }
  if (appearance.isEmpty) {
    final id =
        current['spotcheckID'] ?? current['spotCheckId'] ?? current['id'];
    final list = state['allSpotChecksInToken'];
    if (list is List && id != null) {
      for (final e in list) {
        if (e is! Map) continue;
        final m = e.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
        if (m['id'] == id || m['spotCheckId'] == id) {
          final a = m['appearance'];
          if (a is Map) {
            appearance = a.map<String, dynamic>((k, v) =>
                MapEntry(k.toString(), v is Map ? _deepCopyMap(v) : v));
          }
          break;
        }
      }
    }
  }

  String s(dynamic v) => v == null ? '' : v.toString().trim();
  final appMode = s(appearance['mode']);
  if (appMode.isNotEmpty && s(details['mode']).isEmpty) {
    details['mode'] = appMode;
  }
  final appPos = appearance['position'];
  if ((details['position'] == null || details['position'] == '') &&
      appPos != null) {
    details['position'] = appPos;
  }
  final mode = s(details['mode']);
  details['isFullScreenMode'] = mode == 'fullScreen';

  final av = appearance['avatar'];
  if (av is Map) {
    if (av['enabled'] == true && details['avatarEnabled'] != true) {
      details['avatarEnabled'] = true;
    }
    final urlStr = details['avatarUrl']?.toString().trim() ?? '';
    if (urlStr.isEmpty) {
      final fromAppearance = av['avatarUrl'] ?? av['url'];
      if (fromAppearance != null && fromAppearance.toString().trim().isNotEmpty) {
        details['avatarUrl'] = fromAppearance.toString();
      }
    }
  }

  if (details['avatarEnabled'] == true) {
    final u = details['avatarUrl']?.toString().trim() ?? '';
    if (u.isEmpty) {
      details['avatarUrl'] = kSpotcheckDefaultAvatarUrl;
    }
  }

  state['spotCheckDetails'] = details;
  return state;
}

Map<String, dynamic> _stateWithKeyboardInset(
  SpotcheckStore store,
  double keyboardInset,
) {
  final state = _effectiveSpotCheckStateForBuilder(store);
  final sd = Map<String, dynamic>.from(
    state['spotCheckDetails'] as Map? ?? <String, dynamic>{},
  );
  sd['keyBoardHeight'] = keyboardInset;
  state['spotCheckDetails'] = sd;
  return state;
}

class WrapperComponent extends StatefulWidget {
  final SpotcheckStore spotcheckStore;
  final ComponentStore componentStore;
  final Executables executables;
  final Widget child;

  const WrapperComponent({
    super.key,
    required this.spotcheckStore,
    required this.componentStore,
    required this.executables,
    required this.child,
  });

  @override
  State<WrapperComponent> createState() => _WrapperComponentState();
}

class _WrapperComponentState extends State<WrapperComponent> {
  Map<String, dynamic> _styles = {
    'overlayStyle': {'width': 0, 'height': 0, 'opacity': 0, 'positioned': true},
    'wrapperStyle': {
      'width': 0,
      'height': 0,
      'opacity': 0,
      'clipBehavior': 'hardEdge'
    },
    'webViewWrapperStyle': {'width': 0, 'height': 0, 'opacity': 0},
  };
  bool _styleLoading = false;
  String _lastStyleKey = '';
  double _keyboardInset = -1;
  Timer? _keyboardStyleDebounce;

  @override
  void initState() {
    super.initState();
    widget.spotcheckStore.addListener(_onStateChanged);
    widget.componentStore.addListener(_onComponentChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lastStyleKey = '';
      _loadStyles();
    });
  }

  @override
  void dispose() {
    _keyboardStyleDebounce?.cancel();
    widget.spotcheckStore.removeListener(_onStateChanged);
    widget.componentStore.removeListener(_onComponentChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    if (_keyboardInset >= 0 && (kb - _keyboardInset).abs() < 0.5) {
      return;
    }
    _keyboardInset = kb;
    _keyboardStyleDebounce?.cancel();
    _keyboardStyleDebounce = Timer(const Duration(milliseconds: 48), () {
      if (!mounted) return;
      _loadStyles();
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});

    // Build a key from the state fields that getWrapperStyles depends on.
    // Keyboard height is **not** here — it comes from [MediaQuery] in [_loadStyles]
    // and [build] (old arch used local Rx / plugin, not global store spam).
    final sd = widget.spotcheckStore.state.spotCheckDetails;
    final show = widget.spotcheckStore.state.showSpotCheck;
    final key = '$show|${sd['isMounted']}|${sd['isVisible']}|${sd['isExiting']}'
        '|${sd['currentQuestionHeight']}|${sd['miniCardHeight']}'
        '|${sd['textPosition']}|${sd['mode']}'
        '|${sd['position']}|${sd['isFullScreenMode']}';

    if (key == _lastStyleKey) return;
    _lastStyleKey = key;
    _loadStyles();
  }

  void _onComponentChanged() {
    if (mounted) setState(() {});
  }

  void _loadStyles() async {
    if (_styleLoading) return;
    _styleLoading = true;

    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom;
    final result = await widget.executables.execute(
      'wrapper.getWrapperStyles',
      {
        'screenHeight': mq.size.height,
        'screenWidth': mq.size.width,
        'keyboardHeight': kb,
        'setStyles': null,
      },
    );

    _styleLoading = false;
    if (result is Map<String, dynamic> && mounted) {
      setState(() => _styles = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wrapperSchema = widget.componentStore.getSchema('wrapper');
    if (wrapperSchema == null || !widget.componentStore.isLoaded) {
      return const SizedBox.shrink();
    }

    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final state = _stateWithKeyboardInset(widget.spotcheckStore, kb);

    final builderContext = BuilderContext(
      state: state,
      styles: _styles,
      slots: {'children': widget.child},
      handlers: {
        'executeFunction': (String name) => widget.executables.execute(name),
      },
    );

    return SchemaBuilder(schema: wrapperSchema, context: builderContext);
  }
}

void registerWrapperComponent() {
  // Wrapper is not registered as a schema component — it's a root widget
}
