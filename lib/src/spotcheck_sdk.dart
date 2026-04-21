import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';

import 'execute/executables.dart' show Executables;
import 'state/spotcheck_state.dart';
import 'state/function_state.dart';
import 'state/component_state.dart';
import 'api/spotcheck_api.dart';
import 'adapters/storage_adapter.dart';
import 'adapters/sentry_adapter.dart';
import 'adapters/keyboard_adapter.dart';
import 'adapters/listener_adapter.dart';
import 'builder/default_components.dart';
import 'components/close_button_component.dart';
import 'components/webview_component.dart';
import 'components/spotcheck_button_component.dart';
import 'components/wrapper_scroll_coordinator.dart';
import 'components/wrapper_component.dart';
import 'scroll/spotcheck_scroll_binding.dart';

String _spotcheckDefaultUserAgent() {
  return 'SurveySparrow-Flutter-SDK/$sdkVersion (${defaultTargetPlatform.name})';
}

class SpotCheckSDK {
  static SpotCheckSDK? _instance;

  late final SpotcheckStore spotcheckStore;
  late final FunctionStore functionStore;
  late final ComponentStore componentStore;
  late final Executables executables;
  late final StorageAdapter storage;
  late final SentryAdapter sentry;
  late final KeyboardAdapter keyboard;
  late final ListenerAdapter listener;
  late SpotcheckApi? _api;
  late final WebViewControllerManager webViewManager;

  bool _componentsRegistered = false;

  SpotCheckSDK._() {
    spotcheckStore = SpotcheckStore();
    functionStore = FunctionStore();
    componentStore = ComponentStore();
    storage = StorageAdapter();
    sentry = SentryAdapter();
    keyboard = KeyboardAdapter();
    listener = ListenerAdapter();

    executables = Executables(
      spotcheckStore: spotcheckStore,
      functionStore: functionStore,
      storage: storage,
      sentry: sentry,
      keyboard: keyboard,
      listener: listener,
    );

    SpotcheckScrollBinding.bindWrapperList(spotcheckStore.wrapperListScrollController);

    webViewManager = WebViewControllerManager(
      executables: executables,
      spotcheckStore: spotcheckStore,
    );

    executables.onAfterBatchDispatch =
        webViewManager.flushPendingJavaScriptInjection;

    sentry.wireExecute(
      execute: executables.execute,
      functionsLoaded: () => functionStore.isLoaded,
    );
  }

  static SpotCheckSDK get instance {
    _instance ??= SpotCheckSDK._();
    return _instance!;
  }

  void _registerComponents() {
    if (_componentsRegistered) return;
    registerDefaultComponents();
    registerCloseButtonComponent(spotcheckStore, componentStore, executables);
    registerWebViewComponent(spotcheckStore, componentStore, executables);
    _componentsRegistered = true;
  }

  Future<void> initialize({
    required String domainName,
    required String targetToken,
    required Map<String, dynamic> userDetails,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? customProperties,
    SsSpotcheckListener? spotCheckListener,
  }) async {
    _registerComponents();

    executables.resetInitializationGate();

    listener.setListener(spotCheckListener);
    sentry.configure(domainName: domainName, targetToken: targetToken);

    _api = SpotcheckApi(domainName: domainName, targetToken: targetToken);

    spotcheckStore.dispatch({
      'params': {
        'domainName': domainName,
        'targetToken': targetToken,
        'userDetails': userDetails,
        'variables': variables ?? {},
        'customProperties': customProperties ?? {},
        'framework': 'flutter',
        'userAgent': _spotcheckDefaultUserAgent(),
      },
    });

    try {
      final response = await _api!.getAllSpotcheckFunctions();
      if (response == null) {
        executables.abandonPendingInitialization();
        return;
      }

      final functions = <String, dynamic>{};
      final topLevelFunctions = [
        'initializeSpotcheckComponent',
        'trackScreen',
        'trackEvent',
        'handleNavigationChange',
        'handleExitAnimationComplete',
      ];
      for (final name in topLevelFunctions) {
        if (response[name] != null) functions[name] = response[name];
      }

      final groups = [
        'webviewComponent',
        'closeButton',
        'wrapper',
        'spotCheckButton',
        'sentry',
      ];
      for (final group in groups) {
        if (response[group] is Map) {
          functions[group] = response[group];
        }
      }

      functionStore.loadFunctions(functions);

      final rawSchemas = response['componentSchemas'];
      if (rawSchemas is Map) {
        final schemas = rawSchemas.map<String, dynamic>(
          (k, v) => MapEntry(k.toString(), v),
        );
        componentStore.loadSchemas(schemas);
      }

      await executables.execute('initializeSpotcheckComponent', {
        'domainName': domainName,
        'targetToken': targetToken,
        'userDetails': userDetails,
        'variables': variables ?? {},
        'customProperties': customProperties ?? {},
      });

      await executables.flushPendingExecutes();
    } catch (e) {
      executables.abandonPendingInitialization();
      sentry.captureP0Error(e, 'SDK_INITIALIZATION', {'action': 'initialize'});
    }
  }

  Future<void> trackScreen(String screen) async {
    await executables.execute('trackScreen', {'screen': screen});
  }

  Future<void> trackEvent(String screen, Map<String, dynamic> event) async {
    await executables.execute('trackEvent', {'screen': screen, 'event': event});
  }

  void injectUnmountApp() {
    webViewManager.injectUnmountApp();
  }

  void handleNavigationChange() {
    injectUnmountApp();
    executables.execute('handleNavigationChange');
  }

  late final Widget _wrapperWidget = WrapperScrollCoordinator(
    store: spotcheckStore,
    child: WrapperComponent(
      spotcheckStore: spotcheckStore,
      componentStore: componentStore,
      executables: executables,
      child: WebViewComponentWidget(
        webViewManager: webViewManager,
        spotcheckStore: spotcheckStore,
        componentStore: componentStore,
      ),
    ),
  );

  late final Widget _buttonWidget = SpotCheckButtonComponent(
    spotcheckStore: spotcheckStore,
    componentStore: componentStore,
    executables: executables,
  );

  Widget buildWrapperWidget() => _wrapperWidget;

  Widget buildButtonWidget() => _buttonWidget;

  Widget buildWidget({required Widget child}) {
    return Stack(
      children: [
        child,
        buildWrapperWidget(),
        buildButtonWidget(),
      ],
    );
  }

  void dispose() {
    SpotcheckScrollBinding.clear();
    spotcheckStore.dispose();
    functionStore.dispose();
    componentStore.dispose();
    _instance = null;
  }
}
