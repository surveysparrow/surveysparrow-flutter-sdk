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

// void main() async {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  final Map<dynamic, dynamic> surveyData;
  const MyApp({Key? key, required this.surveyData}) : super(key: key);

  closeModalThing() {
    print("modal is closed");
  }

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
                                SurveyModal.testFunc();
                                print(
                                    " 1190kkl from main currently collected answer ${val} ");
                              },
                              allCollectedAnswers: (val) {
                                print(
                                    " 1190--2 from main currently collected answer ${val} ");
                              },
                            ),
                          ),
                        );
                      },
                    ).whenComplete(this.closeModalThing);
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
                                'phoneNumber':{
                                  'defaultNumber':'65'
                                }
                              },
                              customParams: {
                                'test': 'sachin 2',
                                'ntesterR': 'sachin 3'
                              },
                              currentlyCollectedAnswers: (val) {
                                print(
                                    " 1190kkl from main currently collected answer ${val} ");
                              },
                              allCollectedAnswers: (val) {
                                print(
                                    " 1190--2 from main currently collected answer ${val} ");
                              },
                            ),
                          ),
                        );
                      },
                    ).whenComplete(this.closeModalThing);
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
                              print(
                                  " 1190kkl from main currently collected answer ${val} ");
                            },
                            allCollectedAnswers: (val) {
                              print(
                                  " 1190--2 from main currently collected answer ${val} ");
                            },
                            onSubmitCloseModalFunction: () {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              },
                          )),
                    );
                  });

              // SurveyModal(
              //             euiTheme: const {
              //               "rating": {
              //                 "showNumber": true,
              //               },
              //               "bottomSheet": {
              //                 "showPadding": false,
              //               }
              //             },
              //             customParams: {
              //               'tester': 'sachin 2',
              //               'ntesterR': 'sachin 3'
              //             },
              //             currentlyCollectedAnswers: (val) {
              //               print(
              //                   " 1190kkl from main currently collected answer ${val} ");
              //             },
              //             allCollectedAnswers: (val) {
              //               print(
              //                   " 1190--2 from main currently collected answer ${val} ");
              //             },
              //           )

              // showModalBottomSheet(
              //     isScrollControlled: true,
              //     enableDrag: true,
              //     isDismissible: true,
              //     context: context,
              //     builder: (BuildContext context) {
              //       return Padding(
              //         padding: MediaQuery.of(context).viewInsets,
              //         child: Container(
              //           height: MediaQuery.of(context).size.height * 0.50,
              //           child: SurveyModal(
              //             customParams: {'tester': 'sachin 2'},
              //             currentlyCollectedAnswers: (val) {
              //               print(
              //                   " 1190kkl from main currently collected answer ${val} ");
              //             },
              //             allCollectedAnswers: (val) {
              //               print(
              //                   " 1190--2 from main currently collected answer ${val} ");
              //             },
              //           ),
              //         ),
              //       );
              //     },
              //   ).whenComplete(this.closeModalThing);
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
      child: SurveyModal(
          token: 'tt-3d4efc', customParams: {'ntesterR': 'sachin'}),
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

// container specific code

// Container(
//               width: 350,
//               height: 500,
//               child: SurveyModal(
//                 customParams: {'tester': 'sachin 2'},
//                 currentlyCollectedAnswers: (val) {
//                   print(
//                       " 1190kkl from main currently collected answer ${val} ");
//                 },
//                 allCollectedAnswers: (val) {
//                   print(
//                       " 1190--2 from main currently collected answer ${val} ");
//                 },
//               ),
//             )

// rating specific code

// RatingBar.builder(
//               initialRating: 0,
//               minRating: 1,
//               direction: Axis.horizontal,
//               allowHalfRating: true,
//               itemCount: 5,
//               itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//               itemBuilder: (context, _) => Icon(
//                 Icons.star,
//                 color: Colors.amber,
//               ),
//               onRatingUpdate: (rating) {
//                 showModalBottomSheet(
//                   isScrollControlled: true,
//                   enableDrag: true,
//                   isDismissible: true,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return Padding(
//                       padding: MediaQuery.of(context).viewInsets,
//                       child: Container(
//                         height: 500,
//                         child: SurveyModal(
//                           firstQuestionAnswer: rating - 1,
//                           customParams: {'tester': 'sachin 2'},
//                           currentlyCollectedAnswers: (val) {
//                             print(
//                                 " 1190kkl from main currently collected answer ${val} ");
//                           },
//                           allCollectedAnswers: (val) {
//                             print(
//                                 " 1190--2 from main currently collected answer ${val} ");
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ).whenComplete(this.closeModalThing);
//               },
//             )

// import 'package:country_pickers/country.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:country_pickers/country_pickers.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Country Pickers Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       routes: {
//         '/': (context) => DemoPage(),
//       },
//     );
//   }
// }

