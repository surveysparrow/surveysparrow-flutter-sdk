import 'package:flutter/material.dart';

import '../../helpers/question.dart';

class QuestionColumn extends StatefulWidget {
  final Map<dynamic, dynamic> question;
  final int currentQuestionNumber;
  final Map<String, String> customParams;
  final Map<dynamic, dynamic> theme;
  final Map<dynamic, dynamic>? euiTheme;

  const QuestionColumn({
    Key? key,
    required this.question,
    required this.currentQuestionNumber,
    required this.theme,
    required this.customParams,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<QuestionColumn> createState() => _QuestionColumnState(
        question: question,
        currentQuestionNumber: currentQuestionNumber,
        theme: this.theme,
        customParams: this.customParams,
      );
}

class _QuestionColumnState extends State<QuestionColumn> {
  final Map<dynamic, dynamic> question;
  final int currentQuestionNumber;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  var customFont = null;
  var questionHeadingFontSize = 24.0;
  var questionDescriptionFontSize = 14.0;
  var questionNumberFontSize = 14.0;

  _QuestionColumnState({
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
          if (this.theme['showQuestionNumber']) ...[
            Text(
              'Question ${currentQuestionNumber.toString()}',
              textAlign: TextAlign.left,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: questionNumberFontSize,
                fontWeight: FontWeight.w400,
                color: theme['questionNumberColor'],
                fontFamily: customFont,
              ),
            ),
          ],
          Text(
            theme['showRequired'] && this.question['required']
                ? "*" + parsedHeading(this.question, this.customParams)
                : parsedHeading(this.question, this.customParams),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: customFont,
                decoration: TextDecoration.none,
                fontSize: questionHeadingFontSize,
                fontWeight: FontWeight.w400,
                color: theme['questionColor']),
          ),
          Text(
            this.question['rdesc'] != null &&
                    this.question['rdesc']['blocks'] != null &&
                    this.question['rdesc']['blocks'][0] != null &&
                    this.question['rdesc']['blocks'][0]['text'] != null
                ? this.question['rdesc']['blocks'][0]['text']
                : '',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: customFont,
              decoration: TextDecoration.none,
              fontSize: questionDescriptionFontSize,
              fontWeight: FontWeight.w400,
              color: theme['questionDescriptionColor'],
            ),
          ),
        ],
      ),
    );
  }
}
