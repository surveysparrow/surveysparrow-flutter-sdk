import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';

import '../common/skipAndNext.dart';

class TextRating extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const TextRating({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
    required this.submitData,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<TextRating> createState() => _TextRatingState(
        func: this.func,
        answer: this.answer,
        question: question,
        theme: this.theme,
        customParams: this.customParams,
        currentQuestionNumber: currentQuestionNumber,
        isLastQuestion: isLastQuestion,
      );
}

class _TextRatingState extends State<TextRating> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  bool disabled = true;

  TextEditingController inputController = new TextEditingController();
  _TextRatingState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
  });

  var customFont = null;

  double fontSize = 18.0;
  var textFieldWidth;
  @override
  initState() {
    super.initState();

    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }
      if (this.question['type'] == 'EmailInput') {
        if (this.widget.euiTheme!['email'] != null) {
          if (this.widget.euiTheme!['email']['fontSize'] != null) {
            fontSize = this.widget.euiTheme!['email']['fontSize'];
          }
          if (this.widget.euiTheme!['email']['textFieldWidth'] != null) {
            textFieldWidth = this.widget.euiTheme!['email']['textFieldWidth'];
          }
        }
      }

      if (this.question['type'] != 'EmailInput') {
        if (this.widget.euiTheme!['text'] != null) {
          if (this.widget.euiTheme!['text']['fontSize'] != null) {
            fontSize = this.widget.euiTheme!['text']['fontSize'];
          }
          if (this.widget.euiTheme!['text']['textFieldWidth'] != null) {
            textFieldWidth = this.widget.euiTheme!['text']['textFieldWidth'];
          }
        }
      }
    }

    if (this.answer[this.question['id']] != null) {
      setState(() {
        disabled = false;
        inputController.text = this.answer[this.question['id']];
      });
    }
  }

  validateEmail(value) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionColumn(
              question: question,
              currentQuestionNumber: this.currentQuestionNumber,
              customParams: this.customParams,
              theme: this.theme,
              euiTheme: this.widget.euiTheme,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: textFieldWidth != null
                      ? textFieldWidth
                      : useMobileLayout
                          ? 320
                          : 500),
              child: TextField(
                onChanged: (value) {
                  if (this.question['type'] == 'EmailInput') {
                    if (!validateEmail(value)) {
                      setState(() {
                        disabled = true;
                      });
                    } else {
                      setState(() {
                        disabled = false;
                      });
                    }
                  } else {
                    if (value.length == 0) {
                      setState(() {
                        disabled = true;
                      });
                    } else {
                      setState(() {
                        disabled = false;
                      });
                    }
                  }
                },
                maxLines:
                    this.question['properties']['data']['type'] == "MULTI_LINE"
                        ? null
                        : 1,
                style: TextStyle(
                    fontFamily: customFont,
                    color: this.theme['answerColor'],
                    fontSize: fontSize),
                cursorColor: this.theme['answerColor'],
                controller: inputController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: this.theme['answerColor']),
                  ),
                  hintText: "Please Enter Your Response",
                  hintStyle: TextStyle(
                      fontFamily: customFont,
                      color: this.theme['questionNumberColor']),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: this.theme['questionDescriptionColor'],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SkipAndNextButtons(
              key: UniqueKey(),
              disabled: disabled,
              showNext: true,
              showSubmit: this.widget.isLastQuestion,
              showSkip:
                  (this.question['required'] || this.widget.isLastQuestion)
                      ? false
                      : true,
              onClickNext: () {
                if (!disabled) {
                  this.func(inputController.text, question['id']);
                }
                if (!disabled && this.widget.isLastQuestion) {
                  this.widget.submitData();
                }
              },
              onClickSkip: () {
                this.func(null, question['id']);
              },
              theme: theme,
              euiTheme: this.widget.euiTheme,
            ),
          ],
        ),
      ],
    );
  }
}
