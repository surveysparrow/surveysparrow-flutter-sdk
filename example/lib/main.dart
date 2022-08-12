import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SurveyScreen(),
    );
  }
}

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SurveySparrow"),
      ),
      body: Builder(
        builder: ((context) => Center(
              child: Container(
                child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            width: double.infinity,
                            height: 500,
                            child: SurveyModal(
                              token: 'tt-0207b6', // give your token
                              domain:
                                  'sample.surveysparrow.com', // give your domain name
                              variables: const {
                                "custom_name": "surveysparrow",
                                "custom_number": "2"
                              },
                              firstQuestionAnswer: FirstQuestionAnswer(
                                pageNumber: 1,
                                answers: [
                                  Answer(
                                    opnionScale: CustomOpinionScale(
                                      key: 4646744,
                                      data: 2,
                                      timeTaken: 1,
                                      skipped: false,
                                    ),
                                  ),
                                ],
                              ),
                              onNext: (val) {
                                print("Currently collected answer ${val} ");
                              },
                              onError: () {
                                Navigator.pop(context);
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
                    child: Text("open survey modal")),
              ),
            )),
      ),
    );
  }
}
