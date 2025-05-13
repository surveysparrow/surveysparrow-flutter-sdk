import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

class SpotCheckState extends StatelessWidget {
  SpotCheckState(
      {Key? key,
      required this.targetToken,
      required this.domainName,
      required this.userDetails,
      required this.variables,
      required this.customProperties})
      : super(key: key);

  final String targetToken;
  final String domainName;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;
  double screenHeight = 0;
  double screenWidth = 0;
  final Map<String, dynamic> userDetails;

  final RxBool isValid = false.obs;
  final RxBool isFullScreenMode = false.obs;
  final RxBool isBannerImageOn = false.obs;
  final RxBool isSpotCheckOpen = false.obs;
  final RxBool isCloseButtonEnabled = false.obs;
  final RxMap<String, dynamic> closeButtonStyle = <String, dynamic>{}.obs;
  final RxString position = "bottom".obs;
  final RxString spotcheckURL = "".obs;
  final RxInt spotcheckID = 0.obs;
  final RxInt spotcheckContactID = 0.obs;
  final RxInt afterDelay = 0.obs;
  final RxInt currentQuestionHeight = 0.obs;
  final RxString triggerToken = "".obs;
  final RxString traceId = "".obs;
  final RxBool _isImageCaptureActive = false.obs;
  final RxDouble maxHeight = 0.0.obs;
  final RxBool _isAnimated = false.obs;
  final RxBool _isSpotPassed = false.obs;
  final RxBool _isChecksPassed = false.obs;
  final RxList<dynamic> customEventsSpotChecks = [].obs;
  final RxString spotCheckType = ''.obs;
  final Rx<WebViewController?> chatController = Rx<WebViewController?>(null);
  final Rx<WebViewController?> classicController = Rx<WebViewController?>(null);
  final RxBool isMounted = false.obs;
  final RxBool isChatLoading = true.obs;
  final RxBool isClassicLoading = true.obs;
  final RxList<dynamic> filteredSpotChecks = <dynamic>[].obs;
  final RxString chatUrl = ''.obs;
  final RxString classicUrl = ''.obs;
  final RxBool isInit = false.obs;
  final RxBool isInjected = false.obs;
  final RxString avatarUrl = ''.obs;
  final RxString spotChecksMode = ''.obs;
  final RxBool avatarEnabled = false.obs;
  final RxDouble textPosition = 0.0.obs;
  var currentKeyboardHeight = 0.0.obs;
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chatscrollController = ScrollController();

  void start() {
    Future.delayed(Duration(seconds: afterDelay.value), () {
      _isAnimated.value = true;
      isSpotCheckOpen.value = true;
    });
  }

  void end() {

    WebViewController? webViewRef = spotCheckType.value == 'chat'
        ? chatController.value
        : classicController.value;

    if (webViewRef != null) {
      String injectedJavaScript = """
      (function() {
        window.dispatchEvent(new MessageEvent('message', {
          data: ${jsonEncode({"type": "UNMOUNT_APP"})}
        }));
      })();
    """;

      webViewRef.runJavaScript(injectedJavaScript);
      spotCheckType.value = "";
    }

    isSpotCheckOpen.value = false;
    isFullScreenMode.value = false;
    spotcheckID.value = 0;
    position.value = "";
    currentQuestionHeight.value = 0;
    isCloseButtonEnabled.value = false;
    closeButtonStyle.value = {};
    spotcheckContactID.value = 0;
    spotcheckURL.value = "";
    isMounted.value = false;
    isInjected.value = false;
    spotChecksMode.value = '';
    avatarEnabled.value = false;
    avatarUrl.value =  "";

  }

  Future<List<String>> _pickFiles({bool isImage = false}) async {
    try {
      if (isImage) {
        final picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.camera);
        _isImageCaptureActive.value = false;
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
      log('Error picking ${isImage ? "Image" : "Files"}: $e');
      _isImageCaptureActive.value = false;
      _updateFileSelectionListener();
    }

    return [];
  }

