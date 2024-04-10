import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveysparrow_flutter_sdk/spotcheck/helpers.dart';
import 'package:surveysparrow_flutter_sdk/spotcheck/spotCheckWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotCheck extends GetxController {
  var isOpen = false.obs;
  var spotCheckURL = "".obs;
  var position = "".obs;
  var maxHeight = 0.obs;
  var minHeight = 0.obs;
  var email = "gokulkrishna.raju@surveysparrow.com";
  var firstName = "gokulkrishna";
  var lastName = "raju";
  var phoneNumber = "6383846825";
  var screenHeight = 0;
  var screenWidth = 0;
  var spotCheckId = "".obs;

  void trackEvent(String event) async {
    Map<String, dynamic> payload = {
      "url": "",
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
            "latitude": await getLatitude(),
            "longitude": await getLongitude(),
          }
        },
        "ipAddress": await fetchIPAddress() ?? "",
        "deviceType": Platform.isAndroid ? 'Android' : 'iOS',
        "operatingSystem": Platform.operatingSystem,
        "browser": "",
        "browserLanguage": "",
        "screenResolution": {"height": screenHeight, "width": screenWidth},
        "userAgent": "",
        "currentDate": getCurrentDate(),
        "timezone": DateTime.now().timeZoneName,
      }
    };

    // bool allow = await sendRequest(payload);
    // log(allow.toString());
    // if (allow) {
    //   Future.delayed(const Duration(milliseconds: 5), () {
    //     isOpen.value = true;
    //   });
    // }
  }

  void trackScreen(String screen) async {
    Map<String, dynamic> payload = {
      "url": screen,
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
            "latitude": await getLatitude(),
            "longitude": await getLongitude(),
          }
        },
        "ipAddress": await fetchIPAddress() ?? "",
        "deviceType": "Mobile",
        "operatingSystem": Platform.operatingSystem,
        "browser": "",
        "browserLanguage": "",
        "screenResolution": {"height": screenHeight, "width": screenWidth},
        "userAgent": "",
        "currentDate": getCurrentDate(),
        "timezone": DateTime.now().timeZoneName,
      }
    };

    Map<String, dynamic> response = await sendRequest(payload);
    log(response["valid"].toString());
    if (response["valid"]) {
      spotCheckId.value = response["spotCheckId"];
      Future.delayed(const Duration(seconds: 1), () {
        isOpen.value = true;
      });
    }
  }
}

class SpotCheckWidget extends StatelessWidget {
  final SpotCheck spotCheckController;

  const SpotCheckWidget({Key? key, required this.spotCheckController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void close() {
      spotCheckController.isOpen.value = false;
    }

    return Obx(
      () => spotCheckController.isOpen.value
          ? SpotCheckInternalWidget(spotCheckId: spotCheckController.spotCheckId.value, close: close)
          : const SizedBox(),
    );
  }
}
