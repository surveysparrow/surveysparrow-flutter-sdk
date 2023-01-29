import 'dart:convert';

import 'package:example/customSurvey.dart';
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
        title: Text("SurveySparrow"),
      ),
      body: Builder(
        builder: ((context) => Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Domain"),
                    TextField(
                      controller: domainController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Token"),
                    TextField(
                      controller: tokenController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Custom Theme"),
                    TextField(
                      controller: customThemeFieldController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final Map<String, dynamic> testJosn =
                            customThemeFieldController.text == null ||
                                    customThemeFieldController.text == ''
                                ? {}
                                : json.decode(customThemeFieldController.text);
                        print("Theme to load ${testJosn} ");
                        var survey_theme = CustomSurveyTheme.fromMap(testJosn);
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
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
                                customSurveyTheme: survey_theme,
                                onNext: (val) {
                                  print("Currently collected answer ${val} ");
                                },
                                onError: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.of(context).pop();
                                  });
                                },
                                onSubmit: (val) {
                                  print("All collected answer ${val} ");
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
                      child: Text("open survey modal"),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
