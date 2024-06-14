import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surveysparrow_flutter_sdk/spotcheck/spot_check_state.dart';

class SpotCheck extends StatelessWidget {
  SpotCheck(
      {Key? key,
      required this.targetToken,
      required this.domainName,
      this.email = "",
      this.firstName = "",
      this.lastName = "",
      this.phoneNumber = "",
      this.variables = const {},
      this.customProperties = const {}
      })
      : super(key: key) {
    spotCheckState = SpotCheckState(
      email: email,
      targetToken: targetToken,
      domainName: domainName,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      variables: variables,
      customProperties: customProperties,
    );
  }

  final String email;
  final String targetToken;
  final String domainName;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;

  late final SpotCheckState spotCheckState;

  void trackScreen(String screen) async {
    Map<String, dynamic> response =
        await spotCheckState.sendTrackScreenRequest(screen);
    if (response["valid"]) {
      Future.delayed(const Duration(seconds: 1), () {
        spotCheckState.start();
      });
    } else {
      log("TrackScreen Failed");
    }
  }

  void trackEvent(String screen, Map<String, dynamic> event) async {
    Map<String, dynamic> response =
        await spotCheckState.sendTrackEventRequest(screen, event);
    if (response["valid"]) {
      Future.delayed(const Duration(seconds: 1), () {
        spotCheckState.start();
      });
    } else {
      log("TrackEvent Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return spotCheckState;
  }
}