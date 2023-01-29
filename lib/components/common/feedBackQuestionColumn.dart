import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/helpers/cx.dart';
import 'package:surveysparrow_flutter_sdk/providers/survey_provider.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

import '../../helpers/question.dart';
import 'package:provider/provider.dart';
import 'package:surveysparrow_flutter_sdk/providers/answer_provider.dart';

class FeedBackQuestionColumn extends StatefulWidget {
  final Map<dynamic, dynamic> question;
  final int currentQuestionNumber;
  final Map<String, String> customParams;
  final Map<dynamic, dynamic> theme;
  final Map<dynamic, dynamic>? euiTheme;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> parentQuestion;

  const FeedBackQuestionColumn({
    Key? key,
    required this.question,
    required this.currentQuestionNumber,
    required this.theme,
    required this.customParams,
    required this.answer,
    required this.parentQuestion,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<FeedBackQuestionColumn> createState() => _FeedBackQuestionColumnState(
        question: question,
        currentQuestionNumber: currentQuestionNumber,
        theme: this.theme,
        customParams: this.customParams,
      );
}

class _FeedBackQuestionColumnState extends State<FeedBackQuestionColumn> {
  final Map<dynamic, dynamic> question;
  final int currentQuestionNumber;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  var customFont = null;
  var questionHeadingFontSize = 24.0;
  var questionDescriptionFontSize = 14.0;
  var questionNumberFontSize = 14.0;

  _FeedBackQuestionColumnState({
    required this.question,
    required this.currentQuestionNumber,
    required this.theme,
    required this.customParams,
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }

      if (this.widget.euiTheme!['question'] != null) {
        if (this.widget.euiTheme!['question']['questionNumberFontSize'] !=
            null) {
          questionNumberFontSize =
              this.widget.euiTheme!['question']['questionNumberFontSize'];
        }
        if (this.widget.euiTheme!['question']['questionHeadingFontSize'] !=
            null) {
          questionHeadingFontSize =
              this.widget.euiTheme!['question']['questionHeadingFontSize'];
        }
        if (this.widget.euiTheme!['question']['questionDescriptionFontSize'] !=
            null) {
          questionDescriptionFontSize =
              this.widget.euiTheme!['question']['questionDescriptionFontSize'];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theme['showRequired'] && this.question['required']
                ? "*" +
                    getCXFeedBackQuestionHeading(
                        this.question, this.widget.parentQuestion ,this.customParams, context.watch<WorkBench>().getWorkBenchData, context.watch<SurveyProvider>().getSurvey)
                : getCXFeedBackQuestionHeading(
                        this.question, this.widget.parentQuestion ,this.customParams, context.watch<WorkBench>().getWorkBenchData, context.watch<SurveyProvider>().getSurvey),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: customFont,
                decoration: TextDecoration.none,
                fontSize: questionHeadingFontSize,
                fontWeight: FontWeight.w400,
                color: theme['questionColor']),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
