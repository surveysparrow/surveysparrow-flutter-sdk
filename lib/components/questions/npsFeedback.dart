import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/feedBackQuestionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';

import '../common/skipAndNext.dart';

class FeedBackText extends StatefulWidget {
  final Function func;
  final Function handleFeedBackText;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> parentQuestion;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final Map<dynamic, dynamic>? euiTheme;

  const FeedBackText({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.handleFeedBackText,
    required this.parentQuestion,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<FeedBackText> createState() => _FeedBackTextState(
        func: this.func,
        answer: this.answer,
        question: question,
        theme: this.theme,
        customParams: this.customParams,
      );
}

class _FeedBackTextState extends State<FeedBackText> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  bool disabled = true;

  TextEditingController inputController = new TextEditingController();
  _FeedBackTextState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
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

      if (this.widget.euiTheme!['text'] != null) {
        if (this.widget.euiTheme!['text']['fontSize'] != null) {
          fontSize = this.widget.euiTheme!['text']['fontSize'];
        }
        if (this.widget.euiTheme!['text']['textFieldWidth'] != null) {
          textFieldWidth = this.widget.euiTheme!['text']['textFieldWidth'];
        }
      }
    }

    if (this.answer[this.question['id']] != null) {
      var disabledState = false;
      if (this.answer[this.question['id']] == "") {
        disabledState = true;
      }
      setState(() {
        disabled = disabledState;
        inputController.text = this.answer[this.question['id']];
      });
    }
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
            FeedBackQuestionColumn(
              question: question,
              currentQuestionNumber: 0,
              theme: theme,
              customParams: customParams,
              answer: this.widget.answer,
              parentQuestion: this.widget.parentQuestion,
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
                  this.widget.handleFeedBackText(value, question['id']);
                  // if (value.length == 0) {
                  //   setState(() {
                  //     disabled = true;
                  //   });
                  // } else {
                  //   setState(() {
                  //     disabled = false;
                  //   });
                  // }

                  // if (value == '') {
                  //   this.widget.toggleNextButtonBlock(false);
                  //   this.func(null, question['id'], changePage: false);
                  //   return;
                  // }
                  // this.func(inputController.text, question['id'],
                  //     changePage: false);
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
            // const SizedBox(height: 30),
            // SkipAndNextButtons(
            //   key: UniqueKey(),
            //   disabled: this.widget.isLastQuestion
            //       ? this.question['required']
            //           ? disabled
            //           : false
            //       : disabled,
            //   showNext: true,
            //   showSubmit: this.widget.isLastQuestion,
            //   showSkip:
            //       (this.question['required'] || this.widget.isLastQuestion)
            //           ? false
            //           : true,
            //   onClickNext: () {
            //     if (this.widget.isLastQuestion &&
            //         disabled &&
            //         !this.question['required']) {
            //       this.widget.submitData();
            //     }
            //     FocusScope.of(context).requestFocus(new FocusNode());
            //     if (!disabled) {
            //       if (this.widget.isLastQuestion) {
            //         this.func(inputController.text, question['id'],
            //             isLastQuestionHandle: true);
            //       } else {
            //         this.func(inputController.text, question['id']);
            //       }
            //     }
            //     if (!disabled && this.widget.isLastQuestion) {
            //       this.widget.submitData();
            //     }
            //   },
            //   onClickSkip: () {
            //     this.widget.toggleNextButtonBlock(false);
            //     this.func(null, question['id']);
            //   },
            //   theme: theme,
            //   euiTheme: this.widget.euiTheme,
            // ),
          ],
        ),
      ],
    );
  }
}
