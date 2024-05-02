import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class SpotCheckScreen extends StatelessWidget {

  final SpotCheck spotCheck = SpotCheck(
    email: "gokulkrishna.raju@surveysparrow.com",
    location: const {
      "latitude": 12.946363918641865,
      "longitude": 80.23247606374693
    },
    firstName: "gokulkrishna",
    lastName: "raju",
    phoneNumber: "6383846825",
    targetToken: 'tar-qeaHP85gPG21ZBotb758a7',
    domainName: 'rgk.ap.ngrok.io',
  );

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
            child: ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print("trackEvent('Click')");
                }
                spotCheck.trackEvent("Click");
              },
              child: const Text("SpotCheckScreen"),
            ),
          ),

          spotCheck,
        
        ],
      ),
    );
  }
}
