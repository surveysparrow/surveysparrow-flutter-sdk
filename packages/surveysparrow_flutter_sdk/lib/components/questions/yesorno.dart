import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';

import '../../helpers/svg.dart';
import '../common/skipAndNext.dart';
import 'package:sizer/sizer.dart';

class YesOrNo extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const YesOrNo({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
    required this.submitData,
    this.euiTheme
  }) : super(key: key);

  @override
  State<YesOrNo> createState() => _YesOrNoState(
      func: this.func,
      answer: this.answer,
      question: question,
      theme: this.theme,
      customParams: this.customParams,
      currentQuestionNumber: currentQuestionNumber);
}

class _YesOrNoState extends State<YesOrNo> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  var _selectedOption = -1;

  _YesOrNoState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
  });

  var customFont = null;

  convertBoolToIndex(val) {
    if (val == true) {
      return 0;
    } else {
      return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    if(this.widget.euiTheme != null){
      print("q-eui-theme ${this.widget.euiTheme} ");
      if(this.widget.euiTheme!['font'] != null){
        customFont = this.widget.euiTheme!['font'];
      }
    }
    if (this.answer[this.question['id']] != null) {
      _selectedOption = convertBoolToIndex(this.answer[this.question['id']]);
    }
  }

  setSelectedOption(val) {
    setState(() {
      _selectedOption = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("119011 updated inside opnion ${currentQuestionNumber} ");
    return Column(
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
        // SizedBox(height: 40),
        SizedBox(height: 2.h),
        // SizedBox(height: 40),

        YesOrNoQuestion(
          func: func,
          answer: answer,
          question: question,
          theme: theme,
          setSelectedOption: setSelectedOption,
          euiTheme: this.widget.euiTheme,
        ),

        // OpnionScaleQuestion(
        //   func: this.func,
        //   answer: this.answer,
        //   question: this.question,
        //   theme: this.theme,
        //   setSelectedOption: setSelectedOption,
        // ),

        SizedBox(height: 7.h),
        // SizedBox(height: 40),
        SkipAndNextButtons(
          key: UniqueKey(),
          disabled: _selectedOption == -1,
          showNext: this.widget.isLastQuestion,
          showSkip: (this.question['required'] || this.widget.isLastQuestion)
              ? false
              : true,
          showSubmit: this.widget.isLastQuestion,
          onClickSkip: () {
            this.func(null, question['id']);
            print("skip is clicked");
          },
          onClickNext: () {
            // this.widget.submitData();
            if (_selectedOption != -1) {
              this.widget.submitData();
            }
            print("rating submit is ${_selectedOption}");
          },
          theme: this.theme,
          euiTheme: this.widget.euiTheme,
        ),
      ],
    );
  }
}

class YesOrNoQuestion extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function setSelectedOption;
  final Map<dynamic, dynamic>? euiTheme;

  const YesOrNoQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.setSelectedOption,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<YesOrNoQuestion> createState() => _YesOrNoQuestionState(
      func: this.func,
      answer: this.answer,
      question: this.question,
      theme: this.theme,
      );
}

