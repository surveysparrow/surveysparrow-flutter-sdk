import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class SpotCheckScreen extends StatelessWidget {
  final SpotCheck spotCheck = SpotCheck();

  SpotCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    spotCheck.trackScreen("SpotCheckScreen");

    return Scaffold(
      body: Stack(
        children: [
          IconButton(
            padding: const EdgeInsets.only(top: 60, left: 30),
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Center(
            child: TextButton(
              onPressed: () {
                if (kDebugMode) {
                  print("trackEvent('Click')");
                }
                spotCheck.trackEvent("Click");
              },
              child: const Text("SpotCheckScreen"),
            ),
          ),
          SpotCheckWidget(spotCheckController: spotCheck),
        ],
      ),
    );
  }
}