// class DemoPage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<DemoPage> {
//   Country _selectedDialogCountry =
//       CountryPickerUtils.getCountryByPhoneCode('90');

//   Country _selectedFilteredDialogCountry =
//       CountryPickerUtils.getCountryByPhoneCode('90');

//   Country _selectedCupertinoCountry =
//       CountryPickerUtils.getCountryByIsoCode('tr');

//   Country _selectedFilteredCupertinoCountry =
//       CountryPickerUtils.getCountryByIsoCode('DE');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Country Pickers Demo'),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(8.0),
//         children: <Widget>[
//           Card(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text("CountryPickerDialog"),
//                 ListTile(
//                   onTap: _openCountryPickerDialog,
//                   title: _buildDialogItem(_selectedDialogCountry),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _buildCountryPickerDropdownSoloExpanded() {
//     return CountryPickerDropdown(
//       underline: Container(
//         height: 2,
//         color: Colors.red,
//       ),
//       //show'em (the text fields) you're in charge now
//       onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//       //if you want your dropdown button's selected item UI to be different
//       //than itemBuilder's(dropdown menu item UI), then provide this selectedItemBuilder.
//       onValuePicked: (Country country) {
//         print("${country.name}");
//       },
//       itemBuilder: (Country country) {
//         return Row(
//           children: <Widget>[
//             SizedBox(width: 8.0),
//             CountryPickerUtils.getDefaultFlagImage(country),
//             SizedBox(width: 8.0),
//             Expanded(child: Text(country.name)),
//           ],
//         );
//       },
//       itemHeight: null,
//       isExpanded: true,
//       //initialValue: 'TR',
//       icon: Icon(Icons.arrow_downward),
//     );
//   }

//   _buildCountryPickerDropdown(
//       {bool filtered = false,
//       bool sortedByIsoCode = false,
//       bool hasPriorityList = false,
//       bool hasSelectedItemBuilder = false}) {
//     double dropdownButtonWidth = MediaQuery.of(context).size.width * 0.5;
//     //respect dropdown button icon size
//     double dropdownItemWidth = dropdownButtonWidth - 30;
//     double dropdownSelectedItemWidth = dropdownButtonWidth - 30;
//     return Row(
//       children: <Widget>[
//         SizedBox(
//           width: dropdownButtonWidth,
//           child: CountryPickerDropdown(
//             /* underline: Container(
//               height: 2,
//               color: Colors.red,
//             ),*/
//             //show'em (the text fields) you're in charge now
//             onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//             //if you have menu items of varying size, itemHeight being null respects
//             //that, IntrinsicHeight under the hood ;).
//             itemHeight: null,
//             //itemHeight being null and isDense being true doesn't play along
//             //well together. One is trying to limit size and other is saying
//             //limit is the sky, therefore conflicts.
//             //false is default but still keep that in mind.
//             isDense: false,
//             //if you want your dropdown button's selected item UI to be different
//             //than itemBuilder's(dropdown menu item UI), then provide this selectedItemBuilder.
//             selectedItemBuilder: hasSelectedItemBuilder == true
//                 ? (Country country) => _buildDropdownSelectedItemBuilder(
//                     country, dropdownSelectedItemWidth)
//                 : null,
//             //initialValue: 'AR',
//             itemBuilder: (Country country) => hasSelectedItemBuilder == true
//                 ? _buildDropdownItemWithLongText(country, dropdownItemWidth)
//                 : _buildDropdownItem(country, dropdownItemWidth),
//             initialValue: 'AR',
//             itemFilter: filtered
//                 ? (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode)
//                 : null,
//             //priorityList is shown at the beginning of list
//             priorityList: hasPriorityList
//                 ? [
//                     CountryPickerUtils.getCountryByIsoCode('GB'),
//                     CountryPickerUtils.getCountryByIsoCode('CN'),
//                   ]
//                 : null,
//             sortComparator: sortedByIsoCode
//                 ? (Country a, Country b) => a.isoCode.compareTo(b.isoCode)
//                 : null,
//             onValuePicked: (Country country) {
//               print("${country.name}");
//             },
//           ),
//         ),
//         SizedBox(
//           width: 8.0,
//         ),
//         Expanded(
//           child: TextField(
//             decoration: InputDecoration(
//               labelText: "Phone",
//               isDense: true,
//               contentPadding: EdgeInsets.zero,
//             ),
//             keyboardType: TextInputType.number,
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildDropdownItem(Country country, double dropdownItemWidth) =>
//       SizedBox(
//         width: dropdownItemWidth,
//         child: Row(
//           children: <Widget>[
//             CountryPickerUtils.getDefaultFlagImage(country),
//             SizedBox(
//               width: 8.0,
//             ),
//             Expanded(child: Text("+${country.phoneCode}(${country.isoCode})")),
//           ],
//         ),
//       );