  void _updateFileSelectionListener() async {
    if (!Platform.isAndroid || spotCheckType.value.isEmpty) return;

    final AndroidWebViewController? androidController =
        (spotCheckType.value == "classic"
            ? classicController.value?.platform
            : chatController.value?.platform) as AndroidWebViewController?;

    if (androidController != null) {
      await androidController.setOnShowFileSelector((params) async {
        return _isImageCaptureActive.value
            ? await _pickFiles(isImage: true)
            : await _pickFiles();
      });
    }
  }

  void _captureImage() {
    _isImageCaptureActive.value = true;
    _updateFileSelectionListener();
  }

  Future<Map<String, dynamic>> sendTrackScreenRequest(String screen) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (traceId.isEmpty) {
      traceId.value = generateTraceId();
    }

    Map<String, dynamic> payloadUserDetails = Map.from(userDetails);

    if (payloadUserDetails["email"] == null &&
        payloadUserDetails["uuid"] == null &&
        payloadUserDetails["mobile"] == null) {
      String? uuid = prefs.getString("SurveySparrowUUID");

      if (uuid != null && uuid.isNotEmpty) {
        payloadUserDetails["uuid"] = "uuid";
      }
    }

    Map<String, dynamic> payload = {
      "screenName": screen,
      "variables": variables,
      "userDetails": payloadUserDetails,
      "visitor": {
        "deviceType": "MOBILE",
        "operatingSystem": Platform.operatingSystem,
        "screenResolution": {"height": screenHeight, "width": screenWidth},
        "currentDate": DateTime.now().toIso8601String(),
        "timezone": DateTime.now().timeZoneName,
      },
      "traceId": traceId.value,
      "customProperties": customProperties,
    };

    final Uri url = Uri.parse(
            'https://$domainName/api/internal/spotcheck/widget/$targetToken/properties')
        .replace(queryParameters: {"isSpotCheck": "true"});

    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseJson = jsonDecode(response.body);

        if (responseJson?["uuid"] != null) {
          prefs.setString(
              "SurveySparrowUUID", responseJson?["uuid"].toString() ?? "");
        }

        if (responseJson?["show"] != null) {
          bool show = responseJson?["show"];

          if (show) {
            setAppearance(responseJson!, screen);

            _isSpotPassed.value = true;
            log("Success: Spots or Checks or Visitor or Reccurence Condition Passed");
            return {"valid": true};
          } else {
            log("Error: Spots or Checks or Visitor or Reccurence Condition Failed");
            return {"valid": false};
          }
        } else {
          log("Error: Show not Received");
        }

        if (!_isSpotPassed.value) {
          if (responseJson?["checkPassed"] != null) {
            bool checkPassed = responseJson?["checkPassed"];

            if (checkPassed) {
              if (responseJson?["checkCondition"] != null) {
                Map<String, dynamic> checkCondition =
                    responseJson?["checkCondition"];
                if (checkCondition["afterDelay"] != null) {
                  afterDelay.value = checkCondition["afterDelay"];
                }
                if (checkCondition["customEvent"] != null) {
                  customEventsSpotChecks.value = [responseJson!];
                  return {"valid": false};
                }
              }

              setAppearance(responseJson!, screen);

              _isChecksPassed.value = true;
              log("Success: Checks Condition Passed");
              return {"valid": true};
            } else {
              log("Error: Checks Condition Failed");
              return {"valid": false};
            }
          } else {
            log("Error: CheckPassed not Received");
          }
        }

        if (!_isSpotPassed.value && !_isChecksPassed.value) {
          if (responseJson?["multiShow"] != null) {
            if (responseJson?["multiShow"]) {
              customEventsSpotChecks.value =
                  responseJson?["resultantSpotCheck"];

              Map<String, dynamic> selectedSpotCheck = {};
              int minDelay = 4294967296;

              for (var spotCheck in customEventsSpotChecks) {
                Map<String, dynamic> checks = spotCheck["checks"];
                if (checks.isEmpty) {
                  selectedSpotCheck = spotCheck;
                } else if (checks["afterDelay"] != null) {
                  int delay = checks["afterDelay"];
                  if (minDelay > delay) {
                    minDelay = delay;
                    selectedSpotCheck = spotCheck;
                  }
                }
              }

              if (selectedSpotCheck.isNotEmpty) {
                Map<String, dynamic> checks = selectedSpotCheck["checks"]!;

                if (checks.isNotEmpty) {
                  afterDelay.value = checks["afterDelay"] as int;
                }
              }

              setAppearance(selectedSpotCheck, screen);

              if (selectedSpotCheck.isNotEmpty) {
                return {"valid": true};
              }
            }
          } else {
            log("Info: MultiShow Not Received");
          }
        }

