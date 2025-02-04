import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/feedBackQuestionColumn.dart';

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
        func: func,
        answer: answer,
        question: question,
        theme: theme,
        customParams: customParams,
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

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['text'] != null) {
        if (widget.euiTheme!['text']['fontSize'] != null) {
          fontSize = widget.euiTheme!['text']['fontSize'];
        }
        if (widget.euiTheme!['text']['textFieldWidth'] != null) {
          textFieldWidth = widget.euiTheme!['text']['textFieldWidth'];
        }
      }
    }

    if (answer[question['id']] != null) {
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
              answer: widget.answer,
              parentQuestion: widget.parentQuestion,
            ),
            Container(
              constraints: BoxConstraints(
                  maxWidth: textFieldWidth ?? (useMobileLayout ? 320 : 500)),
              child: TextField(
                onChanged: (value) {
                  widget.handleFeedBackText(value, question['id']);
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
          ],
        ),
      ],
    );
  }
}