//   Widget _buildDropdownItemWithLongText(
//           Country country, double dropdownItemWidth) =>
//       SizedBox(
//         width: dropdownItemWidth,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: <Widget>[
//               CountryPickerUtils.getDefaultFlagImage(country),
//               SizedBox(
//                 width: 8.0,
//               ),
//               Expanded(child: Text("${country.name}")),
//             ],
//           ),
//         ),
//       );

//   Widget _buildDropdownSelectedItemBuilder(
//           Country country, double dropdownItemWidth) =>
//       SizedBox(
//           width: dropdownItemWidth,
//           child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 children: <Widget>[
//                   CountryPickerUtils.getDefaultFlagImage(country),
//                   SizedBox(
//                     width: 8.0,
//                   ),
//                   Expanded(
//                       child: Text(
//                     '${country.name}',
//                     style: TextStyle(
//                         color: Colors.red, fontWeight: FontWeight.bold),
//                   )),
//                 ],
//               )));

//   Widget _buildDialogItem(Country country) => Row(
//         children: <Widget>[
//           CountryPickerUtils.getDefaultFlagImage(country),
//           // SizedBox(width: 8.0),
//           // Text("+${country.phoneCode}"),
//           // SizedBox(width: 8.0),
//           // Flexible(child: Text(country.name))
//         ],
//       );
//     Widget _buildDialogItemPicker(Country country) => Row(
//         children: <Widget>[
//           CountryPickerUtils.getDefaultFlagImage(country),
//           SizedBox(width: 8.0),
//           Text("+${country.phoneCode}"),
//           SizedBox(width: 8.0),
//           Flexible(child: Text(country.name))
//         ],
//       );

//   void _openCountryPickerDialog() => showDialog(
//         context: context,
//         builder: (context) => Theme(
//           data: Theme.of(context).copyWith(primaryColor: Colors.pink),
//           child: CountryPickerDialog(
//             titlePadding: EdgeInsets.all(8.0),
//             searchCursorColor: Colors.pinkAccent,
//             searchInputDecoration: InputDecoration(hintText: 'Search...'),
//             isSearchable: true,
//             title: Text('Select your phone code'),
//             onValuePicked: (Country country) =>
//                 setState(() => _selectedDialogCountry = country),
//             itemBuilder: _buildDialogItemPicker,
//           ),
//         ),
//       );

//   void _openFilteredCountryPickerDialog() => showDialog(
//         context: context,
//         builder: (context) => Theme(
//             data: Theme.of(context).copyWith(primaryColor: Colors.pink),
//             child: CountryPickerDialog(
//                 titlePadding: EdgeInsets.all(8.0),
//                 searchCursorColor: Colors.pinkAccent,
//                 searchInputDecoration: InputDecoration(hintText: 'Search...'),
//                 isSearchable: true,
//                 title: Text('Select your phone code'),
//                 onValuePicked: (Country country) =>
//                     setState(() => _selectedFilteredDialogCountry = country),
//                 itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
//                 itemBuilder: _buildDialogItemPicker)),
//       );

//   void _openCupertinoCountryPicker() => showCupertinoModalPopup<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return CountryPickerCupertino(
//           backgroundColor: Colors.black,
//           itemBuilder: _buildCupertinoItem,
//           pickerSheetHeight: 300.0,
//           pickerItemHeight: 75,
//           initialCountry: _selectedCupertinoCountry,
//           onValuePicked: (Country country) =>
//               setState(() => _selectedCupertinoCountry = country),
//           priorityList: [
//             CountryPickerUtils.getCountryByIsoCode('TR'),
//             CountryPickerUtils.getCountryByIsoCode('US'),
//           ],
//         );
//       });

//   void _openFilteredCupertinoCountryPicker() => showCupertinoModalPopup<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return CountryPickerCupertino(
//           backgroundColor: Colors.white,
//           pickerSheetHeight: 200.0,
//           initialCountry: _selectedFilteredCupertinoCountry,
//           onValuePicked: (Country country) =>
//               setState(() => _selectedFilteredCupertinoCountry = country),
//           itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
//         );
//       });

//   Widget _buildCupertinoSelectedItem(Country country) {
//     return Row(
//       children: <Widget>[
//         CountryPickerUtils.getDefaultFlagImage(country),
//         SizedBox(width: 8.0),
//         Text("+${country.phoneCode}"),
//         SizedBox(width: 8.0),
//         Flexible(child: Text(country.name))
//       ],
//     );
//   }

//   Widget _buildCupertinoItem(Country country) {
//     return DefaultTextStyle(
//       style: const TextStyle(
//         color: CupertinoColors.white,
//         fontSize: 16.0,
//       ),
//       child: Row(
//         children: <Widget>[
//           SizedBox(width: 8.0),
//           CountryPickerUtils.getDefaultFlagImage(country),
//           SizedBox(width: 8.0),
//           Text("+${country.phoneCode}"),
//           SizedBox(width: 8.0),
//           Flexible(child: Text(country.name))
//         ],
//       ),
//     );
//   }
// }
