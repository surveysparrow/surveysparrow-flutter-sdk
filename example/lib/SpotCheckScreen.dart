import 'package:example/main.dart';
import 'package:flutter/material.dart';

class SpotCheckScreen extends StatelessWidget {
  const SpotCheckScreen({Key? key}) : super(key: key);

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
                spotCheck.trackEvent("SpotCheckScreen", {"MobileClick": {}});
              },
              child: const Text("SpotCheckScreen"),
            ),
          ),
        ],
      ),
    );
  }
}
