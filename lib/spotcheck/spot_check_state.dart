import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotCheckState extends StatelessWidget {
  SpotCheckState(
      {Key? key,
      required this.email,
      required this.targetToken,
      required this.domainName,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.variables,
      required this.customProperties})
      : super(key: key);

  final String email;
  final String targetToken;
  final String domainName;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;
  double screenHeight = 0;
  double screenWidth = 0;

  final RxBool isValid = false.obs;
  final RxBool isFullScreenMode = false.obs;
  final RxBool isBannerImageOn = false.obs;
  final RxBool isSpotCheckOpen = false.obs;
  final RxBool isCloseButtonEnabled = false.obs;
  final RxMap<String, dynamic> closeButtonStyle = <String, dynamic>{}.obs;
  final RxString position = "top".obs;
  final RxString spotcheckURL = "".obs;
  final RxInt spotcheckID = 0.obs;
  final RxInt spotcheckContactID = 0.obs;
  final RxDouble afterDelay = 0.0.obs;
  final RxInt currentQuestionHeight = 0.obs;
  final RxString triggerToken = "".obs;
  final RxString traceId = "".obs;

  final RxDouble maxHeight = 0.0.obs;
  final RxBool _isAnimated = false.obs;
  final RxBool _isSpotPassed = false.obs;
  final RxBool _isChecksPassed = false.obs;
  final RxList<dynamic> customEventsSpotChecks = [].obs;

  late WebViewController controller;

  void start() {
    Future.delayed(Duration(seconds: afterDelay.value.toInt()), () {
      _isAnimated.value = true;
      isSpotCheckOpen.value = true;
    });
  }

  void end() {
    isSpotCheckOpen.value = false;
  }

  Future<Map<String, dynamic>> sendTrackScreenRequest(String screen) async {
    if (traceId.isEmpty) {
      traceId.value = generateTraceId();
    }

    Map<String, dynamic> payload = {
      "screenName": screen,
      "variables": variables,
      "userDetails": {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
      },
      "visitor": {
        "deviceType": "Mobile",
        "operatingSystem": Platform.operatingSystem,
        "screenResolution": {"height": screenHeight, "width": screenWidth},
        "currentDate": DateTime.now().toIso8601String(),
        "timezone": DateTime.now().timeZoneName,
      },
      "traceId": traceId.value,
      "customProperties": customProperties
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

        if (responseJson?["show"] != null) {
          bool show = responseJson?["show"];

          if (show) {
            setAppearance(responseJson!, screen);
            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..loadRequest(Uri.parse(spotcheckURL.value))
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
              });

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
                  afterDelay.value = double.parse(checkCondition["afterDelay"]);
                }
                if (checkCondition["customEvent"] != null) {
                  customEventsSpotChecks.value = [responseJson!];
                }
              }

              setAppearance(responseJson!, screen);
              controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(const Color(0x00000000))
                ..loadRequest(Uri.parse(spotcheckURL.value))
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
                });

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
              double minDelay = double.maxFinite;

              for (var spotCheck in customEventsSpotChecks) {
                Map<String, dynamic> checks = spotCheck["checks"];
                if (checks.isEmpty) {
                  selectedSpotCheck = spotCheck;
                } else if (checks["afterDelay"] != null) {
                  double delay = double.parse(checks["afterDelay"]);
                  if (minDelay > delay) {
                    minDelay = delay;
                    selectedSpotCheck = spotCheck;
                  }
                }
              }

              if (selectedSpotCheck.isNotEmpty) {
                Map<String, dynamic> checks = selectedSpotCheck["checks"]!;

                if (checks.isNotEmpty) {
                  double delay = double.tryParse(checks["afterDelay"]) ?? 0;
                  afterDelay.value = delay;
                }
              }

              setAppearance(selectedSpotCheck, screen);

              if (selectedSpotCheck.isNotEmpty) {
                controller = WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setBackgroundColor(const Color(0x00000000))
                  ..loadRequest(Uri.parse(spotcheckURL.value))
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
                  });

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
    int intMax = 4294967296;
    var selectedSpotCheckID = intMax;

    if (customEventsSpotChecks.isNotEmpty) {
      for (Map<String, dynamic> spotCheck in customEventsSpotChecks) {
        Map<String, dynamic> checks =
            spotCheck["checks"] ?? spotCheck["checkCondition"];
        if (checks.isNotEmpty) {
          Map<String, dynamic> customEvent = checks["customEvent"];
          if (event.keys.contains(customEvent["eventName"])) {
            selectedSpotCheckID =
                spotCheck["id"] ?? spotCheck["spotCheckId"] ?? intMax;

            if (selectedSpotCheckID != intMax) {
              Map<String, dynamic> payload = {
                "url": screen,
                "variables": variables,
                "userDetails": {
                  "email": email,
                  "firstName": firstName,
                  "lastName": lastName,
                  "phoneNumber": phoneNumber,
                },
                "visitor": {
                  "deviceType": "Mobile",
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
                "customProperties": customProperties
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
                      ..setBackgroundColor(const Color(0x00000000))
                      ..loadRequest(Uri.parse(spotcheckURL.value))
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
                      });
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
                          afterDelay.value =
                              double.parse(checkCondition["afterDelay"]);
                        }
                        if (checkCondition["customEvent"] != null) {
                          var delay =
                              checkCondition["customEvent"]?["delayInSeconds"];
                          afterDelay.value = double.parse(delay ?? "0");
                        }
                      }

                      setAppearance(responseJson!, screen);
                      controller = WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..setBackgroundColor(const Color(0x00000000))
                        ..loadRequest(Uri.parse(spotcheckURL.value))
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
                        });

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
          } else {
            return {"valid": false};
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

    return Obx(() => isSpotCheckOpen.value && currentQuestionHeight.value != 0
        ? AnimatedContainer(
            duration:
                Duration(milliseconds: position.value == "center" ? 1000 : 500),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(
                0.0, isSpotCheckOpen.value ? 0.0 : 2000, 0.0),
            child: Stack(
              children: <Widget>[
                Container(
                  color: const Color.fromARGB(12, 0, 0, 0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Column(
                  mainAxisAlignment: _getAlignment(),
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.06),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      height: isFullScreenMode.value
                          ? screenHeight - 100
                          : math.min(
                              screenHeight - 100,
                              (math.min(currentQuestionHeight.value.toDouble(),
                                      maxHeight.value * screenHeight)) +
                                  (isBannerImageOn.value &&
                                          currentQuestionHeight.value != 0
                                      ? 100
                                      : 0)),
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          WebViewWidget(
                            controller: controller,
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Color(int.parse(isHex(
                                        "0xFF${closeButtonStyle["ctaButton"].toString().replaceAll("#", "")}")
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ))
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
        return MainAxisAlignment.center;
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
  final hexColorRegex = RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$');
  return hexColorRegex.hasMatch(input);
}
