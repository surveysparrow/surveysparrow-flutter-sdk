import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class SpotCheckState extends StatelessWidget {
  SpotCheckState(
      {Key? key,
      required this.targetToken,
      required this.domainName,
      required this.userDetails,
      required this.variables,
      required this.customProperties,
      required this.sparrowLang})
      : super(key: key);

  final String targetToken;
  final String domainName;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;
  double screenHeight = 0;
  double screenWidth = 0;
  Map<String, dynamic> userDetails;
  final String sparrowLang;

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

  late WebViewController controller;
  final RxBool isLoading = true.obs;

  void start() {
    Future.delayed(Duration(seconds: afterDelay.value), () {
      _isAnimated.value = true;
      isSpotCheckOpen.value = true;
    });
  }

  void end() {
    isSpotCheckOpen.value = false;
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null && result.files.isNotEmpty) {
        final fileUris = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!).uri.toString())
            .toList();

        return fileUris;
      }
    } catch (e) {
      log('Error picking Files');
    }

    return [];
  }

  Future<List<String>> _androidImagePicker(FileSelectorParams params) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);
      _isImageCaptureActive.value = false;
      addFileSelectionListener();

      if (pickedFile != null) {
        return [File(pickedFile.path).uri.toString()];
      }
    } catch (e) {
      _isImageCaptureActive.value = false;
      addFileSelectionListener();
      log('Error picking Image');
    }

    return [];
  }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      if (!_isImageCaptureActive.value) {
        await androidController.setOnShowFileSelector(_androidFilePicker);
      } else {
        await androidController.setOnShowFileSelector(_androidImagePicker);
      }
    }
  }

  void _captureImage() {
    _isImageCaptureActive.value = true;
    addFileSelectionListener();
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
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(spotcheckURL.value))
              ..setNavigationDelegate(NavigationDelegate(
                onPageFinished: (url) {
                  isLoading.value = false;
                },
              ))
              ..addJavaScriptChannel("flutterSpotCheckData",
                  onMessageReceived: (JavaScriptMessage response) {
                try {
                  var jsonResponse = json.decode(response.message);
                  log(jsonResponse.toString());
                  if (jsonResponse['type'] == "spotCheckData") {
                    var height =
                        jsonResponse['data']['currentQuestionSize']['height'];
                    currentQuestionHeight.value = height;
                  } else if (jsonResponse['type'] == "surveyCompleted") {
                    end();
                  }
                } catch (e) {
                  log("Error decoding JSON: $e");
                }
              })
              ..addJavaScriptChannel(
                "SsFlutterSdk",
                onMessageReceived: (JavaScriptMessage response) {
                  if (response.message == 'captureImage') {
                    _captureImage();
                  }
                },
              );

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
              controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(spotcheckURL.value))
                ..setNavigationDelegate(NavigationDelegate(
                  onPageFinished: (url) {
                    isLoading.value = false;
                  },
                ))
                ..addJavaScriptChannel("flutterSpotCheckData",
                    onMessageReceived: (JavaScriptMessage response) {
                  try {
                    var jsonResponse = json.decode(response.message);
                    log(jsonResponse.toString());
                    if (jsonResponse['type'] == "spotCheckData") {
                      var height =
                          jsonResponse['data']['currentQuestionSize']['height'];
                      currentQuestionHeight.value = height;
                    } else if (jsonResponse['type'] == "surveyCompleted") {
                      end();
                    }
                  } catch (e) {
                    log("Error decoding JSON: $e");
                  }
                })
                ..addJavaScriptChannel(
                  "SsFlutterSdk",
                  onMessageReceived: (JavaScriptMessage response) {
                    if (response.message == 'captureImage') {
                      _captureImage();
                    }
                  },
                );

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
                controller = WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..loadRequest(Uri.parse(spotcheckURL.value))
                  ..setNavigationDelegate(NavigationDelegate(
                    onPageFinished: (url) {
                      isLoading.value = false;
                    },
                  ))
                  ..addJavaScriptChannel("flutterSpotCheckData",
                      onMessageReceived: (JavaScriptMessage response) {
                    try {
                      var jsonResponse = json.decode(response.message);
                      log(jsonResponse.toString());
                      if (jsonResponse['type'] == "spotCheckData") {
                        var height = jsonResponse['data']['currentQuestionSize']
                            ['height'];
                        currentQuestionHeight.value = height;
                      } else if (jsonResponse['type'] == "surveyCompleted") {
                        end();
                      }
                    } catch (e) {
                      log("Error decoding JSON: $e");
                    }
                  })
                  ..addJavaScriptChannel(
                    "SsFlutterSdk",
                    onMessageReceived: (JavaScriptMessage response) {
                      if (response.message == 'captureImage') {
                        _captureImage();
                      }
                    },
                  );

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
                    controller = WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(spotcheckURL.value))
                      ..setNavigationDelegate(NavigationDelegate(
                        onPageFinished: (url) {
                          isLoading.value = false;
                        },
                      ))
                      ..addJavaScriptChannel("flutterSpotCheckData",
                          onMessageReceived: (JavaScriptMessage response) {
                        try {
                          var jsonResponse = json.decode(response.message);
                          log(jsonResponse.toString());
                          if (jsonResponse['type'] == "spotCheckData") {
                            var height = jsonResponse['data']
                                ['currentQuestionSize']['height'];
                            currentQuestionHeight.value = height;
                          } else if (jsonResponse['type'] ==
                              "surveyCompleted") {
                            end();
                          }
                        } catch (e) {
                          log("Error decoding JSON: $e");
                        }
                      })
                      ..addJavaScriptChannel(
                        "SsFlutterSdk",
                        onMessageReceived: (JavaScriptMessage response) {
                          if (response.message == 'captureImage') {
                            _captureImage();
                          }
                        },
                      );
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
                      controller = WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..loadRequest(Uri.parse(spotcheckURL.value))
                        ..setNavigationDelegate(NavigationDelegate(
                          onPageFinished: (url) {
                            isLoading.value = false;
                          },
                        ))
                        ..addJavaScriptChannel("flutterSpotCheckData",
                            onMessageReceived: (JavaScriptMessage response) {
                          try {
                            var jsonResponse = json.decode(response.message);
                            log(jsonResponse.toString());
                            if (jsonResponse['type'] == "spotCheckData") {
                              var height = jsonResponse['data']
                                  ['currentQuestionSize']['height'];
                              currentQuestionHeight.value = height;
                            } else if (jsonResponse['type'] ==
                                "surveyCompleted") {
                              end();
                            }
                          } catch (e) {
                            log("Error decoding JSON: $e");
                          }
                        })
                        ..addJavaScriptChannel(
                          "SsFlutterSdk",
                          onMessageReceived: (JavaScriptMessage response) {
                            if (response.message == 'captureImage') {
                              _captureImage();
                            }
                          },
                        );

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

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;

    return Obx(() => isSpotCheckOpen.value
        ? Stack(
            children: <Widget>[
              isLoading.value
                  ? Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(85, 0, 0, 0),
                      ),
                      child: const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          )),
                    )
                  : Container(
                      color: const Color.fromARGB(85, 0, 0, 0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: screenHeight * 0.945,
                  child: Column(
                    mainAxisAlignment: _getAlignment(),
                    children: [
                      SizedBox(
                        height: isFullScreenMode.value
                            ? screenHeight * 0.945
                            : math.min(
                                screenHeight,
                                (math.min(
                                        currentQuestionHeight.value.toDouble(),
                                        maxHeight.value * screenHeight)) +
                                    (isBannerImageOn.value &&
                                            currentQuestionHeight.value != 0
                                        ? useMobileLayout
                                            ? 100
                                            : 0
                                        : 0)),
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            WebViewWidget(
                              controller: controller,
                            ),
                            (isCloseButtonEnabled.value && !isLoading.value)
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
                                        spotcheckID.value = 0;
                                        position.value = "";
                                        currentQuestionHeight.value = 0;
                                        isCloseButtonEnabled.value = false;
                                        closeButtonStyle.value = {};
                                        spotcheckContactID.value = 0;
                                        spotcheckURL.value = "";
                                        end();
                                      },
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink());
  }

  MainAxisAlignment _getAlignment() {
    switch (position.value) {
      case "top":
        return MainAxisAlignment.start;
      case "center":
        return MainAxisAlignment.center;
      case "bottom":
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.end;
    }
  }

  void setAppearance(Map<String, dynamic> responseJson, String screen) {
    if (responseJson.isNotEmpty) {
      if (responseJson["appearance"] != null) {
        String tposition = responseJson["appearance"]?["position"];
        switch (tposition) {
          case "top_full":
            position.value = "top";
            break;
          case "center_center":
            position.value = "center";
            break;
          case "bottom_full":
            position.value = "bottom";
            break;
          default:
        }
        isCloseButtonEnabled.value = responseJson["appearance"]?["closeButton"];
        closeButtonStyle.value =
            responseJson["appearance"]?["colors"]?["overrides"] ?? {};
        Map<String, dynamic> cardProp =
            responseJson["appearance"]?["cardProperties"];
        var mxHeight = double.parse(cardProp["maxHeight"].toString());
        maxHeight.value = mxHeight / 100;
        isFullScreenMode.value =
            responseJson["appearance"]?["mode"] as String == "fullScreen"
                ? true
                : false;
        isBannerImageOn.value =
            responseJson["appearance"]?["bannerImage"]?["enabled"];
      }

      spotcheckID.value = responseJson["spotCheckId"] ?? responseJson["id"];
      spotcheckContactID.value = responseJson["spotCheckContactId"] ??
          responseJson["spotCheckContact"]?["id"];
      triggerToken.value = responseJson["triggerToken"] ?? "";
      spotcheckURL.value =
          "https://$domainName/n/spotcheck/${triggerToken.value}?spotcheckContactId=${spotcheckContactID.value}&traceId=${traceId.value}&spotcheckUrl=$screen";

      variables.forEach((key, value) =>
          spotcheckURL.value = "${spotcheckURL.value}&$key=$value");

      if (sparrowLang.isNotEmpty) {
        spotcheckURL.value = "${spotcheckURL.value}&sparrowLang=$sparrowLang";
      }

      log(spotcheckURL.value);
    }
  }

  void closeSpotCheck() async {
    try {
      Map<String, dynamic> payload = {
        "traceId": traceId.value,
        "triggerToken": triggerToken.value
      };

      final response = await http.put(
        Uri.parse(
            "https://$domainName/api/internal/spotcheck/dismiss/$spotcheckContactID"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data["success"]) {
          log("SpotCheck Closed");
        }
      }
    } catch (error) {
      log("Error parsing JSON: $error");
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
