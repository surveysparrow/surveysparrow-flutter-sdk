import 'dart:async';
import 'dart:convert';
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

class WebViewControllerManager {
  final Executables executables;
  final SpotcheckStore spotcheckStore;

  WebViewController? classicController;
  WebViewController? chatController;
  String? _lastInjectedData;
  String? _prevInjKey;

  String? _pendingClassicJs;
  String? _pendingChatJs;

  bool _isImageCaptureActive = false;

  static final String _unmountAppJs = """
      (function() {
        window.dispatchEvent(new MessageEvent('message', {
          data: ${jsonEncode({"type": "UNMOUNT_APP"})}
        }));
      })();
    """;

  void injectUnmountApp() {
    final isChat = spotcheckStore.state.webViewDetails['isChat'] == true;
    if (isChat && chatController != null) {
      chatController!.runJavaScript(_unmountAppJs);
    } else if (classicController != null) {
      classicController!.runJavaScript(_unmountAppJs);
    }
  }

  WebViewControllerManager({
    required this.executables,
    required this.spotcheckStore,
  }) {
    spotcheckStore.addListener(_onStateChanged);
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
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        return result?.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!).uri.toString())
                .toList() ??
            [];
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
    final v = PlatformDispatcher.instance.views.first;
    return v.physicalSize.height / v.devicePixelRatio;
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
      var scaledY = (yPosition / webViewHeight) * $h;
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
  styleTag.innerHTML = ".surveysparrow-chat__wrapper .ss-language-selector--wrapper { margin-right: 45px; } .close-btn-chat--spotchecks { display: none !important; }";
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
          final js =
              '${_focusTrackingJavaScript(sh)}\n${_euiPageHelperScripts()}';
          controller.runJavaScript(js);
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
            try {
              final json = jsonDecode(data) as Map<String, dynamic>?;
              final type = json?['type'] as String?;
              if (type == 'surveyCompleted') {
                executables.execute(
                  'webviewComponent.handleWebViewMessage',
                  {
                    'event': {
                      'nativeEvent': {'data': data}
                    }
                  },
                );
                injectUnmountApp();
              } else if (type == 'thankYouPageSubmission') {
                final sd = spotcheckStore.state.spotCheckDetails;
                final isMiniCard = sd['mode'] == 'miniCard';
                final closeEnabled = sd['closeButton']?['isEnabled'] == true;
                if (isMiniCard && !closeEnabled) {
                  Timer(const Duration(seconds: 4), () {
                    injectUnmountApp();
                  });
                }
                executables.execute(
                  'webviewComponent.handleWebViewMessage',
                  {
                    'event': {
                      'nativeEvent': {'data': data}
                    }
                  },
                );
              } else {
                executables.execute(
                  'webviewComponent.handleWebViewMessage',
                  {
                    'event': {
                      'nativeEvent': {'data': data}
                    }
                  },
                );
              }
            } catch (_) {}
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

    _applyPendingJavaScriptInjection();
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

  void _applyPendingJavaScriptInjection() {
    final wd = spotcheckStore.state.webViewDetails;
    final injData = wd['webViewInjectionData'];
    final isChat = wd['isCurrentSpotcheckChat'];
    final isClassicLoading = wd['isClassicLoading'];
    final isChatLoading = wd['isChatLoading'];

    if (injData == null) {
      _lastInjectedData = null;
      _pendingClassicJs = null;
      _pendingChatJs = null;
      return;
    }

    if (injData is! String || injData.isEmpty) {
      return;
    }

    if (isChat != true) {
      _pendingClassicJs = injData;
      _pendingChatJs = null;
    } else {
      _pendingChatJs = injData;
      _pendingClassicJs = null;
    }

    final classicReady = isChat != true &&
        classicController != null &&
        isClassicLoading == false;
    final chatReady =
        isChat == true && chatController != null && isChatLoading == false;

    if (classicReady && _pendingClassicJs != null) {
      final js = _pendingClassicJs!;
      if (js != _lastInjectedData) {
        _lastInjectedData = js;
        classicController!.runJavaScript(js);
        _updateFileSelectionListener();
      }
    } else if (chatReady && _pendingChatJs != null) {
      final js = _pendingChatJs!;
      if (js != _lastInjectedData) {
        _lastInjectedData = js;
        chatController!.runJavaScript(js);
        _updateFileSelectionListener();
      }
    }
  }

  void flushPendingJavaScriptInjection() => _applyPendingJavaScriptInjection();

  void _onStateChanged() {
    ensureControllers();

    final wd = spotcheckStore.state.webViewDetails;
    final injKey = _injectionTriggerKey(wd);

    if (injKey != _prevInjKey) {
      _prevInjKey = injKey;
      executables.execute('webviewComponent.handleWebViewInjection');
    }

    _applyPendingJavaScriptInjection();
  }

  void dispose() {
    spotcheckStore.removeListener(_onStateChanged);
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
    webViewManager.flushPendingJavaScriptInjection();

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

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        if (webViewManager.classicController != null)
          _WebViewSlot(
            controller: webViewManager.classicController!,
            canShow: canShowClassic,
            hiddenStyle: classicHidden,
          ),
        if (webViewManager.chatController != null)
          _WebViewSlot(
            controller: webViewManager.chatController!,
            canShow: canShowChat,
            hiddenStyle: chatHidden,
          ),
      ],
    );
  }
}

class _WebViewSlot extends StatelessWidget {
  final WebViewController controller;
  final bool canShow;
  final Map<String, dynamic>? hiddenStyle;

  const _WebViewSlot({
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
        child: SizedBox(
          width: sw,
          height: sh,
          child: ClipRect(child: webView),
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
