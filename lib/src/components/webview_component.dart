import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../builder/component_registry.dart';
import '../state/spotcheck_state.dart';
import '../state/component_state.dart';
import '../execute/executables.dart';

class WebViewControllerManager with WidgetsBindingObserver {
  final Executables executables;
  final SpotcheckStore spotcheckStore;

  WebViewController? classicController;
  String? remoteWebViewScript;
  WebViewController? chatController;
  String? _prevInjKey;

  bool _isImageCaptureActive = false;
  bool _observing = false;
  String? _lastScreenHeight;

  WebViewControllerManager({
    required this.executables,
    required this.spotcheckStore,
  }) {
    spotcheckStore.addListener(_onStateChanged);
  }

  /// Backend-driven injection (payload.webview.inject).
  void injectScript(String target, String script) {
    final controller = target == 'chat' ? chatController : classicController;
    if (controller == null) return;
    controller.runJavaScript(script).catchError((_) {});
    _updateFileSelectionListener();
  }

  // Keeps the focus script's screen height correct after rotation.
  @override
  void didChangeMetrics() {
    if (PlatformDispatcher.instance.views.isEmpty) return;
    final h = _logicalScreenHeight().toStringAsFixed(4);
    // Skip keyboard frames; only real height changes matter.
    if (h == _lastScreenHeight) return;
    _lastScreenHeight = h;
    final js = 'window.__ssScreenHeight = $h;';
    classicController?.runJavaScript(js).catchError((_) {});
    chatController?.runJavaScript(js).catchError((_) {});
  }

  Future<List<String>> _pickFiles({bool isImage = false}) async {
    try {
      if (isImage) {
        final picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.camera);
        _isImageCaptureActive = false;
        _updateFileSelectionListener();

        return pickedFile != null ? [File(pickedFile.path).uri.toString()] : [];
      } else {
        final files = await _pickPlatformFiles();
        return files
            .where((file) => file.path != null)
            .map((file) => File(file.path!).uri.toString())
            .toList();
      }
    } catch (e) {
      _isImageCaptureActive = false;
      _updateFileSelectionListener();
    }

