import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';
import 'src/spotcheck_sdk.dart';

class SpotCheck extends StatelessWidget {
  SpotCheck({
    Key? key,
    required this.targetToken,
    required this.domainName,
    required this.userDetails,
    this.variables = const {},
    this.customProperties = const {},
    this.spotCheckListener,
  }) : super(key: key) {
    spotCheckState = SpotCheckState._internal(this);
  }

  final String targetToken;
  final String domainName;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;
  final SsSpotcheckListener? spotCheckListener;

  late final SpotCheckState spotCheckState;

  void trackScreen(String screen) async {
    await SpotCheckSDK.instance.trackScreen(screen);
  }

  void trackEvent(String screen, Map<String, dynamic> event) async {
    await SpotCheckSDK.instance.trackEvent(screen, event);
  }

  @override
  Widget build(BuildContext context) {
    return spotCheckState;
  }
}

class SpotCheckState extends StatefulWidget {
  final SpotCheck _spotCheck;

  final ValueNotifier<bool> isSpotCheckOpen = ValueNotifier(false);
  final ValueNotifier<bool> isSpotCheckButton = ValueNotifier(false);

  SpotCheckState._internal(this._spotCheck);

  void closeSpotCheck() {
    SpotCheckSDK.instance.injectUnmountApp();
    SpotCheckSDK.instance.executables.execute('closeButton.handleCloseButton');
  }

  void end({bool isNavigation = false}) {
    SpotCheckSDK.instance.handleNavigationChange();
  }

  @override
  State<SpotCheckState> createState() => _SpotCheckStateState();
}

class _SpotCheckStateState extends State<SpotCheckState> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initSDK();
    SpotCheckSDK.instance.spotcheckStore.addListener(_syncState);
  }

  Future<void> _initSDK() async {
    await SpotCheckSDK.instance.initialize(
      domainName: widget._spotCheck.domainName,
      targetToken: widget._spotCheck.targetToken,
      userDetails: widget._spotCheck.userDetails,
      variables: widget._spotCheck.variables,
      customProperties: widget._spotCheck.customProperties,
      spotCheckListener: widget._spotCheck.spotCheckListener,
    );
    if (mounted) setState(() => _initialized = true);
  }

  void _syncState() {
    final details = SpotCheckSDK.instance.spotcheckStore.state.spotCheckDetails;
    widget.isSpotCheckOpen.value = (details['isVisible'] as bool?) ?? false;
    widget.isSpotCheckButton.value =
        (details['isSpotCheckButton'] as bool?) ?? false;
  }

  @override
  void dispose() {
    SpotCheckSDK.instance.spotcheckStore.removeListener(_syncState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    final sdk = SpotCheckSDK.instance;
    return _SpotCheckContent(sdk: sdk);
  }
}

class _SpotCheckContent extends StatefulWidget {
  final SpotCheckSDK sdk;
  const _SpotCheckContent({required this.sdk});

  @override
  State<_SpotCheckContent> createState() => _SpotCheckContentState();
}

class _SpotCheckContentState extends State<_SpotCheckContent> {
  late final Widget _wrapper;
  late final Widget _button;

  @override
  void initState() {
    super.initState();
    _wrapper = widget.sdk.buildWrapperWidget();
    _button = widget.sdk.buildButtonWidget();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.sdk.spotcheckStore,
      builder: (context, _) {
        final details = widget.sdk.spotcheckStore.state.spotCheckDetails;
        final isActive = (details['isVisible'] == true) ||
            (details['isSpotCheckButton'] == true);

        return IgnorePointer(
          ignoring: !isActive,
          child: SizedBox.expand(
            child: Stack(children: [_wrapper, _button]),
          ),
        );
      },
    );
  }
}

class SsNavigationListener extends NavigatorObserver {
  final SpotCheckState state;

  SsNavigationListener(this.state);

  @override
  void didPush(Route route, Route? previousRoute) {
    _handle();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _handle();
  }

  void _handle() {
    if (state.isSpotCheckOpen.value || state.isSpotCheckButton.value) {
      state.closeSpotCheck();
      state.end(isNavigation: true);
    }
  }
}
