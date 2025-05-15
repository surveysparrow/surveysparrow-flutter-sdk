import 'package:example/SpotCheckScreen.dart';
import 'package:flutter/material.dart';
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
);

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
        return Scaffold(
          body: Stack(
            children: [
              child ?? const SizedBox(),
              spotCheck,
            ],
          ),
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