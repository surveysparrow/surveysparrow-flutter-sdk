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
        theme: theme,
        customParams: customParams,
      );
}

class _QuestionColumnState extends State<QuestionColumn> {
  final Map<dynamic, dynamic> question;
  final int currentQuestionNumber;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  dynamic customFont;
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
    super.initState();
    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['question'] != null) {
        if (widget.euiTheme!['question']['questionNumberFontSize'] !=
            null) {
          questionNumberFontSize =
              widget.euiTheme!['question']['questionNumberFontSize'];
        }
        if (widget.euiTheme!['question']['questionHeadingFontSize'] !=
            null) {
          questionHeadingFontSize =
              widget.euiTheme!['question']['questionHeadingFontSize'];
        }
        if (widget.euiTheme!['question']['questionDescriptionFontSize'] !=
            null) {
          questionDescriptionFontSize =
              widget.euiTheme!['question']['questionDescriptionFontSize'];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (theme['showQuestionNumber']) ...[
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
            theme['showRequired'] && question['required']
                ? "* ${parsedHeading(question, customParams)}"
                : parsedHeading(question, customParams),
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: customFont,
                decoration: TextDecoration.none,
                fontSize: questionHeadingFontSize,
                fontWeight: FontWeight.w400,
                color: theme['questionColor']),
          ),
          Text(
            question['rdesc'] != null &&
                    question['rdesc']['blocks'] != null &&
                    question['rdesc']['blocks'][0] != null &&
                    question['rdesc']['blocks'][0]['text'] != null
                ? question['rdesc']['blocks'][0]['text']
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