    return [];
  }

  Future<void> _updateFileSelectionListener() async {
    if (!Platform.isAndroid) return;

    final spotCheckType =
        spotcheckStore.state.spotCheckDetails['spotCheckType'] as String?;
    if (spotCheckType == null || spotCheckType.isEmpty) return;

    final AndroidWebViewController? androidController =
        (spotCheckType == 'classic'
            ? classicController?.platform
            : chatController?.platform) as AndroidWebViewController?;

    if (androidController != null) {
      await androidController.setOnShowFileSelector((params) async {
        return _isImageCaptureActive
            ? await _pickFiles(isImage: true)
            : await _pickFiles();
      });
    }
  }

  void _captureImage() {
    _isImageCaptureActive = true;
    _updateFileSelectionListener();
  }

  static double _logicalScreenHeight() {
    // Legacy: height minus the top inset.
    final v = PlatformDispatcher.instance.views.first;
    return (v.physicalSize.height - v.padding.top) / v.devicePixelRatio;
  }

  static String _focusTrackingJavaScript(double logicalScreenHeight) {
    final h = logicalScreenHeight.toStringAsFixed(4);
    return '''
(function() {
  if (window.__ssSpotcheckFocusinInstalled) return;
  window.__ssSpotcheckFocusinInstalled = true;
  document.addEventListener('focusin', function(event) {
    if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
      var rect = event.target.getBoundingClientRect();
      var yPosition = rect.y + window.scrollY;
      var webViewHeight = window.innerHeight;
      var scaledY = (yPosition / webViewHeight) * (window.__ssScreenHeight || $h);
      flutterSpotCheckData.postMessage(JSON.stringify({
        type: 'position',
        y: scaledY
      }));
    }
  });
})();
''';
  }

  static String _euiPageHelperScripts() => r'''
(function() {
  if (window.__ssSpotcheckEuiHelpersInstalled) return;
  window.__ssSpotcheckEuiHelpersInstalled = true;
  var obs = new MutationObserver(function() {
    var input = document.querySelector(".ss-language-selector__select__input input");
    if (input) input.setAttribute("readonly", true);
  });
  obs.observe(document.body, { childList: true, subtree: true });
  var styleTag = document.createElement("style");
  styleTag.innerHTML = ".close-btn-chat--spotchecks { display: none !important; }";
  document.head.appendChild(styleTag);
})();
''';

  WebViewController _createController(bool isClassic) {
    late final WebViewController controller;
    controller = WebViewController(
      onPermissionRequest: (WebViewPermissionRequest request) {
        request.grant();
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          final sh = _logicalScreenHeight();
          final remote = remoteWebViewScript;
          // Backend page script when sent; built-in one otherwise.
          final js = remote != null
              ? 'window.__ssScreenHeight = window.__ssScreenHeight || ${sh.toStringAsFixed(4)};\n$remote'
              : '${_focusTrackingJavaScript(sh)}\n${_euiPageHelperScripts()}';
          controller.runJavaScript(js).catchError((_) {});
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            executables.execute(
              'webviewComponent.handleWebViewError',
              {'error': error.description},
            );
          }
        },
      ))
      ..addJavaScriptChannel(
        'flutterSpotCheckData',
        onMessageReceived: (message) {
          final data = message.message;
          if (data.isNotEmpty && data != 'captureImage') {
            executables.execute(
              'webviewComponent.handleWebViewMessage',
              {
                'event': {
                  'nativeEvent': {'data': data}
                }
              },
            );
          }
        },
      )
      ..addJavaScriptChannel(
        'SsFlutterSdk',
        onMessageReceived: (message) {
          if (message.message == 'captureImage') {
            _captureImage();
          }
        },
      );

    return controller;
  }

  void ensureControllers() {
    final wd = spotcheckStore.state.webViewDetails;
    final classicUrl = wd['classicUrl'] as String?;
    final chatUrl = wd['chatUrl'] as String?;

    if (classicUrl != null &&
        classicUrl.isNotEmpty &&
        classicController == null) {
      classicController = _createController(true);
      classicController!.loadRequest(Uri.parse(classicUrl));
    }

    if (chatUrl != null && chatUrl.isNotEmpty && chatController == null) {
      chatController = _createController(false);
      chatController!.loadRequest(Uri.parse(chatUrl));
    }

    // Lazy so the binding exists (not required before runApp).
    if (!_observing && (classicController != null || chatController != null)) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }

    _updateFileSelectionListener();
  }

  static String _injectionTriggerKey(Map<String, dynamic> wd) {
    final raw = wd['webViewInjectionData'];
    final String injPart = switch (raw) {
      null => 'null',
      final String s => '${s.hashCode}_${s.length}',
      _ => 'other_${raw.hashCode}',
    };
    return '${wd['isClassicLoading']}_${wd['isChatLoading']}_$injPart';
  }

  void _onStateChanged() {
    ensureControllers();

    final wd = spotcheckStore.state.webViewDetails;
    final injKey = _injectionTriggerKey(wd);

    if (injKey != _prevInjKey) {
      _prevInjKey = injKey;
      executables.execute('webviewComponent.handleWebViewInjection');
    }
  }

  void dispose() {
    spotcheckStore.removeListener(_onStateChanged);
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
  }
}

class WebViewComponentWidget extends StatelessWidget {
  final WebViewControllerManager webViewManager;
  final SpotcheckStore spotcheckStore;
  final ComponentStore componentStore;

  const WebViewComponentWidget({
    super.key,
    required this.webViewManager,
    required this.spotcheckStore,
    required this.componentStore,
  });

