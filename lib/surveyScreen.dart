import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SurveySparrow"),
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
                token: 'tt-0daa18',
                domain: 'sachin.officesparrow.com',
                variables: const {
                  "custom_name": "surveysparrow",
                  "custom_number": "2"
                },
                firstQuestionAnswer: FirstQuestionAnswer(
                  pageNumber: 1, // number of pages to skip when the user takes the survey
                  answers: [
                    Answer(
                      opnionScale: CustomOpinionScale(
                        key: 22864,
                        data: 3,
                        timeTaken: 1,
                        skipped: false,
                      ),
                    ),
                    Answer(
                      rating: CustomRating(
                        key: 22865,
                        data: 3,
                        timeTaken: 1,
                        skipped: false,
                      ),
                    ),
                    Answer(
                      multipleChoice : CustomMultiChoice(
                        key: 22866,
                        data: [20862, 20864],
                        timeTaken: 1,
                        skipped: false,
                      ),
                    )
                  ],
                ),
                customSurveyTheme: CustomSurveyTheme(
                  question: Question(
                      questionNumberFontSize: 20.0,
                      questionHeadingFontSize: 30.0,
                      questionDescriptionFontSize: 20.0),
                  logo: Logo(fontSize: 20.0),
                  bottomBar: BottomBar(navigationButtonSize: 50.0),
                  nextButton:
                      NextButton(fontSize: 20.0, width: 120.0, iconSize: 30.0),
                  email: Email(fontSize: 30.0),
                  skipButton: SkipButton(fontSize: 20.0),
                  rating: Rating(
                    svgHeight: 80,
                    svgWidth: 80,
                    customRatingSvgUnselected:
                        '<svg width="23" height="22" viewBox="0 0 23 22" fill="none" xmlns="http://www.w3.org/2000/svg"><path clip-rule="evenodd" d="m11.5 17.5-5.878 3.09 1.123-6.545L1.989 9.41l6.572-.955L11.5 2.5l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545L11.5 17.5Z" stroke="#007AFF" stroke-width="1.5"/></svg>',
                    customRatingSvgSelected:
                        '<svg width="23" height="21" viewBox="0 0 23 21" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="m11.5 16.5-5.878 3.09 1.123-6.545L1.989 8.41l6.572-.955L11.5 1.5l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545L11.5 16.5Z" fill="#007AFF" stroke="#007AFF"/></svg>',
                  ),
                  yesOrNo: YesOrNo(
                      outerContainerHeight: 200.0,
                      outerContainerWidth: 180.0,
                      svgHeight: 70.0,
                      svgWidth: 70.0,
                      fontSize: 20.0,
                      circleFontIndicatorSize: 30.0),
                  phoneNumber: PhoneNumber(
                      countryPickerWidth: 100.0,
                      countryPickerHeight: 80.0,
                      countryCodeNumberInputWidth: 240.0,
                      fontSize: 28.0),
                  opinionScale: OpinionScale(
                    outerBlockSizeWidth: 80,
                    outerBlockSizeHeight: 80,
                    innerBlockSizeWidth: 70,
                    innerBlockSizeHeight: 70,
                    labelFontSize: 20,
                    numberFontSize: 18,
                    positionedLabelTopValue: -24.0,
                    runSpacing: 28.0,
                  ),
                  welcome: WelcomePageTheme(
                    headerFontSize: 30.0,
                    imageDescriptionFontSize: 25.0,
                    descriptionFontSize: 30.0,
                    imageHeight: 350,
                    imageWidth: 550,
                    buttonFontSize: 30.0,
                    buttonWidth: 500.0,
                    buttonIconSize: 44.0,
                  ),
                  thankYouPage: ThankYouPageTheme(
                    headerFontSize: 30.0,
                    imageDescriptionFontSize: 25.0,
                    descriptionFontSize: 30.0,
                    imageHeight: 550,
                    imageWidth: 650,
                    buttonFontSize: 30.0,
                    buttonWidth: 500.0,
                    buttonIconSize: 44.0,
                    visibilityTime: 5000,
                  ),
                ),
                onNext: (val) {
                  print("Currently collected answer ${val} ");
                },
                onError: () {
                  Navigator.pop(context);
                },
                onSubmit: (val) {
                  print("All collected answer ${val} ");
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
