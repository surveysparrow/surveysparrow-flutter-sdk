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
  final Function toggleNextButtonBlock;

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
    required this.toggleNextButtonBlock,
  }) : super(key: key);

  @override
  State<TextRating> createState() => _TextRatingState(
        func: func,
        answer: answer,
        question: question,
        theme: theme,
        customParams: customParams,
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

  TextEditingController inputController = TextEditingController();
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

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }
      if (question['type'] == 'EmailInput') {
        if (widget.euiTheme!['email'] != null) {
          if (widget.euiTheme!['email']['fontSize'] != null) {
            fontSize = widget.euiTheme!['email']['fontSize'];
          }
          if (widget.euiTheme!['email']['textFieldWidth'] != null) {
            textFieldWidth = widget.euiTheme!['email']['textFieldWidth'];
          }
        }
      }

      if (question['type'] != 'EmailInput') {
        if (widget.euiTheme!['text'] != null) {
          if (widget.euiTheme!['text']['fontSize'] != null) {
            fontSize = widget.euiTheme!['text']['fontSize'];
          }
          if (widget.euiTheme!['text']['textFieldWidth'] != null) {
            textFieldWidth = widget.euiTheme!['text']['textFieldWidth'];
          }
        }
      }
    }

    if (answer[question['id']] != null) {
      if (question['type'] == 'EmailInput') {
        checkIfEmailValid(answer[question['id']]);
        setState(() {
          inputController.text = answer[question['id']];
        });
      } else {
        var disabledState = false;
        if (answer[question['id']] == "") {
          disabledState = true;
        }
        setState(() {
          disabled = disabledState;
          inputController.text = answer[question['id']];
        });
      }
    }
  }

  checkIfEmailValid(value) {
    if (value == "") {
      widget.toggleNextButtonBlock(false);
      setState(() {
        disabled = true;
      });
      return;
    }
    if (question['type'] == 'EmailInput') {
      if (!validateEmail(value)) {
        widget.toggleNextButtonBlock(true);
        setState(() {
          disabled = true;
        });
      } else {
        widget.toggleNextButtonBlock(false);
        setState(() {
          disabled = false;
        });
      }
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
              currentQuestionNumber: currentQuestionNumber,
              customParams: customParams,
              theme: theme,
              euiTheme: widget.euiTheme,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: textFieldWidth ?? (useMobileLayout ? 320 : 500)),
              child: TextField(
                onChanged: (value) {
                  if (question['type'] == 'EmailInput') {
                    checkIfEmailValid(value);
                  } else {
                    if (value.isEmpty) {
                      setState(() {
                        disabled = true;
                      });
                    } else {
                      setState(() {
                        disabled = false;
                      });
                    }
                  }
                  if (value == '') {
                    widget.toggleNextButtonBlock(false);
                    func(null, question['id'], changePage: false);
                    return;
                  }
                  func(inputController.text, question['id'], changePage: false);
                },
                maxLines: question['properties']['data']['type'] == "MULTI_LINE"
                    ? null
                    : 1,
                style: TextStyle(
                    fontFamily: customFont,
                    color: theme['answerColor'],
                    fontSize: fontSize),
                cursorColor: theme['answerColor'],
                controller: inputController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme['answerColor']),
                  ),
                  hintText: "Please Enter Your Response",
                  hintStyle: TextStyle(
                      fontFamily: customFont,
                      color: theme['questionNumberColor']),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: theme['questionDescriptionColor'],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SkipAndNextButtons(
              key: UniqueKey(),
              disabled: widget.isLastQuestion
                  ? question['required']
                      ? disabled
                      : false
                  : disabled,
              showNext: true,
              showSubmit: widget.isLastQuestion,
              showSkip: (question['required'] || widget.isLastQuestion)
                  ? false
                  : true,
              onClickNext: () {
                if (widget.isLastQuestion &&
                    disabled &&
                    !question['required']) {
                  widget.submitData();
                }
                FocusScope.of(context).requestFocus(FocusNode());
                if (!disabled) {
                  if (widget.isLastQuestion) {
                    func(inputController.text, question['id'],
                        isLastQuestionHandle: true);
                  } else {
                    func(inputController.text, question['id']);
                  }
                }
                if (!disabled && widget.isLastQuestion) {
                  widget.submitData();
                }
              },
              onClickSkip: () {
                widget.toggleNextButtonBlock(false);
                func(null, question['id']);
              },
              theme: theme,
              euiTheme: widget.euiTheme,
            ),
          ],
        ),
      ],
    );
  }
}
