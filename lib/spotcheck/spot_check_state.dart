import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SpotCheckState extends StatelessWidget {
  SpotCheckState({
    Key? key,
    required this.email,
    required this.targetToken,
    required this.domainName,
    this.firstName = "",
    this.lastName = "",
    this.phoneNumber = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
  }) : super(key: key);

  final String email;
  final String targetToken;
  final String domainName;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  late double screenHeight;
  late double screenWidth;

  final RxBool isValid = false.obs;
  final RxBool isCloseButtonEnabled = false.obs;
  final RxBool isSpotCheckOpen = false.obs;
  final RxString position = "top".obs;
  final RxString spotcheckURL = "".obs;
  final RxInt spotcheckID = 0.obs;
  final RxInt spotcheckContactID = 0.obs;
  final RxDouble afterDelay = 0.0.obs;

  final RxBool _isAnimated = false.obs;
  final RxBool _isSpotPassed = false.obs;
  final RxBool _isChecksPassed = false.obs;
  final RxList<Map<String, dynamic>> _multiShowSpotCheck =
      [<String, dynamic>{}].obs;
  late WebViewController controller;

  void start() {
    Future.delayed(const Duration(seconds: 1), () {
      _isAnimated.value = true;
      isSpotCheckOpen.value = true;
    });
  }

  void end() {
    isSpotCheckOpen.value = false;
  }

  Future<Map<String, dynamic>> sendRequest(
      {String? screen, String? event}) async {
    final Uri url = Uri.parse(
        'https://$domainName/api/internal/spotcheck/widget/$targetToken/properties');

    Map<String, dynamic> payload = {
      "screenName": screen,
      "variables": {},
      "userDetails": {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
      },
      "visitor": {
        "location": {
          "coords": {
            "latitude": latitude,
            "longitude": longitude,
          }
        },
        "ipAddress": await fetchIPAddress() ?? "",
        "deviceType": "Mobile",
        "operatingSystem": Platform.operatingSystem,
        "screenResolution": {"height": screenHeight, "width": screenWidth},
        "currentDate": DateTime.now().toIso8601String(),
        "timezone": DateTime.now().timeZoneName,
      }
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? json = jsonDecode(response.body);

        if (json?["show"] != null) {
          bool show = json?["show"];

          if (show) {
            spotcheckID.value = json?["spotCheckId"];
            spotcheckContactID.value = json?["spotCheckContactId"];
            spotcheckURL.value =
                "https://$domainName/n/spotcheck/${spotcheckID.value}?spotcheckContactId=${spotcheckContactID.value}";

            controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..loadRequest(Uri.parse(spotcheckURL.value));

            if (json?["appearance"] != null) {
              String tposition = json?["appearance"]?["position"];
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
              isCloseButtonEnabled.value = json?["appearance"]?["closeButton"];
            }

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
          if (json?["checkPassed"] != null) {
            bool checkPassed = json?["checkPassed"];

            if (checkPassed) {
              spotcheckID.value = json?["spotCheckId"];
              spotcheckContactID.value = json?["spotCheckContactId"];
              spotcheckURL.value =
                  "https://$domainName/n/spotcheck/${spotcheckID.value}?spotcheckContactId=${spotcheckContactID.value}";

              controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(const Color(0x00000000))
                ..loadRequest(Uri.parse(spotcheckURL.value));

              if (json?["checkCondition"] != null) {
                Map<String, dynamic> checkCondition = json?["checkCondition"];
                if (checkCondition["afterDelay"] != null) {
                  afterDelay.value = double.parse(checkCondition["afterDelay"]);
                }
              }

              if (json?["appearance"] != null) {
                String tposition = json?["appearance"]?["position"];
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
                isCloseButtonEnabled.value =
                    json?["appearance"]?["closeButton"];
              }

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
          log("Info: MultiShow Received");
//TODO:  multi show
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

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Obx(() => isSpotCheckOpen.value
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
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          WebViewWidget(
                            controller: controller,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: end,
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
}

Future<String?> fetchIPAddress() async {
  try {
    final response =
        await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['ip'];
    } else {
      log('Failed to fetch IP address: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    log('Error fetching IP address: $e');
    return null;
  }
}
