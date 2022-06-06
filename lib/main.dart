// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/embbeded.dart';
import 'package:my_app/otherSurvey.dart';
import 'package:my_app/preLoadedSurvey.dart';
import 'package:my_app/surveyScreen.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

Future<void> main() async {
// Do whatever you need to do here
  var surveyData = {};
  return runApp(MyApp(surveyData: surveyData));
}

class MyApp extends StatelessWidget {
  final Map<dynamic, dynamic> surveyData;
  MyApp({Key? key, required this.surveyData}) : super(key: key);

  var obj = FirstQuestionAnswer(pageNumber: 1, answers: [
    Answer(
        rating: CustomRating(key: 1304, data: 3, timeTaken: 1, skipped: false)),
    Answer(
        opnionScale: CustomOpinionScale(
            key: 1305, data: 6, timeTaken: 1, skipped: false))
  ]);

  final tokenController = TextEditingController();
  final domainController = TextEditingController();
  final customThemeController = TextEditingController();
  final customParamController = TextEditingController();

  final Map<String, dynamic> testJosn = {
    "question": {"questionNumberFontSize": 20.0}
  };

//'tt-04bfb5'
  @override
  Widget build(BuildContext context) {
    var survey_theme = CustomSurveyTheme.fromMap(testJosn);
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                          controller: tokenController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Token',
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextField(
                          controller: domainController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Domain',
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextField(
                          controller: customThemeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Custom Theme',
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextField(
                          controller: customParamController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Custom Param',
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          onPressed: (() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SurveyScreen(),
                              ),
                            );
                          }),
                          child: Text("load survey"),
                        ),
                        ElevatedButton(
                          onPressed: (() {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      height: 510,
                                      child: (Page3()),
                                    ),
                                  );
                                });
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (context) => FullPage3()));
                          }),
                          child: Text("Custom survey"),
                        )
                      ]),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    insetPadding: EdgeInsets.all(0),
                    content: Container(
                      width: 350,
                      height: 450,
                      child: SurveyModal(
                        token: 'tt-04bfb5',
                        domain: 'sample.surveysparrow.test',
                        variables: {
                          'tester': 'sachin 2',
                          'ntesterR': 'sachin 3'
                        },
                        onNext: (val) {
                          print("currently collected answer ${val} ");
                        },
                        onSubmit: (val) {
                          print("All collected answer ${val} ");
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class MainButton extends StatefulWidget {
  const MainButton({Key? key}) : super(key: key);

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  late Future<Map<dynamic, dynamic>> testeru;
  final Map<String, String> variables = {'tester': 'some test val'};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: const Text("open Survey",
            style: TextStyle(fontFamily: 'PaletteMosaic')),
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: SurveyModal(
                      token: 'tt-3d4efc',
                      domain: 'sample.surveysparrow.test',
                      variables: {'ntesterR': 'sachin'}),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TestWiddget extends StatefulWidget {
  const TestWiddget({Key? key}) : super(key: key);

  @override
  State<TestWiddget> createState() => _TestWiddgetState();
}

class _TestWiddgetState extends State<TestWiddget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SurveyModal(
          token: 'tt-3d4efc',
          domain: 'sample.surveysparrow.test',
          variables: {'ntesterR': 'sachin'}),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchAlbumMain() async {
  var url1 =
      'http://sample.surveysparrow.test/api/internal/sdk/get-survey/tt-04bfb5';
  var url2 =
      'https://madbee.surveysparrow.com/api/internal/sdk/get-survey/tt-04bfb5';

  final response = await http.get(Uri.parse(url2));
  print('inital load called');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsedJson = jsonDecode(response.body);
    print('loaded 1 parsed json ${parsedJson}');
    return parsedJson;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}







// Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child: RatingBar.builder(
//                   initialRating: 0,
//                   minRating: 1,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Color.fromARGB(255, 255, 243, 7),
//                   ),
//                   onRatingUpdate: (rating) {
//                     showModalBottomSheet(
//                       isScrollControlled: true,
//                       enableDrag: true,
//                       isDismissible: true,
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Padding(
//                           padding: MediaQuery.of(context).viewInsets,
//                           child: Container(
//                             height: 500,
//                             child: SurveyModal(
//                               token: 'tt-04bfb5',
//                               domain: 'sample.surveysparrow.test',
//                               survey: surveyData,
//                               // tt-3d4efc
//                               firstQuestionAnswer: FirstQuestionAnswer(
//                                 pageNumber: 1,
//                                 answers: [
//                                   Answer(
//                                     rating: CustomRating(
//                                         key: 1304,
//                                         data: rating.toInt(),
//                                         timeTaken: 1,
//                                         skipped: false),
//                                   ),
//                                   Answer(
//                                     opnionScale: CustomOpinionScale(
//                                         key: 1305,
//                                         data: 6,
//                                         timeTaken: 1,
//                                         skipped: false),
//                                   )
//                                 ],
//                               ),
//                               variables: {
//                                 'tester': 'sachin 2',
//                                 'ntesterR': 'sachin 3'
//                               },
//                               onNext: (val) {
//                                 print("currently collected answer ${val} ");
//                               },
//                               onSubmit: (val) {
//                                 print(" All collected answer 88 ${val} ");
                                // Future.delayed(
                                //     const Duration(milliseconds: 500), () {
                                //   Navigator.pop(context);
                                // });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               Text("test", style: TextStyle(fontFamily: 'Antons')),
//               Center(
//                 child: RatingBar.builder(
//                   initialRating: 0,
//                   minRating: 1,
//                   direction: Axis.horizontal,
//                   allowHalfRating: true,
//                   itemCount: 5,
//                   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Colors.amber,
//                   ),
//                   onRatingUpdate: (rating) {
//                     showModalBottomSheet(
//                       isScrollControlled: true,
//                       enableDrag: true,
//                       isDismissible: true,
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Padding(
//                           padding: MediaQuery.of(context).viewInsets,
//                           child: Container(
//                             height: 500,
//                             child: SurveyModal(
//                               // surveyData: surveyData,
//                               token: 'tt-04bfb5',
//                               domain: 'sample.surveysparrow.test',
//                               firstQuestionAnswer: FirstQuestionAnswer(
//                                 pageNumber: 2,
//                                 answers: [
//                                   Answer(
//                                     rating: CustomRating(
//                                       key: 1304,
//                                       data: rating.toInt(),
//                                       timeTaken: 1,
//                                       skipped: false,
//                                     ),
//                                   ),
//                                   Answer(
//                                     opnionScale: CustomOpinionScale(
//                                       key: 1305,
//                                       data: 5,
//                                       timeTaken: 1,
//                                       skipped: false,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               customSurveyTheme: CustomSurveyTheme(
//                                   animationDirection: "horizontal",
//                                   phoneNumber:
//                                       PhoneNumber(defaultNumber: "65")),
//                               variables: {
//                                 'test': 'sachin 2',
//                                 'ntesterR': 'sachin 3',
//                                 'numberparam': '21',
//                               },
//                               onNext: (val) {
//                                 print("currently collected answer ${val} ");
//                               },
//                               onSubmit: (val) {
//                                 print("All collected answer ${val} ");
//                                 Future.delayed(
//                                     const Duration(milliseconds: 500), () {
//                                   Navigator.of(context).pop();
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
              // ElevatedButton(
              //   onPressed: (() {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => Page2(
              //             token: 'tt-04bfb5',
              //             domain: "sample.surveysparrow.test"),
              //       ),
              //     );
              //   }),
              //   child: Text("embbed survey"),
              // ),
//               ElevatedButton(
//                 onPressed: (() {
//                   showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       builder: (BuildContext context) {
//                         return Padding(
//                           padding: MediaQuery.of(context).viewInsets,
//                           child: Container(
//                             height: 510,
//                             child: (Page3()),
//                           ),
//                         );
//                       });
//                   // Navigator.of(context).push(
//                   //     MaterialPageRoute(builder: (context) => FullPage3()));
//                 }),
//                 child: Text("Custom survey"),
//               )
//             ],
//           )


// extra parameters 

// "skipButton":{
//   "fontSize": 18.0,
//                                 },
//                                 "nextButton":{
//                                   "fontSize":29.0,
//                                   "width":180.0,
//                                   "iconSize": 32.0,
//                                 },
//                                 "rating": {
//                                   "hasNumber": true,
//                                   "svgHeight": 50.0,
//                                   "svgWidth": 50.0,
//                                 },
//                                 "opnionScale": {
//                                   "outerBlockSizeWidth": 60.0,
//                                   "outerBlockSizeHeight": 75.0,
//                                   "innerBlockSizeWidth": 50.0,
//                                   "innerBlockSizeHeight": 50.0,
//                                   "labelFontSize": 15.0,
//                                   "numberFontSize": 14.0,
//                                 },
//                                 "question": {
//                                   "questionNumberFontSize": 18.0,
//                                   "questionHeadingFontSize": 28.0,
//                                   "questionDescriptionFontSize": 18.0,
//                                 },
//                                 "bottomSheet": {
//                                   "showPadding": true,
//                                   "direction": "horizontal",
//                                   "navigationButtonSize":52.0,
//                                   "brandingLogoHeight":35.0,
//                                   "brandingLogoWidth":175.0,
//                                 }

