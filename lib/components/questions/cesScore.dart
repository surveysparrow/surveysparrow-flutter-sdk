import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/questions/npsFeedback.dart';
import 'package:surveysparrow_flutter_sdk/helpers/cx.dart';
import 'package:surveysparrow_flutter_sdk/helpers/theme.dart';

import '../common/skipAndNext.dart';
import 'package:sizer/sizer.dart';

class CesScore extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const CesScore({
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
  State<CesScore> createState() => _CesScoreState(
      func: this.func,
      answer: this.answer,
      question: question,
      theme: this.theme,
      customParams: this.customParams,
      currentQuestionNumber: currentQuestionNumber);
}

class _CesScoreState extends State<CesScore> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  var _selectedOption = -1;

  var subQuestionData;

  _CesScoreState({
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

  handleFeedBackQuestionAnswer(value, questionId) {
    setState(() {
      subQuestionData = {'questionId': questionId, 'value': value};
    });
  }

  handleNextButtonVisibility() {
    var listSubQuestions = (this.question['subQuestions'] as List)
        .map((e) => e as Map<dynamic, dynamic>)
        .toList();
    var subQuestion;
    var hasFeedBackQuestion = false;
    if (listSubQuestions.length > 0) {
      hasFeedBackQuestion = true;
      subQuestion = listSubQuestions[0];
    }
    if (hasFeedBackQuestion) {
      if (subQuestion['required']) {
        return subQuestionData == null || _selectedOption == -1;
      } else {
        return _selectedOption == -1;
      }
    } else {
      return _selectedOption == -1;
    }
  }

  handleShowNextButton() {
    var feedBackQuestion = getFeedBackQuestion(question);
    var hasBranching = checkIfCXSurveyHasBranchingProperty(feedBackQuestion);
    if (hasBranching) {
      if (_selectedOption == -1) {
        return false;
      } else {
        return true;
      }
    } else {
      if(this.widget.isLastQuestion){
        return true;
      }
      return checkIfTheQuestionHasAFeedBack(question);
    }
  }

  @override
  initState() {
    if (this.answer[this.question['id']] != null) {

      var hasFeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
      if (hasFeedBackQuestion) {
        var feedBackQuestion = getFeedBackQuestion(question);
        handleFeedBackQuestionAnswer(
            this.answer[feedBackQuestion['id']], feedBackQuestion['id']);
      }
      setState(() {
        _selectedOption = this.answer[this.question['id']];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var listSubQuestions = (this.question['subQuestions'] as List)
        .map((e) => e as Map<dynamic, dynamic>)
        .toList();
    var subQuestion;
    var hasFeedBackQuestion = false;
    if (listSubQuestions.length > 0) {
      hasFeedBackQuestion = true;
    }

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
        CesScoreQuestion(
          func: this.func,
          answer: this.answer,
          question: this.question,
          theme: this.theme,
          setSelectedOption: setSelectedOption,
          euiTheme: this.widget.euiTheme,
          customParams: this.customParams,
          handleFeedBackQuestionAnswer: this.handleFeedBackQuestionAnswer,
        ),
        SizedBox(height: 7.h),
        // SizedBox(height: 40),
        SkipAndNextButtons(
          key: UniqueKey(),
          disabled: handleNextButtonVisibility(),
          showNext: handleShowNextButton(),
          showSkip: false,
          showSubmit: this.widget.isLastQuestion,
          onClickSkip: () {
            this.func(null, question['id']);
          },
          onClickNext: () {
            if (subQuestionData != null) {
              this.func(
                  subQuestionData['value'], subQuestionData['questionId']);
              FocusScope.of(context).requestFocus(new FocusNode());
            }
            //             isLastQuestionHandle: true);
            // this.widget.submitData();
            // if (_selectedOption != -1) {
            //   this.widget.submitData();
            // }
            if (this.widget.isLastQuestion &&
                _selectedOption != -1.0) {
              this.widget.submitData();
            }

            // if (_selectedOption != -1.0) {
            //   this.func(_selectedOption, question['id']);
            // }
          },
          
          theme: this.theme,
          euiTheme: this.widget.euiTheme,
        ),
      ],
    );
  }
}

class CesScoreQuestion extends StatefulWidget {
  final Function func;
  final Function handleFeedBackQuestionAnswer;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function setSelectedOption;
  final Map<dynamic, dynamic>? euiTheme;
  final Map<String, String> customParams;

  const CesScoreQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.setSelectedOption,
    required this.customParams,
    required this.handleFeedBackQuestionAnswer,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<CesScoreQuestion> createState() => _CesScoreQuestionState(
      func: this.func,
      answer: this.answer,
      question: this.question,
      theme: this.theme);
}

class _CesScoreQuestionState extends State<CesScoreQuestion> {
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
  _CesScoreQuestionState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
  });

  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> tooltipkeyStart = GlobalKey<TooltipState>();
  updateOpnionScale(val) {
    this.widget.setSelectedOption(val);
    setState(() {
      _selectedOption = val;
    });
    var hasfeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
    this.func(val, question['id'], changePage: !hasfeedBackQuestion);
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

  var hasFeedBackQuestion = false;
  @override
  initState() {
    super.initState();
    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }

      if (this.widget.euiTheme!['opinionScale'] != null) {
        if (this.widget.euiTheme!['opinionScale']['outerBlockWidth'] != null) {
          opnionBlockSizeWidth =
              this.widget.euiTheme!['opinionScale']['outerBlockWidth'];
        }
        if (this.widget.euiTheme!['opinionScale']['outerBlockHeight'] != null) {
          opnionBlockSizeHeight =
              this.widget.euiTheme!['opinionScale']['outerBlockHeight'];
        }

        if (this.widget.euiTheme!['opinionScale']['innerBlockWidth'] != null) {
          innerOpnionBlockSizeWidth =
              this.widget.euiTheme!['opinionScale']['innerBlockWidth'];
        }
        if (this.widget.euiTheme!['opinionScale']['innerBlockHeight'] != null) {
          innerOpnionBlockSizeHeight =
              this.widget.euiTheme!['opinionScale']['innerBlockHeight'];
        }
        if (this.widget.euiTheme!['opinionScale']['labelFontSize'] != null) {
          opnionLabelFontSize =
              this.widget.euiTheme!['opinionScale']['labelFontSize'];
        }
        if (this.widget.euiTheme!['opinionScale']['numberFontSize'] != null) {
          numberFontSize =
              this.widget.euiTheme!['opinionScale']['numberFontSize'];
        }
        if (this.widget.euiTheme!['opinionScale']['runSpacing'] != null) {
          runSpacing = this.widget.euiTheme!['opinionScale']['runSpacing'];
        }
        if (this.widget.euiTheme!['opinionScale']['positionedLabelTopValue'] !=
            null) {
          positionedLabelTopValue =
              this.widget.euiTheme!['opinionScale']['positionedLabelTopValue'];
        }
      }
    }

    startLabel = this.question['properties']['data']['labels']['left'] ==
            'builder.ces_score.min'
        ? 'Strongly Disagree'
        : this.question['properties']['data']['labels']['left'];
    midLabel = 'Neutral';
    endLabel = this.question['properties']['data']['labels']['right'] ==
            'builder.ces_score.max'
        ? 'Strongly Agree'
        : this.question['properties']['data']['labels']['right'];

    luminanceValue =
        this.theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    if (this.question['properties'] != null &&
        this.question['properties']['data'] != null &&
        this.question['properties']['data']['reversedOrder'] != null) {
      reversedOrder = this.question['properties']['data']['reversedOrder'];
    }

    this.generateStartStep(
        7, this.question['properties']['data']['startWithOne'] ? 1 : 0);

    if (this.answer[this.question['id']] != null) {
      setState(() {
        _selectedOption = this.answer[this.question['id']];
        hasFeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
      });
    } else {
      setState(() {
        _selectedOption = -1;
        hasFeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
      });
    }
  }

  transformLabel(text) {
    var value = text.length > 18 ? '${text.substring(0, 12)}...' : text;
    return value;
  }

  handleFeedBackText(text, questionId) {
    this.widget.handleFeedBackQuestionAnswer(text, questionId);
  }

  getOpnionScaleBlockColorUnSelected(val) {
    var hasSegmentedOpton = checkIfCXSurveyHasSegmentedOption(question);

    if (hasSegmentedOpton) {
      var promoters =
          this.question['properties']['data']['segmentColors']['lowEffort'];
      var passives =
          this.question['properties']['data']['segmentColors']['neutral'];
      var detractors =
          this.question['properties']['data']['segmentColors']['highEffort'];

      if (val <= 3) {
        return convertRgbToColor(('#' + detractors), 1.0);
      }
      if (val <= 4) {
        return convertRgbToColor(('#' + passives), 1.0);
      }
      return convertRgbToColor(('#' + promoters), 1.0);
    }
    return this.theme['decodedOpnionBackgroundColorUnSelected'];
  }

  getOpnionScaleBlockColorSelected(val) {
    var hasSegmentedOpton = checkIfCXSurveyHasSegmentedOption(question);
    if (hasSegmentedOpton) {
      return darkenColor(getOpnionScaleBlockColorUnSelected(val), 0.17);
    }
    return this.theme['decodedOpnionBackgroundColorSelected'];
  }

  getOptionScaleBorderColor(val) {
    var hasSegmentedOpton = checkIfCXSurveyHasSegmentedOption(question);
    if (hasSegmentedOpton) {
      return darkenColor(getOpnionScaleBlockColorUnSelected(val), 0.17);
    }
    return this.theme['decodedOpnionBorderColor'];
  }

  getAnswerColor(val, isSelectedOption) {
    var hasSegmentedOpton = checkIfCXSurveyHasSegmentedOption(question);
    if (hasSegmentedOpton) {
      var segementedOptionluminanceValue =
          getOpnionScaleBlockColorUnSelected(val).computeLuminance();
      return segementedOptionluminanceValue > 0.5 ? Colors.black : Colors.white;
    }
    return isSelectedOption == val
        ? luminanceValue > 0.5
            ? Colors.black
            : Colors.white
        : this.theme['answerColor'];
  }

  generateOpmionBlock(val, isSelectedOption) {
    return Container(
      width: opnionBlockSizeWidth,
      height: opnionBlockSizeHeight,
      margin: _step == 3
          ? val == 0
              ? EdgeInsets.only(left: 0.0)
              : EdgeInsets.only(right: 30.0)
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (val == _start) ...[
            Positioned(
              top: positionedLabelTopValue,
              left: -1,
              child: Container(
                  child: Tooltip(
                message: startLabel,
                key: tooltipkeyStart,
                triggerMode: TooltipTriggerMode.manual,
                child: InkWell(
                  onTap: () {
                    tooltipkeyStart.currentState?.ensureTooltipVisible();
                  },
                  child: Text(
                    reversedOrder
                        ? transformLabel(endLabel)
                        : transformLabel(startLabel),
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: opnionLabelFontSize,
                      fontWeight: FontWeight.w400,
                      // overflow: TextOverflow.ellipsis,
                      // color: Color.fromRGBO(67, 67, 67, 1),
                      color: this.theme['decodedOpnionLabelColor'],
                      fontFamily: customFont,
                    ),
                  ),
                ),
              )),
            ),
          ]
          else if (val == _end) ...[
            Positioned(
              top: positionedLabelTopValue,
              right: 0,
              child: Container(
                child: Tooltip(
                  message: endLabel,
                  key: tooltipkey,
                  triggerMode: TooltipTriggerMode.manual,
                  child: InkWell(
                    onTap: () {
                      tooltipkey.currentState?.ensureTooltipVisible();
                    },
                    child: Text(
                      reversedOrder
                          ? transformLabel(startLabel)
                          : transformLabel(endLabel),
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: opnionLabelFontSize,
                        fontWeight: FontWeight.w400,
                        color: this.theme['decodedOpnionLabelColor'],
                        fontFamily: customFont,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Center(
            child: Container(
              // color: Color.fromARGB(255, 255, 247, 0),
              width: innerOpnionBlockSizeWidth,
              height: innerOpnionBlockSizeHeight,
              // constraints: BoxConstraints(
              //    maxHeight: 40,maxWidth: 40),
              decoration: BoxDecoration(
                color: isSelectedOption == val
                    ? getOpnionScaleBlockColorSelected(val)
                    : getOpnionScaleBlockColorUnSelected(val),
                border: Border.all(
                  // color: Color.fromRGBO(63, 63, 63, 0.5),
                  // color: this.theme['decodedOpnionBorderColor'],
                  color: getOptionScaleBorderColor(val),
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
                    color: getAnswerColor(val, isSelectedOption),
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

  showFeedBackQuestion() {
    var feedBackQuestion = getFeedBackQuestion(question);
    var hasBranching = checkIfCXSurveyHasBranchingProperty(feedBackQuestion);
    if (hasBranching) {
      if (_selectedOption == -1) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;

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

    var listSubQuestions = (this.question['subQuestions'] as List)
        .map((e) => e as Map<dynamic, dynamic>)
        .toList();
    var subQuestion;
    if (listSubQuestions.length > 0) {
      subQuestion = Map<dynamic, dynamic>.from(listSubQuestions[0]);
    }

    // possible change is change the alignment for container to wrapalignment to start if needed in tablet

    // Have removed width:doubly.infinity

    return Column(
      children: [
        Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            runSpacing: runSpacing,
            direction: Axis.horizontal,
            children: [...list],
          ),
        ),
        SizedBox(height: 40),
        if (hasFeedBackQuestion && showFeedBackQuestion()) ...[
          FeedBackText(
            func: func,
            answer: answer,
            question: subQuestion,
            theme: theme,
            customParams: widget.customParams,
            handleFeedBackText: handleFeedBackText,
            parentQuestion: this.question,
          )
        ],
      ],
    );
  }
}