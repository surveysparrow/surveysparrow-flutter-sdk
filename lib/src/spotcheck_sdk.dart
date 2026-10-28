import 'dart:async' show unawaited;
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';

import 'builder/builder.dart' show SpotcheckActions;
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

// Raw device facts; the backend builds the User-Agent from these.
Future<Map<String, dynamic>> _deviceFacts() async {
  final facts = await _osFacts();
  // Host app release; the backend keeps the SDK version of the newest build.
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) facts['appVersion'] = info.version;
    if (info.buildNumber.isNotEmpty) facts['appBuild'] = info.buildNumber;
  } catch (_) {}
  return facts;
}

Future<Map<String, dynamic>> _osFacts() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      final view = PlatformDispatcher.instance.views.first;
      final ratio = view.devicePixelRatio;
      final w = view.physicalSize.width;
      final h = view.physicalSize.height;
      final isTablet = (ratio < 2 && (w >= 1000 || h >= 1000)) ||
          (ratio == 2 && (w >= 1920 || h >= 1920));
      return {'os': 'android', 'osVersion': info.version.release, 'isTablet': isTablet};
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return {
        'os': 'ios',
        'osVersion': info.systemVersion,
        'deviceName': info.name,
        'model': info.model,
        'isTablet': false,
      };
    }
  } catch (_) {}
  return {};
}

// Fallback User-Agent (legacy format) for backends that don't build one.
String _fallbackUserAgent(Map<String, dynamic> d) {
  if (d['os'] == 'android') {
    return 'Mozilla/5.0 (Linux; Android ${d['osVersion']}; ${d['isTablet'] == true ? 'Tablet' : 'Mobile'}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36';
  }
  if (d['os'] == 'ios') {
    final version = (d['osVersion'] as String).replaceAll('.', '_');
    return 'Mozilla/5.0 (${d['deviceName']} - ${d['model']} CPU iOS $version like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/537.36';
  }
  return 'SurveySparrow-Flutter-SDK/$sdkVersion (${defaultTargetPlatform.name})';
}

const _nonFunctionKeys = {'componentSchemas', 'config'};

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

  // A failed init (e.g. offline) is retried on the next track call, at most every 10s.
  static const Duration _initRetryGap = Duration(seconds: 10);
  Future<void> Function()? _retryInit;
  bool _initFailed = false;
  DateTime _lastInitAttempt = DateTime.fromMillisecondsSinceEpoch(0);

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

    executables.onWebViewInject = webViewManager.injectScript;
    // Schema `$execute` taps run backend functions; unknown names are ignored by execute().
    SpotcheckActions.runner = (fn, params) {
      executables.execute(fn, params);
    };
    // A schema node that failed to render was skipped; the app keeps running.
    SpotcheckActions.renderErrorReporter = (error, stack, nodeKey) {
      sentry.captureP1Error(error, 'APP_CRASH', {'action': 'renderNode', 'node': nodeKey}, stack);
    };

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

    _initFailed = false;
    _lastInitAttempt = DateTime.now();
    _retryInit = () => initialize(
          domainName: domainName,
          targetToken: targetToken,
          userDetails: userDetails,
          variables: variables,
          customProperties: customProperties,
          spotCheckListener: spotCheckListener,
        );

    executables.resetInitializationGate();

    listener.setListener(spotCheckListener);
    sentry.configure(domainName: domainName, targetToken: targetToken);

    _api = SpotcheckApi(domainName: domainName, targetToken: targetToken);
    final device = await _deviceFacts();
    final userAgent = _fallbackUserAgent(device);

    spotcheckStore.dispatch({
      'params': {
        'domainName': domainName,
        'targetToken': targetToken,
        'userDetails': userDetails,
        'variables': variables ?? {},
        'customProperties': customProperties ?? {},
        'framework': 'flutter',
        'userAgent': userAgent,
      },
    });

    try {
      final response = await _api!.getAllSpotcheckFunctions();

      // Load every function the backend sends (non-function keys skipped).
      final functions = <String, dynamic>{};
      response.forEach((key, value) {
        if (_nonFunctionKeys.contains(key)) return;
        if (value is String && value.isNotEmpty) {
          functions[key] = value;
        } else if (value is Map) {
          final group = <String, dynamic>{};
          value.forEach((k, v) {
            if (v is String && v.isNotEmpty) group[k.toString()] = v;
          });
          if (group.isNotEmpty) functions[key.toString()] = group;
        }
      });

      final config = response['config'];
      final script = config is Map ? config['webViewScript'] : null;
      webViewManager.remoteWebViewScript =
          script is String && script.trim().isNotEmpty ? script : null;

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
        'framework': 'flutter',
        'sdkVersion': sdkVersion,
        'device': device,
      });

      await executables.flushPendingExecutes();
    } catch (e) {
      _initFailed = true;
      executables.abandonPendingInitialization();
      sentry.captureP0Error(e, 'SPOTCHECK_INITIALIZATION', {'action': 'initialize'});
    }
  }

  // False drops the call (iOS parity); a started retry queues it until init finishes.
  bool _retryInitIfFailed() {
    if (!_initFailed) return true;
    final retry = _retryInit;
    if (retry == null || DateTime.now().difference(_lastInitAttempt) < _initRetryGap) return false;
    unawaited(retry());
    return true;
  }

  Future<void> trackScreen(String screen) async {
    if (!_retryInitIfFailed()) return;
    sentry.addBreadcrumb('trackScreen', {'screen': screen});
    await executables.execute('trackScreen', {'screen': screen});
  }

  Future<void> trackEvent(String screen, Map<String, dynamic> event) async {
    if (!_retryInitIfFailed()) return;
    sentry.addBreadcrumb('trackEvent', {'screen': screen, 'event': event.keys.join(',')});
    await executables.execute('trackEvent', {'screen': screen, 'event': event});
  }

  void handleNavigationChange() {
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
    executables.dispose();
    webViewManager.dispose();
    SpotcheckScrollBinding.clear();
    spotcheckStore.dispose();
    functionStore.dispose();
    componentStore.dispose();
    _instance = null;
  }
}