  @override
  Widget build(BuildContext context) {
    webViewManager.ensureControllers();

    final wd = spotcheckStore.state.webViewDetails;
    final canShowClassic = wd['canShowClassic'] == true;
    final canShowChat = wd['canShowChat'] == true;

    final schema = componentStore.getSchema('webviewComponent');
    final children = schema?['children'] as List?;
    final classicSchema = children?.firstWhere(
      (c) => c is Map && c['meta']?['webViewType'] == 'classic',
      orElse: () => null,
    );
    final chatSchema = children?.firstWhere(
      (c) => c is Map && c['meta']?['webViewType'] == 'chat',
      orElse: () => null,
    );
    Map<String, dynamic>? classicHidden;
    if (classicSchema is Map) {
      final p = classicSchema['props'];
      if (p is Map && p['hiddenStyle'] is Map) {
        classicHidden = Map<String, dynamic>.from(p['hiddenStyle'] as Map);
      }
    }
    Map<String, dynamic>? chatHidden;
    if (chatSchema is Map) {
      final p = chatSchema['props'];
      if (p is Map && p['hiddenStyle'] is Map) {
        chatHidden = Map<String, dynamic>.from(p['hiddenStyle'] as Map);
      }
    }

    final slots = <_WebViewSlot>[
      if (webViewManager.classicController != null)
        _WebViewSlot(
          key: ObjectKey(webViewManager.classicController),
          controller: webViewManager.classicController!,
          canShow: canShowClassic,
          hiddenStyle: classicHidden,
        ),
      if (webViewManager.chatController != null)
        _WebViewSlot(
          key: ObjectKey(webViewManager.chatController),
          controller: webViewManager.chatController!,
          canShow: canShowChat,
          hiddenStyle: chatHidden,
        ),
    ];
    // Hidden (preloading) webview spans past the card; paint it first so the shown one is on top.
    slots.sort((a, b) => (a.canShow ? 1 : 0) - (b.canShow ? 1 : 0));

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: slots,
    );
  }
}

class _WebViewSlot extends StatelessWidget {
  final WebViewController controller;
  final bool canShow;
  final Map<String, dynamic>? hiddenStyle;

  const _WebViewSlot({
    super.key,
    required this.controller,
    required this.canShow,
    this.hiddenStyle,
  });

  static Widget _clipWebViewToBox(WebViewWidget webView, BoxConstraints c) {
    if (!c.hasBoundedWidth || !c.hasBoundedHeight) {
      return const SizedBox.shrink();
    }
    final w = c.maxWidth;
    final h = c.maxHeight;
    if (w < 4 || h < 4) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: SizedBox(
        width: w,
        height: h,
        child: webView,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final webView = WebViewWidget(
      controller: controller,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
      },
    );

    if (!canShow) {
      final hs = hiddenStyle;
      final w = hs?['width'];
      final h = hs?['height'];
      final sw = (w is num && w == -1) ? screenWidth : (w as num?)?.toDouble();
      final sh = (h as num?)?.toDouble();
      if (sw == null || sh == null || sw < 4 || sh < 4) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: (hs?['top'] as num?)?.toDouble(),
        bottom: (hs?['bottom'] as num?)?.toDouble(),
        left: (hs?['left'] as num?)?.toDouble(),
        right: (hs?['right'] as num?)?.toDouble(),
        // Preloading only: never takes taps meant for the shown survey.
        child: IgnorePointer(
          child: SizedBox(
            width: sw,
            height: sh,
            child: ClipRect(child: webView),
          ),
        ),
      );
    }

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _clipWebViewToBox(webView, constraints);
        },
      ),
    );
  }
}

void registerWebViewComponent(
    SpotcheckStore store, ComponentStore componentStore, Executables exec) {
  ComponentRegistry.instance.register(
    'WebViewRenderer',
    (props, children, {String? content}) {
      return const SizedBox.shrink();
    },
  );
}

// file_picker 11/12 take allowMultiple (11 returns FilePickerResult?); 13 always multi-selects and returns a list.
Future<List<PlatformFile>> _pickPlatformFiles() async {
  dynamic result;
  try {
    result = await Function.apply(FilePicker.pickFiles, const [], const {#allowMultiple: true});
  } on NoSuchMethodError {
    result = await Function.apply(FilePicker.pickFiles, const []);
  }
  if (result is List) return result.whereType<PlatformFile>().toList();
  // file_picker 11's FilePickerResult (type gone in 12+), read dynamically.
  try {
    final files = (result as dynamic)?.files;
    if (files is List) return files.whereType<PlatformFile>().toList();
  } catch (_) {}
  return const [];
}
