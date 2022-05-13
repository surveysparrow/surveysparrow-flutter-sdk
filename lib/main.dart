// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/embbeded.dart';
import 'package:my_app/otherSurvey.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

Future<void> main() async {
// Do whatever you need to do here
  var surveyData = await fetchAlbumMain();
  return runApp(MyApp(surveyData: surveyData));
}

class MyApp extends StatelessWidget {
  final Map<dynamic, dynamic> surveyData;
  const MyApp({Key? key, required this.surveyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Color.fromARGB(255, 255, 243, 7),
                  ),
                  onRatingUpdate: (rating) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      enableDrag: true,
                      isDismissible: true,
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Container(
                            height: 500,
                            child: SurveyModal(
                              token: 'tt-3d4efc',
                              euiTheme: const {
                                "rating": {
                                  "showNumber": true,
                                },
                                "bottomSheet": {
                                  "showPadding": true,
                                  "direction": "horizontal"
                                }
                              },
                              surveyData: surveyData,
                              onSubmitCloseModalFunction: () {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              },
                              // tt-3d4efc
                              firstQuestionAnswer: rating,
                              customParams: {
                                'tester': 'sachin 2',
                                'ntesterR': 'sachin 3'
                              },
                              currentlyCollectedAnswers: (val) {
                                print("currently collected answer ${val} ");
                              },
                              allCollectedAnswers: (val) {
                                print(" All collected answer ${val} ");
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Text("test", style: TextStyle(fontFamily: 'Antons')),
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      enableDrag: true,
                      isDismissible: true,
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Container(
                            height: 500,
                            child: SurveyModal(
                              // surveyData: surveyData,
                              token: 'tt-5f4a66',
                              onSubmitCloseModalFunction: () {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              },
                              firstQuestionAnswer: rating,
                              euiTheme: const {
                                'phoneNumber': {'defaultNumber': '65'}
                              },
                              customParams: {
                                'test': 'sachin 2',
                                'ntesterR': 'sachin 3'
                              },
                              currentlyCollectedAnswers: (val) {
                                print("currently collected answer ${val} ");
                              },
                              allCollectedAnswers: (val) {
                                print("All collected answer ${val} ");
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: (() {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Page2()));
                }),
                child: Text("embbed survey"),
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
            ],
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
                          token: 'tt-0e48de',
                          euiTheme: const {
                            "question": {
                              "questionNumberFontSize": 18.0,
                              "questionHeadingFontSize": 28.0,
                              "questionDescriptionFontSize": 18.0,
                            },
                            "rating": {
                              "showNumber": true,
                              "customRatingSVGUnselected":
                                  '<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11.656 15.75H6.344a1.688 1.688 0 0 1-1.683-1.558l-.723-9.41h10.124l-.723 9.41a1.687 1.687 0 0 1-1.683 1.558v0ZM15 4.781H3M6.89 2.25h4.22a.844.844 0 0 1 .843.844V4.78H6.047V3.094a.844.844 0 0 1 .844-.844v0Zm.61 10.5h3" stroke="gray" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                              "customRatingSVGSelected":
                                  '<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11.656 15.75H6.344a1.688 1.688 0 0 1-1.683-1.558l-.723-9.41h10.124l-.723 9.41a1.687 1.687 0 0 1-1.683 1.558v0ZM15 4.781H3M6.89 2.25h4.22a.844.844 0 0 1 .843.844V4.78H6.047V3.094a.844.844 0 0 1 .844-.844v0Zm.61 10.5h3" stroke="#EC6772" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                              "svgHeight": 50.0,
                              "svgWidth": 50.0,
                            },
                            "opnionScale": {
                              "outerBlockSizeWidth": 90.0,
                              "outerBlockSizeHeight": 170.0,
                              "innerBlockSizeWidth": 80.0,
                              "innerBlockSizeHeight": 80.0,
                            },
                            "font": "Antons",
                            "bottomSheet": {
                              "showPadding": false,
                            }
                          },
                          customParams: {
                            'tester': 'sachin 2',
                            'ntesterR': 'sachin 3'
                          },
                          currentlyCollectedAnswers: (val) {
                            print("currently collected answer ${val} ");
                          },
                          allCollectedAnswers: (val) {
                            print("All collected answer ${val} ");
                          },
                          onSubmitCloseModalFunction: () {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.of(context).pop();
                            });
                          },
                        )),
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
  final Map<String, String> customParams = {'tester': 'some test val'};

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
                      token: 'tt-3d4efc', customParams: {'ntesterR': 'sachin'}),
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
      child:
          SurveyModal(token: 'tt-3d4efc', customParams: {'ntesterR': 'sachin'}),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchAlbumMain() async {
  var url1 =
      'http://sample.surveysparrow.test/api/internal/offline-app/v3/get-sdk-data/tt-3d4efc';
  var url2 =
      'https://madbee.surveysparrow.com/api/internal/offline-app/v3/get-sdk-data/tt-3d4efc';

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


// extra parameters 

// "skipButton":{
//                                   "fontSize": 18.0,
//                                 },
//                                 "nextButton":{
//                                   "fontSize":29.0,
//                                   "width":180.0,
//                                   "iconSize": 32.0,
//                                 },
//                                 "rating": {
//                                   "showNumber": true,
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

