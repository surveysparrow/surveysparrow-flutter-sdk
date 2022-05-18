import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("embbed Text"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Builder(
        builder: ((context) => Container(
              width: double.infinity,
              height: double.infinity,
              child: SurveyModal(
                // surveyData: surveyData,
                token: 'tt-0e48de',
                onSubmitCloseModalFunction: () {
                  Navigator.of(context).pop();
                },
                customParams: {'tester': 'sachin 2', 'ntesterR': 'sachin 3'},
                currentlyCollectedAnswers: (val) {
                  print(
                      " 1190kkl from main currently collected answer ${val} ");
                },
                allCollectedAnswers: (val) {
                  print(
                      " 1190--2 from main currently collected answer ${val} ");
                },
              ),
            )),
      ),
    );
  }
}
