import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class Page2 extends StatelessWidget {
  final String token;
  final String domain;
  final String customTheme;
  final String customParam;

  const Page2(
      {Key? key,
      required this.token,
      required this.domain,
      required this.customTheme,
      required this.customParam})
      : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> testJosn =
        customTheme == null || customTheme == '' ? {} : json.decode(customTheme);

    var survey_theme = CustomSurveyTheme.fromMap(testJosn);

    Map<String, dynamic> queryParameters =  customParam == null || customParam == '' ? {} : json.decode(customParam);
    Map<String, String> stringQueryParameters =
        queryParameters.map((key, value) => MapEntry(key, value.toString()));

    return Scaffold(
      appBar: AppBar(
        title: Text(token + "domain" + domain),
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
                token: token,
                domain: domain,
                variables: stringQueryParameters,
                customSurveyTheme: survey_theme,
                onNext: (val) {
                  print(
                      " 1190kkl from main currently collected answer ${val} ");
                },
                onError: (){
                  Navigator.pop(context);
                },
                onSubmit: (val) {
                  print(
                      " 1190--2 from main currently collected answer ${val} ");
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                  });
                },
              ),
            )),
      ),
    );
  }
}

// CustomSurveyTheme(
//                   question: Question(
//                       questionNumberFontSize: 20.0,
//                       questionHeadingFontSize: 30.0,
//                       questionDescriptionFontSize: 20.0),
//                   logo: Logo(fontSize: 20.0),
//                   bottomBar: BottomBar(navigationButtonSize: 50.0),
//                   nextButton:
//                       NextButton(fontSize: 20.0, width: 120.0, iconSize: 30.0),
//                   email: Email(fontSize: 30.0),
//                   skipButton: SkipButton(fontSize: 20.0),
//                   rating: Rating(svgHeight: 80, svgWidth: 80),
//                   yesOrNo: YesOrNo(
//                       outerContainerHeight: 200.0,
//                       outerContainerWidth: 180.0,
//                       svgHeight: 70.0,
//                       svgWidth: 70.0,
//                       fontSize: 20.0,
//                       circleFontIndicatorSize: 30.0),
//                   phoneNumber: PhoneNumber(
//                       countryPickerWidth: 100.0, countryPickerHeight: 80.0,
//                       countryCodeNumberInputWidth: 240.0,
//                       fontSize: 28.0
//                       ),
//                   opnionScale: OpnionScale(
//                     outerBlockSizeWidth: 80,
//                     outerBlockSizeHeight: 80,
//                     innerBlockSizeWidth: 70,
//                     innerBlockSizeHeight: 70,
//                     labelFontSize: 20,
//                     numberFontSize: 18,
//                     positionedLabelTopValue: -24.0,
//                     runSpacing: 28.0,
//                   ),
//                 )