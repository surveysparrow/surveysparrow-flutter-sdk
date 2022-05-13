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
  @override
  initState() {
    super.initState();
    print("test text text-1190 ${this.question['properties']['data']['type']}");

    if (this.widget.euiTheme != null) {
      print("q-eui-theme ${this.widget.euiTheme} ");
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
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
    print("sel-90-txt-dis ${disabled}");
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
              constraints:
                  BoxConstraints(maxWidth: useMobileLayout ? 320 : 500),
              child: TextField(
                onChanged: (value) {
                  print('vali called ${this.question['type']}');
                  if (this.question['type'] == 'EmailInput') {
                    print("vali called ${validateEmail(value)}");
                    if (!validateEmail(value)) {
                      print("sel-90-txt-in ${value}");
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
                      print("sel-90-txt-in ${value}");
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
                style: TextStyle(fontFamily: customFont,color: this.theme['answerColor']),
                cursorColor: this.theme['answerColor'],
                controller: inputController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: this.theme['answerColor']),
                  ),
                  hintText: "Please Enter Your Response",
                  hintStyle:
                      TextStyle(fontFamily: customFont, color: this.theme['questionNumberColor']),
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
                print("obtained test input is 1134 ${inputController.text}");
                if (!disabled) {
                  this.func(inputController.text, question['id']);
                }
                if (!disabled && this.widget.isLastQuestion) {
                  print("vali called called for submit ${disabled} ");
                  this.widget.submitData();
                }
              },
              onClickSkip: () {
                this.func(null, question['id']);
                print("skip is clicked");
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
