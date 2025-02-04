import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class SurveyThemeScreen extends StatelessWidget {
  SurveyThemeScreen({
    Key? key,
  }) : super(key: key);
  final domainController = TextEditingController();
  final tokenController = TextEditingController();
  final customThemeFieldController = TextEditingController();

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
                  const Text("Domain"),
                  TextField(
                    controller: domainController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Token"),
                  TextField(
                    controller: tokenController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Custom Theme"),
                  TextField(
                    controller: customThemeFieldController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final Map<String, dynamic> testJosn =
                          customThemeFieldController.text == ''
                              ? {}
                              : json.decode(customThemeFieldController.text);
                      log("Theme to load $testJosn ");
                      var surveyTheme = CustomSurveyTheme.fromMap(testJosn);
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 500,
                            child: SurveyModal(
                              token: tokenController
                                  .text, // give your token 'tt-5466fc'
                              domain: domainController
                                  .text, // give your domain name
                              variables: const {
                                "custom_name": "surveysparrow",
                                "custom_number": "2"
                              },
                              customSurveyTheme: surveyTheme,
                              onNext: (val) {
                                log("Currently collected answer $val ");
                              },
                              onError: () {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              },
                              onSubmit: (val) {
                                log("All collected answer $val ");
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("open survey modal"),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