class _YesOrNoQuestionState extends State<YesOrNoQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  var _start;
  var _mid;
  var _end;
  var luminanceValue = 0.5;
  var reversedOrder = false;
  var startLabel;
  var midLabel;
  var endLabel;
  int _selectedOption = -1;
  var yesLabel = "";
  var noLabel = "";

  _YesOrNoQuestionState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
  });

  updateOpnionScale(val) {
    // this.widget.setSelectedOption(val);
    // setState(() {
    //   _selectedOption = val;
    // });
    // this.func(val, question['id']);
    // print("val to update is ${val}");
  }

  var customFont = null;
  @override
  initState() {
    super.initState();

    if(this.widget.euiTheme != null){
      print("q-eui-theme ${this.widget.euiTheme} ");
      if(this.widget.euiTheme!['font'] != null){
        customFont = this.widget.euiTheme!['font'];
      }
    }

    print(
        "yesorno-89-q question ${this.question['properties']} ${this.question['properties']['data']['iconShape']}");

    yesLabel = this.question['properties']['data']['yes'] == 'builder.yes_no.yes' ? 'Yes' : this.question['properties']['data']['yes'];
    noLabel = this.question['properties']['data']['no'] == 'builder.yes_no.no' ? 'No' : this.question['properties']['data']['no'];

    luminanceValue =
        this.theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    // print("called in rating ${this.answer}");

    print(
        "test yesorno-89 ${this.answer[this.question['id']]} ${this.theme['ratingRgba']}");

    if (this.answer[this.question['id']] != null) {
      setState(() {
        _selectedOption = convertBoolToIndex(this.answer[this.question['id']]);
      });
    } else {
      setState(() {
        _selectedOption = -1;
      });
    }
  }

  convertBoolToIndex(val) {
    if (val == true) {
      return 0;
    } else {
      return 1;
    }
  }

  convertIndexToBool(val) {
    if (val == 0) {
      return true;
    }
    return false;
  }

  updateYesOrNoAnswer(val) {
    print("yes or no int is ${val}");
    this.widget.setSelectedOption(convertBoolToIndex(val));
    setState(() {
      _selectedOption = convertBoolToIndex(val);
    });
    this.func(val, question['id']);
  }

  generateYesOrNoBlock(val) {
    return Container(
      width: 120,
      height: 140,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: _selectedOption == val
            ? this.theme['decodedOpnionBackgroundColorSelected']
            : this.theme['decodedOpnionBackgroundColorUnSelected'],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 24.sp),
            child: val == 1
                ? Container(
                    width: 42,
                    height: 42,
                    child: SvgPicture.string(
                      this.question['properties']['data']['iconShape'] ==
                                'YES_NO_ICON_TICK_CROSS'
                            ? generateYesOrNoTickUnSelected(
                                _selectedOption == val
                                    ? luminanceValue > 0.5
                                        ? 'rgba(57,57,57,1)'
                                        : 'rgba(255,255,255,1)'
                                    : this.theme['ratingRgba'],
                              )
                            : generateYesOrNoThumbUnSelected(
                                _selectedOption == val
                                    ? luminanceValue > 0.5
                                        ? 'rgba(57,57,57,1)'
                                        : 'rgba(255,255,255,1)'
                                    : this.theme['ratingRgba'],
                              ),
                    ),
                  )
                : Container(
                    child: Container(
                      width: 42,
                      height: 42,
                      child: SvgPicture.string(
                        this.question['properties']['data']['iconShape'] ==
                                'YES_NO_ICON_TICK_CROSS'
                            ? generateYesOrNoTickSelected(
                                _selectedOption == val
                                    ? luminanceValue > 0.5
                                        ? 'rgba(57,57,57,1)'
                                        : 'rgba(255,255,255,1)'
                                    : this.theme['ratingRgba'],
                              )
                            : generateYesOrNoThumbSelected(
                                _selectedOption == val
                                    ? luminanceValue > 0.5
                                        ? 'rgba(57,57,57,1)'
                                        : 'rgba(255,255,255,1)'
                                    : this.theme['ratingRgba'],
                              ),
                      ),
                    ),
                  ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.sp, right: 10, left: 10),
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    val == 0 ? yesLabel : noLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily:customFont,
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: _selectedOption == val
                          ? luminanceValue > 0.5
                              ? Colors.black
                              : Colors.white
                          : this.theme['answerColor'],
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: this.theme['answerColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      val == 0 ? "Y" : "N",
                      style: TextStyle(
                        fontFamily:customFont,
                        decoration: TextDecoration.none,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            luminanceValue > 0.5 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("selected option yes or no int is ${_selectedOption}");

    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;

    List<Widget> list = List<Widget>.empty(growable: true);

    for (var i = 0; i < 2; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            print("on tap called for op ${i}");
            updateYesOrNoAnswer(convertIndexToBool(i));
          },
          child: Container(
            child: Container(child: generateYesOrNoBlock(i)),
          ),
        ),
      );
    }

    // possible change is change the alignment for container to wrapalignment to start if needed in tablet

    // Have removed width:doubly.infinity
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: useMobileLayout ? WrapAlignment.center : WrapAlignment.start,
        runSpacing: 5,
        direction: Axis.horizontal,
        children: [...list],
      ),
    );
  }
}
