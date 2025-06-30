import 'package:example/SpotCheckScreen.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

void main() {
  runApp(const MyApp());
}

final SpotCheck spotCheck = SpotCheck(
  domainName: "",
  targetToken: "",
  // Should Not Pass userDetails as const
  userDetails: {},
  variables: {},
  customProperties: {},
  sparrowLang: "",
  spotCheckListener:MySpotcheckListener()
);



class MySpotcheckListener extends SsSpotcheckListener {
  @override
  Future<void> onSurveyLoaded(Map<String, dynamic> response) async {
    print("🟢 Loaded: $response");
  }

  @override
  Future<void> onSurveyResponse(Map<String, dynamic> response) async {
    print("✅ Response: $response");
  }

  @override
  Future<void> onCloseButtonTap() async {
    print("❌ Close tapped");
    await Future.delayed(Duration(milliseconds: 1500));
    print("✅ Cleanup completed after delay");
  }

  @override
  Future<void> onPartialSubmission(Map<String, dynamic> response) async {
    print("# Partial Submission");
    await Future.delayed(Duration(milliseconds: 1500));
    print("✅ Response: $response");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox(),
            spotCheck,
          ],
        );
      },
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