        return {"valid": false};
      } else {
        log('Error: ${response.statusCode}');
        return {"valid": false};
      }
    } catch (error) {
      log('Error: $error');
      return {"valid": false};
    }
  }

  Future<Map<String, dynamic>> sendTrackEventRequest(
      String screen, Map<String, dynamic> event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int intMax = 4294967296;
    var selectedSpotCheckID = intMax;

    if (customEventsSpotChecks.isNotEmpty) {
      for (Map<String, dynamic> spotCheck in customEventsSpotChecks) {
        Map<String, dynamic> checks =
            spotCheck["checks"] ?? spotCheck["checkCondition"];
        if (checks.isNotEmpty) {
          Map<String, dynamic> customEvent = checks["customEvent"] ?? {};
          if (customEvent.isNotEmpty &&
              event.keys.contains(customEvent["eventName"])) {
            selectedSpotCheckID =
                spotCheck["id"] ?? spotCheck["spotCheckId"] ?? intMax;

            Map<String, dynamic> payloadUserDetails = Map.from(userDetails);

            if (selectedSpotCheckID != intMax) {
              if (payloadUserDetails["email"] == null &&
                  payloadUserDetails["uuid"] == null &&
                  payloadUserDetails["mobile"] == null) {
                String? uuid = prefs.getString("SurveySparrowUUID");

                if (uuid != null && uuid.isNotEmpty) {
                  payloadUserDetails["uuid"] = "uuid";
                }
              }

              Map<String, dynamic> payload = {
                "url": screen,
                "variables": variables,
                "userDetails": payloadUserDetails,
                "visitor": {
                  "deviceType": "MOBILE",
                  "operatingSystem": Platform.operatingSystem,
                  "screenResolution": {
                    "height": screenHeight,
                    "width": screenWidth
                  },
                  "currentDate": DateTime.now().toIso8601String(),
                  "timezone": DateTime.now().timeZoneName,
                },
                "spotCheckId": selectedSpotCheckID,
                "eventTrigger": {
                  "customEvent": event,
                },
                "traceId": traceId.value,
                "customProperties": customProperties,
              };

              final Uri url = Uri.parse(
                      'https://$domainName/api/internal/spotcheck/widget/$targetToken/eventTrigger')
                  .replace(queryParameters: {"isSpotCheck": "true"});

              try {
                final http.Response response = await http.post(
                  url,
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(payload),
                );

                if (response.statusCode == 200) {
                  final Map<String, dynamic>? responseJson =
                      jsonDecode(response.body);

                  if (responseJson?["show"] != null) {
                    bool show = responseJson?["show"];
                    setAppearance(responseJson!, screen);
                    _isSpotPassed.value = true;
                    if (show) {
                      log("Success: Spots or Checks or Visitor or Reccurence Condition Passed");
                      return {"valid": true};
                    } else {
                      log("Error: Spots or Checks or Visitor or Reccurence Condition Failed");
                      return {"valid": false};
                    }
                  } else {
                    log("Error: Show not Received");
                  }

                  if (!_isSpotPassed.value) {
                    if (responseJson?["eventShow"]) {
                      if (responseJson?["checkCondition"] != null) {
                        Map<String, dynamic> checkCondition =
                            responseJson?["checkCondition"];
                        if (checkCondition["afterDelay"] != null) {
                          afterDelay.value = checkCondition["afterDelay"];
                        }
                        if (checkCondition["customEvent"] != null) {
                          var delay =
                              checkCondition["customEvent"]?["delayInSeconds"];
                          afterDelay.value = delay ?? 0;
                        }
                      }

                      setAppearance(responseJson!, screen);

                      log("Success: Checks Condition Passed");
                      return {"valid": true};
                    }
                  }
                } else {
                  log('Error: ${response.statusCode}');
                  return {"valid": false};
                }
              } catch (error) {
                log('Error: $error');
                return {"valid": false};
              }
            }
          }
        }
      }
      return {"valid": true};
    } else {
      return {"valid": false};
    }
  }

  Future<String> getUserAgent() async {
    String userAgent = 'Mozilla/5.0 ';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      bool isTablet;

      final double devicePixelRatio = ui.window.devicePixelRatio;
      final ui.Size size = ui.window.physicalSize;
      final double width = size.width;
      final double height = size.height;


      if(devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) {
        isTablet = true;
      }
      else if(devicePixelRatio == 2 && (width >= 1920 || height >= 1920)) {
        isTablet = true;
      }
      else {
        isTablet = false;
      }


      userAgent += '(Linux; Android ${androidInfo.version.release}; ${isTablet ? 'Tablet' : 'Mobile'}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String deviceName = iosInfo.name;
      String model = iosInfo.model;
      String iosVersion = iosInfo.systemVersion.replaceAll('.', '_');

      userAgent += '($deviceName - $model CPU iOS $iosVersion like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/537.36';
    }

    return userAgent;
  }

  Future<void> initializeWidget(String domainName, String targetToken) async {
    try {
      const String SDK = 'FLUTTER';
      final Uri url = Uri.parse(
          'https://$domainName/api/internal/spotcheck/widget/$targetToken/init?sdk=$SDK');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        log('Error fetching widget data: ${response.statusCode}');
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['filteredSpotChecks'] != null) {
        filteredSpotChecks.value =
            List<dynamic>.from(data['filteredSpotChecks']);
      }

      bool isClassicIframe = false, isChatIframe = false;

      for (final spotcheck in filteredSpotChecks) {
        final String mode = spotcheck['appearance']['mode'] as String;
        final String? surveyType =
            spotcheck['survey']?['surveyType'] as String?;

        if (mode == 'card' || mode == 'fullScreen' || mode=='miniCard') {
          isClassicIframe = true;
          if (mode == 'fullScreen' && isChatSurvey(surveyType)) {
            isChatIframe = true;
          }
        }
      }

      chatUrl.value =
          isChatIframe ? 'https://$domainName/eui-template/chat' : '';
      classicUrl.value =
          isClassicIframe ? 'https://$domainName/eui-template/classic' : '';

      void setupWebViewController(
          WebViewController controller, String url, RxBool loadingState) {
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url))
          ..setNavigationDelegate(NavigationDelegate(
            onPageFinished: (_) {
              loadingState.value = false;
              controller.runJavaScript(
                  """
          document.addEventListener('focusin', function(event) {
            if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
              var rect = event.target.getBoundingClientRect();
              var yPosition = rect.y + window.scrollY;
              var webViewHeight = window.innerHeight;
              var scaledY = (yPosition / webViewHeight) * ${screenHeight};

              flutterSpotCheckData.postMessage(JSON.stringify({
                type: 'position',
                y: scaledY
              }));
            }
          });
          """
              );
            },
          ))
          ..addJavaScriptChannel("flutterSpotCheckData",
              onMessageReceived: (response) {
                try {
                  var jsonResponse = json.decode(response.message);
                  if (jsonResponse['type'] == "spotCheckData") {

                    if(jsonResponse['data']['currentQuestionSize']!=null){
                    currentQuestionHeight.value =
                    jsonResponse['data']['currentQuestionSize']['height'] ?? 0.0;
                    if (spotChecksMode.value == 'miniCard' && isCloseButtonEnabled.value) {
                      currentQuestionHeight.value += 8;
                    }

                    if (spotChecksMode.value == 'miniCard' && avatarEnabled.value) {
                      currentQuestionHeight.value += 8;
                    }
                    }

                    else if(jsonResponse['data']['isCloseButtonEnabled']!=null){
                      isCloseButtonEnabled.value = jsonResponse['data']['isCloseButtonEnabled'];
                    }

                  } else if (jsonResponse['type'] == "surveyCompleted") {
                    end();
                  } else if (jsonResponse["type"] == 'slideInFrame') {
                    isMounted.value = true;
                  } else if (jsonResponse["type"] == 'position') {
                    if(Platform.isAndroid) {
                      textPosition.value = jsonResponse["y"];
                      ever(currentKeyboardHeight, (
                          double currentKeyboardHeight) {
                        if (currentKeyboardHeight > 0) {
                          if(spotCheckType.value=="chat"){
                            _chatscrollController.animateTo(
                              currentKeyboardHeight,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }

                          else if (textPosition.value - currentKeyboardHeight - 175 >
                              0)
                            _scrollController.animateTo(
                              textPosition.value - currentKeyboardHeight - 175,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                        }
                      });
                    }
                  }
                } catch (e) {
                  log("Error decoding JSON: $e");
                }
              })
          ..addJavaScriptChannel("SsFlutterSdk", onMessageReceived: (response) {
            if (response.message == 'captureImage') {
              _captureImage();
            }
          });
      }

      if (isChatIframe) {
        chatController.value = WebViewController();
        setupWebViewController(
            chatController.value!, chatUrl.value, isChatLoading);
      }

      if (isClassicIframe) {
        classicController.value = WebViewController();
        setupWebViewController(
            classicController.value!, classicUrl.value, isClassicLoading);
      }

      if (isChatIframe || isClassicIframe) {
        isInit.value = true;
      }
    } catch (error) {
      log('Error initializing widget: $error');
    }
  }

  bool isChatSurvey(String? type) {
    return type == 'Conversational' ||
        type == 'CESChat' ||
        type == 'NPSChat' ||
        type == 'CSATChat';
  }

  @override
  Widget build(BuildContext context) {
    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
        if(currentKeyboardHeight.value!=height){
        currentKeyboardHeight.value = height;}
    });
    screenWidth = MediaQuery.of(context).size.width;
    final mediaQuery = MediaQuery.of(context);
    screenHeight = mediaQuery.size.height;
    screenHeight = screenHeight - mediaQuery.padding.top;
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;
    if (!isInit.value) {
      initializeWidget(domainName, targetToken);
    }

    return Obx(() => SafeArea(
      child: Stack(
              children: <Widget>[
                ((isMounted.value || isFullScreenMode.value) && isInjected.value)
                    ? Container(
                        color: const Color.fromARGB(85, 0, 0, 0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                      )
                    : const SizedBox.shrink(),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(

                    children: [
                      Expanded(
                        child: Align(
                          alignment: _getAlignment(),
                          child: ListView(
                            physics: (Platform.isIOS)?const BouncingScrollPhysics():(currentKeyboardHeight.value>0)? const BouncingScrollPhysics():const ClampingScrollPhysics(),
                            controller: _scrollController,
                            shrinkWrap: true, // Ensure ListView only takes necessary height
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: (spotChecksMode.value == "miniCard") ? 12 : 0),
                                child: SizedBox(
                                  height: (isSpotCheckOpen.value == true &&
                                      ((isMounted.value || isFullScreenMode.value) &&
                                          isInjected.value) &&
                                      spotCheckType.value == "classic")
                                      ? isFullScreenMode.value
                                      ? (!Platform.isIOS)?screenHeight:screenHeight*0.945
                                      : math.min(
                                      screenHeight * 0.945,
                                      (math.min(
                                        currentQuestionHeight.value.toDouble(),
                                        maxHeight.value * screenHeight * 0.945,
                                      )) +
                                          (isBannerImageOn.value &&
                                              currentQuestionHeight.value != 0
                                              ? useMobileLayout
                                              ? 100
                                              : 0
                                              : 0)) +
                                      (currentQuestionHeight.value == 0 ? 150 : 0)
                                      : 1,
                                  width: (isSpotCheckOpen.value == true &&
                                      ((isMounted.value || isFullScreenMode.value) &&
                                          isInjected.value) &&
                                      spotCheckType.value == "classic")
                                      ? MediaQuery.of(context).size.width
                                      : 0,
                                  child: Stack(
                                    children: [
                                      (!isClassicLoading.value)
                                          ? Column(
                                        children: [
                                          (spotChecksMode.value == "miniCard")
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    closeSpotCheck();
                                                    end();
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
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
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                              : SizedBox.shrink(),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular((spotChecksMode.value == "miniCard") ? 12 : 0),
                                              child: WebViewWidget(
                                                gestureRecognizers: Set()
                                                  ..add(
                                                    Factory<VerticalDragGestureRecognizer>(
                                                          () => VerticalDragGestureRecognizer(),
                                                    ), // or null
                                                  ),
                                                key: ValueKey('classic'),
                                                controller: classicController.value!,
                                              ),
                                            ),
                                          ),
                                          (avatarEnabled.value && spotChecksMode.value == "miniCard")
                                              ? Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(24),
                                                  ),
                                                  elevation: 4,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(24),
                                                    child: Image.network(
                                                      avatarUrl.value,
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                              : const SizedBox.shrink(),
                                        ],
                                      )
                                          : const SizedBox(),
                                      (isCloseButtonEnabled.value &&
                                          !isClassicLoading.value &&
                                          isInjected.value &&
                                          spotChecksMode.value != "miniCard")
                                          ? Positioned(
                                        top: 6,
                                        right: 8,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Color(int.parse(isHex(closeButtonStyle["ctaButton"].toString())
                                                ? "0xFF${closeButtonStyle["ctaButton"].toString().replaceAll("#", "")}"
                                                : "0xFF000000")),
                                          ),
                                          onPressed: () {
                                            closeSpotCheck();
                                            end();
                                          },
                                        ),
                                      )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top:0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child:

                  Column(

                    children: [
                      Expanded(
                        child: Align(
                          alignment: _getAlignment(),
                          child: ListView(
                            physics: (Platform.isIOS)?const BouncingScrollPhysics():(currentKeyboardHeight.value>0)? const BouncingScrollPhysics():const ClampingScrollPhysics(),
                            controller: _chatscrollController,
                            shrinkWrap: true, // Ensure ListView only takes necessary height
                            children: [
                              Container(

                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: (isSpotCheckOpen.value == true &&
                                      ((isMounted.value || isFullScreenMode.value) &&
                                          isInjected.value) &&
                                      spotCheckType.value == "chat")
                                      ? isFullScreenMode.value
                                      ? (!Platform.isIOS)?screenHeight:screenHeight*0.945
                                      :0
                                      : 1,
                                  width: (isSpotCheckOpen.value == true &&
                                      ((isMounted.value || isFullScreenMode.value) &&
                                          isInjected.value) &&
                                      spotCheckType.value == "chat")
                                      ? MediaQuery.of(context).size.width
                                      : 1,
                                  child: Stack(
                                    children: [
                                      (!isChatLoading.value)
                                          ? WebViewWidget(
                                      gestureRecognizers: Set()
                                        ..add(
                                          Factory<VerticalDragGestureRecognizer>(
                                                () => VerticalDragGestureRecognizer(),
                                          ), // or null
                                        ),
                                        key: ValueKey('chat'),
                                        controller: chatController.value!,
                                      )
                                          : const SizedBox(),
                                      (isCloseButtonEnabled.value && !isChatLoading.value && isInjected.value && spotChecksMode.value!="miniCard")
                                          ? Positioned(
                                        top: 6,
                                        right: 8,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Color(int.parse(isHex(
                                                closeButtonStyle["ctaButton"]
                                                    .toString())
                                                ? "0xFF${closeButtonStyle["ctaButton"].toString().replaceAll("#", "")}"
                                                : "0xFF000000")),
                                          ),
                                          onPressed: () {
                                            closeSpotCheck();
                                            end();
                                          },
                                        ),
                                      )
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    ),
    );
  }

  Alignment _getAlignment() {
    switch (position.value) {
      case "top":
        return Alignment.topCenter;
      case "center":
        return Alignment.center;
      case "bottom":
        return Alignment.bottomCenter;
      default:
        return Alignment.bottomCenter;
    }
  }

  void setAppearance(Map<String, dynamic> responseJson, String screen) async {
    if (responseJson.isEmpty) return;

    bool chat = false;
    final appearance = responseJson["appearance"] ?? {};

    var currentSpotCheck = filteredSpotChecks.firstWhere(
      (spotcheck) =>
          spotcheck['id'] == responseJson['spotCheckId'] ||
          spotcheck['id'] == responseJson['id'],
      orElse: () => null,
    );

    chat = isChatSurvey(currentSpotCheck?['survey']?['surveyType']) &&
        appearance["mode"] == "fullScreen";

    spotChecksMode.value = appearance?["mode"];
    avatarEnabled.value = appearance?["avatar"]?["enabled"] ?? false;
    avatarUrl.value =  appearance?["avatar"]?["avatarUrl"] ?? '';

    spotCheckType.value = chat ? "chat" : "classic";

    switch (appearance["position"]) {
      case "top_full":
        position.value = "top";
        break;
      case "center_center":
        position.value = "center";
        break;
      case "bottom_full":
        position.value = "bottom";
        break;
    }

    isCloseButtonEnabled.value = appearance["closeButton"] ?? false;
    closeButtonStyle.value = appearance["colors"]?["overrides"] ?? {};

    Map<String, dynamic>? cardProp = appearance["cardProperties"];
    if (cardProp != null) {
      maxHeight.value =
          double.tryParse(cardProp["maxHeight"].toString()) ?? 1.0 / 100;
    }

    isFullScreenMode.value = appearance["mode"] == "fullScreen";
    isBannerImageOn.value = appearance["bannerImage"]?["enabled"] ?? false;

    spotcheckID.value = responseJson["spotCheckId"] ?? responseJson["id"];
    spotcheckContactID.value = responseJson["spotCheckContactId"] ??
        responseJson["spotCheckContact"]?["id"];
    triggerToken.value = responseJson["triggerToken"] ?? "";

    final sb = StringBuffer(
        "https://$domainName/n/spotcheck/${triggerToken.value}/${chat ? 'config' : 'bootstrap'}"
        "?spotcheckContactId=${spotcheckContactID.value}"
        "&traceId=${traceId.value}"
        "&spotcheckUrl=$screen");

    variables.forEach((key, value) => sb.write("&$key=$value"));
    spotcheckURL.value = sb.toString();
    log(spotcheckURL.value);

    try {
      String userAgent = await getUserAgent();
      final response = await http.get(Uri.parse(spotcheckURL.value),
        headers: {
          'User-Agent': userAgent,
        },);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final themeInfo = data["config"]["generatedCSS"];

        final themePayload = {
          "type": "THEME_UPDATE_SPOTCHECK",
          "themeInfo": themeInfo
        };

        final WebViewController? webViewRef =
            chat ? chatController.value : classicController.value;
        final RxBool isLoading = chat ? isChatLoading : isClassicLoading;

        final payload = {
          "type": "RESET_STATE",
          "state": {
            ...(data ?? {}),
            "skip": true,
            "spotCheckAppearance": {
              ...(appearance ?? {}),
              "targetType": "MOBILE",
            },
            "spotcheckUrl": screen,
            "traceId": traceId.value,
            "elementBuilderParams": {
              ...(variables ?? {}),
            },
          },
        };

        String injectedJavaScript = """
        (function() {
          window.dispatchEvent(new MessageEvent('message', { data: ${jsonEncode(payload)} }));
          window.dispatchEvent(new MessageEvent('message', { data: ${jsonEncode(themePayload)} }));
        })();
      """;

        if (!isLoading.value) {
          _updateFileSelectionListener();
          webViewRef?.runJavaScript(injectedJavaScript);
          isInjected.value = true;
        } else {
          ever(isLoading, (bool loading) {
            if (!loading) {
              _updateFileSelectionListener();
              webViewRef?.runJavaScript(injectedJavaScript);
              isInjected.value = true;
            }
          });
        }
      }
    } catch (e) {
      log("Error fetching spotcheck data: $e");
    }
  }

  void closeSpotCheck() async {
    try {
      final response = await http.put(
        Uri.parse(
            "https://$domainName/api/internal/spotcheck/dismiss/$spotcheckContactID"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"traceId": traceId.value, "triggerToken": triggerToken.value}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data["success"]) log("SpotCheck Closed");
      }
    } catch (error) {
      log("Error closing SpotCheck: $error");
    }
  }
}

String generateTraceId() {
  var uuid = const Uuid();
  String uuidString = uuid.v4();
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$uuidString-$timestamp';
}

bool isHex(String input) {
  bool isHex = input.length == 7 && input.contains("#");
  return isHex;
}
