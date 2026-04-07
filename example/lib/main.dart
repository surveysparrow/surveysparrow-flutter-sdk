import 'package:example/SpotCheckScreen.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

void main() {
  runApp(const MyApp());
}

final SpotCheck spotCheck = SpotCheck(
    domainName: "kalai.in.ngrok.io",
    targetToken: "tar-4TtoU3D5mmopzFFRtHdEx7",
    // Should Not Pass userDetails as const
    userDetails: {},
    variables: {},
    customProperties: {},
    spotCheckListener: MySpotcheckListener());

class MySpotcheckListener extends SsSpotcheckListener {
  @override
  Future<void> onSurveyLoaded(Map<String, dynamic> response) async {}

  @override
  Future<void> onSurveyResponse(Map<String, dynamic> response) async {}

  @override
  Future<void> onCloseButtonTap() async {}

  @override
  Future<void> onPartialSubmission(Map<String, dynamic> response) async {}
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    spotCheck.trackScreen("SpotCheckScreen");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyScreen(),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              child ?? const SizedBox(),
              spotCheck,
            ],
          ),
        );
      },
      navigatorObservers: [SsNavigationListener(spotCheck.spotCheckState)],
    );
  }
}

class SurveyScreen extends StatelessWidget {
  SurveyScreen({
    Key? key,
  }) : super(key: key);
  final domainController = TextEditingController();
  final tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    spotCheck.trackScreen("SpotCheckScreen");
    return Scaffold(
      appBar: AppBar(
        title: const Text("SurveySparrow"),
      ),
      body: Builder(
        builder: ((context) => Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SpotCheckScreen(),
                          ),
                        );
                      },
                      child: const Text("SpotCheck"))
                ],
              ),
            )),
      ),
    );
  }
}
