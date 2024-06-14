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

  const YesOrNo(
      {Key? key,
      required this.func,
      required this.answer,
      required this.question,
      required this.theme,
      required this.customParams,
      required this.currentQuestionNumber,
      required this.isLastQuestion,
      required this.submitData,
      this.euiTheme})
      : super(key: key);

  @override
  State<YesOrNo> createState() => _YesOrNoState(
      func: func,
      answer: answer,
      question: question,
      theme: theme,
      customParams: customParams,
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
    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }
    }
    if (answer[question['id']] != null) {
      _selectedOption = convertBoolToIndex(answer[question['id']]);
    }
  }

  setSelectedOption(val) {
    setState(() {
      _selectedOption = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        // SizedBox(height: 40),
        SizedBox(height: 2.h),
        // SizedBox(height: 40),

        YesOrNoQuestion(
          func: func,
          answer: answer,
          question: question,
          theme: theme,
          setSelectedOption: setSelectedOption,
          euiTheme: widget.euiTheme,
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
          disabled: widget.isLastQuestion
              ? question['required']
                  ? _selectedOption == -1
                  : false
              : _selectedOption == -1,
          showNext: widget.isLastQuestion,
          showSkip:
              (question['required'] || widget.isLastQuestion) ? false : true,
          showSubmit: widget.isLastQuestion,
          onClickSkip: () {
            func(null, question['id']);
          },
          onClickNext: () {
            // this.widget.submitData();
            if (_selectedOption != -1) {
              widget.submitData();
            }
            if (widget.isLastQuestion &&
                _selectedOption == -1.0 &&
                !question['required']) {
              widget.submitData();
            }
          },
          theme: theme,
          euiTheme: widget.euiTheme,
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
        func: func,
        answer: answer,
        question: question,
        theme: theme,
      );
}

class _YesOrNoQuestionState extends State<YesOrNoQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
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

  var customFont = null;

  var svgWidth = 42.0;
  var svgHeight = 42.0;

  var outerContainerWidth = 120.0;
  var outerContainerHeight = 140.0;

  var circleFontIndicatorSize = 24.0;

  var fontSize = 12.0;

  var customSvgStringSelected;
  var customSvgStringUnSelected;
  // var text

  @override
  initState() {
    super.initState();

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['yesOrNo'] != null) {
        if (widget.euiTheme!['yesOrNo']['svgWidth'] != null) {
          svgWidth = widget.euiTheme!['yesOrNo']['svgWidth'];
        }
        if (widget.euiTheme!['yesOrNo']['svgHeight'] != null) {
          svgHeight = widget.euiTheme!['yesOrNo']['svgHeight'];
        }
        if (widget.euiTheme!['yesOrNo']['outerContainerWidth'] != null) {
          outerContainerWidth =
              widget.euiTheme!['yesOrNo']['outerContainerWidth'];
        }
        if (widget.euiTheme!['yesOrNo']['outerContainerHeight'] != null) {
          outerContainerHeight =
              widget.euiTheme!['yesOrNo']['outerContainerHeight'];
        }
        if (widget.euiTheme!['yesOrNo']['fontSize'] != null) {
          fontSize = widget.euiTheme!['yesOrNo']['fontSize'];
        }
        if (widget.euiTheme!['yesOrNo']['circleFontIndicatorSize'] != null) {
          circleFontIndicatorSize =
              widget.euiTheme!['yesOrNo']['circleFontIndicatorSize'];
        }
        if (widget.euiTheme!['yesOrNo']['customSvgSelected'] != null) {
          customSvgStringSelected =
              widget.euiTheme!['yesOrNo']['customSvgSelected'];
        }
        if (widget.euiTheme!['yesOrNo']['customSvgUnSelected'] != null) {
          customSvgStringUnSelected =
              widget.euiTheme!['yesOrNo']['customSvgUnSelected'];
        }
      }
    }

    yesLabel = question['properties']['data']['yes'] == 'builder.yes_no.yes'
        ? 'Yes'
        : question['properties']['data']['yes'];
    noLabel = question['properties']['data']['no'] == 'builder.yes_no.no'
        ? 'No'
        : question['properties']['data']['no'];

    luminanceValue =
        theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    if (answer[question['id']] != null) {
      setState(() {
        _selectedOption = convertBoolToIndex(answer[question['id']]);
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
    widget.setSelectedOption(convertBoolToIndex(val));
    setState(() {
      _selectedOption = convertBoolToIndex(val);
    });
    func(val, question['id']);
  }

  generateYesOrNoBlock(val) {
    return Container(
      width: outerContainerWidth,
      height: outerContainerHeight,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: _selectedOption == val
            ? theme['decodedOpnionBackgroundColorSelected']
            : theme['decodedOpnionBackgroundColorUnSelected'],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            child: val == 1
                ? SizedBox(
                    width: svgWidth,
                    height: svgHeight,
                    child: SvgPicture.string(
                      customSvgStringUnSelected != null
                          ? _selectedOption == val
                              ? customSvgStringSelected
                              : customSvgStringUnSelected
                          : question['properties']['data']['iconShape'] ==
                                  'YES_NO_ICON_TICK_CROSS'
                              ? generateYesOrNoTickUnSelected(
                                  _selectedOption == val
                                      ? luminanceValue > 0.5
                                          ? 'rgba(57,57,57,1)'
                                          : 'rgba(255,255,255,1)'
                                      : theme['ratingRgba'],
                                )
                              : generateYesOrNoThumbUnSelected(
                                  _selectedOption == val
                                      ? luminanceValue > 0.5
                                          ? 'rgba(57,57,57,1)'
                                          : 'rgba(255,255,255,1)'
                                      : theme['ratingRgba'],
                                ),
                    ),
                  )
                : SizedBox(
                    width: svgWidth,
                    height: svgHeight,
                    child: SvgPicture.string(
                      customSvgStringSelected != null
                          ? _selectedOption == val
                              ? customSvgStringSelected
                              : customSvgStringUnSelected
                          : question['properties']['data']['iconShape'] ==
                                  'YES_NO_ICON_TICK_CROSS'
                              ? generateYesOrNoTickSelected(
                                  _selectedOption == val
                                      ? luminanceValue > 0.5
                                          ? 'rgba(57,57,57,1)'
                                          : 'rgba(255,255,255,1)'
                                      : theme['ratingRgba'],
                                )
                              : generateYesOrNoThumbSelected(
                                  _selectedOption == val
                                      ? luminanceValue > 0.5
                                          ? 'rgba(57,57,57,1)'
                                          : 'rgba(255,255,255,1)'
                                      : theme['ratingRgba'],
                                ),
                    ),
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    val == 0 ? yesLabel : noLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: customFont,
                      decoration: TextDecoration.none,
                      fontSize: fontSize,
                      color: _selectedOption == val
                          ? luminanceValue > 0.5
                              ? Colors.black
                              : Colors.white
                          : theme['answerColor'],
                    ),
                  ),
                ),
                Container(
                  width: circleFontIndicatorSize,
                  height: circleFontIndicatorSize,
                  decoration: BoxDecoration(
                    color: theme['answerColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      val == 0 ? "Y" : "N",
                      style: TextStyle(
                        fontFamily: customFont,
                        decoration: TextDecoration.none,
                        fontSize: fontSize,
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
    outerContainerWidth = MediaQuery.of(context).size.width / 100 * 31;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;

    List<Widget> list = List<Widget>.empty(growable: true);

    for (var i = 0; i < 2; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            updateYesOrNoAnswer(convertIndexToBool(i));
          },
          child: Container(child: generateYesOrNoBlock(i)),
        ),
      );
    }

    // possible change is change the alignment for container to wrapalignment to start if needed in tablet

    // Have removed width:doubly.infinity
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: useMobileLayout ? WrapAlignment.center : WrapAlignment.start,
      runSpacing: 5,
      direction: Axis.horizontal,
      children: [...list],
    );
  }
}
