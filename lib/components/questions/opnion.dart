import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import '../common/skipAndNext.dart';
import 'package:sizer/sizer.dart';

class ColumnOpnionScale extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const ColumnOpnionScale({
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
  State<ColumnOpnionScale> createState() => _ColumnOpnionScaleState(
      func: func,
      answer: answer,
      question: question,
      theme: theme,
      customParams: customParams,
      currentQuestionNumber: currentQuestionNumber);
}

class _ColumnOpnionScaleState extends State<ColumnOpnionScale> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  var _selectedOption = -1;

  _ColumnOpnionScaleState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
  });

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
        SizedBox(height: 2.h),
        OpnionScaleQuestion(
          func: func,
          answer: answer,
          question: question,
          theme: theme,
          setSelectedOption: setSelectedOption,
          euiTheme: widget.euiTheme,
        ),
        SizedBox(height: 7.h),
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

class OpnionScaleQuestion extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function setSelectedOption;
  final Map<dynamic, dynamic>? euiTheme;

  const OpnionScaleQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.setSelectedOption,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<OpnionScaleQuestion> createState() => _OpnionScaleQuestionState(
      func: func, answer: answer, question: question, theme: theme);
}

class _OpnionScaleQuestionState extends State<OpnionScaleQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  var _start;
  var _mid;
  var _end;
  var _step;
  var luminanceValue = 0.5;
  var reversedOrder = false;
  var startLabel;
  var midLabel;
  var endLabel;

  var runSpacing = 5.0;
  var positionedLabelTopValue = -8.0;

  int _selectedOption = -1;
  _OpnionScaleQuestionState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
  });

  updateOpnionScale(val) {
    widget.setSelectedOption(val);
    setState(() {
      _selectedOption = val;
    });
    func(val, question['id']);
  }

  generateStartStep(step, start) {
    _start = start;
    var totalOptions = start == 0 ? step + 1 : step;

    _mid = totalOptions % 2 == 0
        ? -1
        : ((start == 0 ? totalOptions - 1 : totalOptions) / 2).ceil();
    _end = step;

    _step = start == 0 ? step + 1 : step;
  }

  var customFont = null;

  var opnionBlockSizeWidth = 48.0;
  var opnionBlockSizeHeight = 60.0;

  var innerOpnionBlockSizeWidth = 40.0;
  var innerOpnionBlockSizeHeight = 40.0;

  var opnionLabelFontSize = 12.0;
  var numberFontSize = 13.0;

  var hasNAoption = false;

  @override
  initState() {
    super.initState();

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['opinionScale'] != null) {
        if (widget.euiTheme!['opinionScale']['outerBlockWidth'] != null) {
          opnionBlockSizeWidth =
              widget.euiTheme!['opinionScale']['outerBlockWidth'];
        }
        if (widget.euiTheme!['opinionScale']['outerBlockHeight'] != null) {
          opnionBlockSizeHeight =
              widget.euiTheme!['opinionScale']['outerBlockHeight'];
        }

        if (widget.euiTheme!['opinionScale']['innerBlockWidth'] != null) {
          innerOpnionBlockSizeWidth =
              widget.euiTheme!['opinionScale']['innerBlockWidth'];
        }
        if (widget.euiTheme!['opinionScale']['innerBlockHeight'] != null) {
          innerOpnionBlockSizeHeight =
              widget.euiTheme!['opinionScale']['innerBlockHeight'];
        }
        if (widget.euiTheme!['opinionScale']['labelFontSize'] != null) {
          opnionLabelFontSize =
              widget.euiTheme!['opinionScale']['labelFontSize'];
        }
        if (widget.euiTheme!['opinionScale']['numberFontSize'] != null) {
          numberFontSize = widget.euiTheme!['opinionScale']['numberFontSize'];
        }
        if (widget.euiTheme!['opinionScale']['runSpacing'] != null) {
          runSpacing = widget.euiTheme!['opinionScale']['runSpacing'];
        }
        if (widget.euiTheme!['opinionScale']['positionedLabelTopValue'] !=
            null) {
          positionedLabelTopValue =
              widget.euiTheme!['opinionScale']['positionedLabelTopValue'];
        }
      }
    }

    startLabel =
        question['properties']['data']['min'] == 'builder.opinion_scale.min'
            ? 'Least Likely'
            : question['properties']['data']['min'];
    midLabel =
        question['properties']['data']['mid'] == 'builder.opinion_scale.mid'
            ? 'Neutral'
            : question['properties']['data']['mid'];
    endLabel =
        question['properties']['data']['max'] == 'builder.opinion_scale.max'
            ? 'Most Likely'
            : question['properties']['data']['max'];

    luminanceValue =
        theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    if (question['properties'] != null &&
        question['properties']['data'] != null &&
        question['properties']['data']['reversedOrder'] != null) {
      reversedOrder = question['properties']['data']['reversedOrder'];
    }

    if (question['properties'] != null &&
        question['properties']['data'] != null &&
        question['properties']['data']['notApplicable'] != null) {
      hasNAoption = question['properties']['data']['notApplicable'];
    }

    generateStartStep(question['properties']['data']['step'],
        question['properties']['data']['start']);

    if (answer[question['id']] != null) {
      setState(() {
        _selectedOption = answer[question['id']];
      });
    } else {
      setState(() {
        _selectedOption = -1;
      });
    }
  }

  transformLabel(text) {
    var value = text.length > 12 ? '${text.substring(0, 9)}..' : text;
    return value;
  }

  generateOpmionBlock(val, isSelectedOption) {
    return Container(
      width: opnionBlockSizeWidth,
      height: opnionBlockSizeHeight,
      margin: _step == 3
          ? val == 0
              ? const EdgeInsets.only(left: 0.0)
              : const EdgeInsets.only(right: 30.0)
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (val == _start) ...[
            Positioned(
              top: positionedLabelTopValue,
              left: -1,
              child: Text(
                reversedOrder
                    ? transformLabel(endLabel)
                    : transformLabel(startLabel),
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: opnionLabelFontSize,
                  fontWeight: FontWeight.w400,
                  color: theme['decodedOpnionLabelColor'],
                  fontFamily: customFont,
                ),
              ),
            ),
          ]
          // possible style change can be changing the right to -1 and positionedLabelTopValue depending on the width
          else if (val == _mid) ...[
            Positioned(
                top: positionedLabelTopValue,
                left: -1,
                child: Text(
                  transformLabel(midLabel),
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: opnionLabelFontSize,
                    fontWeight: FontWeight.w400,
                    // color: Color.fromRGBO(67, 67, 67, 1),
                    color: theme['decodedOpnionLabelColor'],
                    fontFamily: customFont,
                  ),
                )),
          ] else if (val == _end) ...[
            Positioned(
              top: positionedLabelTopValue,
              right: 0,
              child: Text(
                reversedOrder
                    ? transformLabel(startLabel)
                    : transformLabel(endLabel),
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: opnionLabelFontSize,
                  fontWeight: FontWeight.w400,
                  color: theme['decodedOpnionLabelColor'],
                  fontFamily: customFont,
                ),
              ),
            ),
          ],
          Center(
            child: Container(
              width: innerOpnionBlockSizeWidth,
              height: innerOpnionBlockSizeHeight,
              decoration: BoxDecoration(
                color: isSelectedOption == val
                    ? theme['decodedOpnionBackgroundColorSelected']
                    : theme['decodedOpnionBackgroundColorUnSelected'],
                border: Border.all(
                  color: theme['decodedOpnionBorderColor'],
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  val.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: numberFontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelectedOption == val
                        ? luminanceValue > 0.5
                            ? Colors.black
                            : Colors.white
                        : theme['answerColor'],
                    fontFamily: customFont,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  generateNaOpinionBlock(val, isSelectedOption) {
    return Container(
      width: opnionBlockSizeWidth,
      height: opnionBlockSizeHeight,
      margin: _step == 3
          ? val == 0
              ? const EdgeInsets.only(left: 0.0)
              : const EdgeInsets.only(right: 30.0)
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: innerOpnionBlockSizeWidth,
              height: innerOpnionBlockSizeHeight,
              decoration: BoxDecoration(
                color: isSelectedOption == -2
                    ? theme['decodedOpnionBackgroundColorSelected']
                    : theme['decodedOpnionBackgroundColorUnSelected'],
                border: Border.all(
                  color: theme['decodedOpnionBorderColor'],
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  val.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: numberFontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelectedOption == -2
                        ? luminanceValue > 0.5
                            ? Colors.black
                            : Colors.white
                        : theme['answerColor'],
                    fontFamily: customFont,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getHeight(blocks) {
    if (blocks >= 11) {
      return 190.0;
    }

    if (blocks >= 6) {
      return 124.0;
    }

    return 60.0;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = List<Widget>.empty(growable: true);
    if (reversedOrder) {
      for (var i = _end; i >= _start; i--) {
        list.add(
          GestureDetector(
            onTap: () {
              updateOpnionScale(i);
            },
            child: Container(
              child: generateOpmionBlock(i, _selectedOption),
            ),
          ),
        );
      }
    } else {
      for (var i = _start; i < _end + 1; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              updateOpnionScale(i);
            },
            child: Container(
              child: generateOpmionBlock(i, _selectedOption),
            ),
          ),
        );
      }
    }

    if (hasNAoption) {
      return Row(
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 240),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runSpacing: runSpacing,
              direction: Axis.horizontal,
              children: [...list],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            color: Colors.black45,
            height: getHeight(_end + 1) + 10,
            width: 1,
          ),
          const SizedBox(
            width: 6,
          ),
          Container(
            constraints: BoxConstraints(minHeight: getHeight(_end + 1)),
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.start,
              direction: Axis.vertical,
              children: [
                GestureDetector(
                  onTap: () {
                    updateOpnionScale(-2);
                  },
                  child: Container(
                    child: generateNaOpinionBlock("N/A", _selectedOption),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runSpacing: runSpacing,
      direction: Axis.horizontal,
      children: [...list],
    );
  }
}
