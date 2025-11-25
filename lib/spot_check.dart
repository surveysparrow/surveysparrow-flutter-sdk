import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/spot_check_state.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';

class SpotCheck extends StatelessWidget {
  SpotCheck({
    Key? key,
    required this.targetToken,
    required this.domainName,
    required this.userDetails,
    this.variables = const {},
    this.customProperties = const {},
    this.spotCheckListener,
  }) : super(key: key) {
    spotCheckState = SpotCheckState(
      targetToken: targetToken,
      domainName: domainName,
      userDetails: userDetails,
      variables: variables,
      customProperties: customProperties,
      spotCheckListener: spotCheckListener,
    );
  }

  final String targetToken;
  final String domainName;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> customProperties;
  final SsSpotcheckListener? spotCheckListener;

  late final SpotCheckState spotCheckState;

  void trackScreen(String screen) async {
    Map<String, dynamic> response =
        await spotCheckState.sendTrackScreenRequest(screen);
    if (response["valid"]) {
      spotCheckState.start();
    } else {
      log("TrackScreen Failed");
    }
  }

  void trackEvent(String screen, Map<String, dynamic> event) async {
    Map<String, dynamic> response =
        await spotCheckState.sendTrackEventRequest(screen, event);
    if (response["valid"]) {
      spotCheckState.start();
    } else {
      log("TrackEvent Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return spotCheckState;
  }
}

class SsNavigationListener extends NavigatorObserver {
  final SpotCheckState state;

  SsNavigationListener(this.state);

  @override
  void didPush(Route route, Route? previousRoute) {
    _handle();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _handle();
  }

  void _handle() {
    if (state.isSpotCheckOpen.value || state.isSpotCheckOpen.value) {
      state.closeSpotCheck();
      state.end(isNavigation: true);
    }
  }
}
