import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
import 'dart:async';
class MyHomePage2 extends StatefulWidget {
  MyHomePage2({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Survey"),
      ),
      body: Center(
        child: Container(
          width: 600,
          height: 600,
          child: SurveyModal(
            domain: "sample.surveysparrow.com",
            token: "tt-3d4efc",
            onNext: (val) {
              print("Answers that has been collected so far ${val}");
            },
            onSubmit: (val) {
              print("All the answers that was collected is ${val}");
            },
            customSurveyTheme: CustomSurveyTheme(
              font: "Antons",
              bottomBar: BottomBar(
              ),
              skipButton: SkipButton(fontSize: 20.0),
              nextButton: NextButton(
                fontSize: 30.0,
                width: 20.0,
                iconSize: 40.0,
              ),
              question: Question(
                questionDescriptionFontSize: 30.0,
                questionHeadingFontSize: 25.0,
                questionNumberFontSize: 31.0,
              ),
              rating: Rating(
                customRatingSvgSelected:
                    '<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11.656 15.75H6.344a1.688 1.688 0 0 1-1.683-1.558l-.723-9.41h10.124l-.723 9.41a1.687 1.687 0 0 1-1.683 1.558v0ZM15 4.781H3M6.89 2.25h4.22a.844.844 0 0 1 .843.844V4.78H6.047V3.094a.844.844 0 0 1 .844-.844v0Zm.61 10.5h3" stroke="#EC6772" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                customRatingSvgUnselected:
                    '<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M11.656 15.75H6.344a1.688 1.688 0 0 1-1.683-1.558l-.723-9.41h10.124l-.723 9.41a1.687 1.687 0 0 1-1.683 1.558v0ZM15 4.781H3M6.89 2.25h4.22a.844.844 0 0 1 .843.844V4.78H6.047V3.094a.844.844 0 0 1 .844-.844v0Zm.61 10.5h3" stroke="#EC6772" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                svgHeight: 20.0,
                svgWidth: 20.0,
                hasNumber: false,
              ),
              yesOrNo: YesOrNo(
                circleFontIndicatorSize: 20.0,
                svgHeight: 20.0,
                svgWidth: 20.0,
                outerContainerHeight: 20.0,
                outerContainerWidth: 40.0,
              ),
              multipleChoice: MultipleChoice(
                choiceContainerHeight: 20.0,
                choiceContainerWidth: 20.0,
                circularFontContainerSize: 30.0,
              ),
              email: Email(
                fontSize: 20.0,
                textFieldWidth: 500.0,
              ),
              opnionScale: OpnionScale(
                outerBlockSizeHeight: 20.0,
                outerBlockSizeWidth: 30.0,
                innerBlockSizeHeight: 30.0,
                innerBlockSizeWidth: 30.0,
                numberFontSize: 12.0,
                labelFontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
