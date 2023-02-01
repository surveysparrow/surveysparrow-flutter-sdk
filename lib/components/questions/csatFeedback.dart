import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/questions/npsFeedback.dart';
import 'package:surveysparrow_flutter_sdk/helpers/cx.dart';
import 'package:surveysparrow_flutter_sdk/helpers/theme.dart';

import '../common/skipAndNext.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';

import '../common/skipAndNext.dart';

class Csat extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const Csat({
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
  State<Csat> createState() => _CsatState(
      func: this.func,
      answer: this.answer,
      question: question,
      theme: this.theme,
      customParams: this.customParams,
      currentQuestionNumber: currentQuestionNumber);
}

class _CsatState extends State<Csat> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  var _selectedOption = -1;

  var subQuestionData;

  _CsatState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
  });

  setSelectedOption(val) {
    setState(() {
      _selectedOption = val.toInt();
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
      if (this.widget.isLastQuestion) {
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
        CsatQuestion(
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
            if (this.widget.isLastQuestion && _selectedOption != -1) {
              this.widget.submitData();
            }

            // if (_selectedOption != -1) {
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

class CsatQuestion extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function setSelectedOption;
  final Map<dynamic, dynamic>? euiTheme;
  final Map<String, String> customParams;
  final Function handleFeedBackQuestionAnswer;

  const CsatQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.setSelectedOption,
    required this.euiTheme,
    required this.customParams,
    required this.handleFeedBackQuestionAnswer,
  }) : super(key: key);

  @override
  State<CsatQuestion> createState() => _CsatQuestionState(
      func: this.func,
      answer: this.answer,
      question: this.question,
      theme: this.theme);
}

class _CsatQuestionState extends State<CsatQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  int _rating = -1;
  double widget1Opacity = 0.0;
  var customSvg = null;

  getRatingSvg(svgName, opacity, color, border) {
    if (opacity == 0.5 && customSvg != null) {
      return customSvg;
    }
    if (opacity == 1 && customSvg != null) {
      return customSvgSelected;
    }
    switch (svgName) {
      case 'RATING_STAR':
        return generateStarSvg(border, color, opacity);
      case 'RATING_THUMBSUP':
        return generateThumbSvg(border, color, opacity);
      case 'RATING_CROWN':
        return generateCrownSvg(border, color, opacity);
      case 'RATING_USER':
        return generateIconSvg(border, color, opacity);
      case 'RATING_LIGHTNING':
        return generateBoltSvg(border, color, opacity);
      default:
        return generateStarSvg(border, color, opacity);
    }
  }

  getSmiliySvg(type, isSelected, curIndex) {
    switch (type) {
      case 5:
        if (curIndex == 0) {
          var emoji = isSelected == true
              ? generateRatingSimilyOne(
                  'rgb(255,255,255)', 'rgb(236,103,114)', 'rgb(236,103,114)', 1)
              : generateRatingSimilyOne('rgb(236,103,114)', 'rgb(255,255,255)',
                  'rgb(236,103,114)', 0.5);
          return emoji;
        }
        if (curIndex == 1) {
          var emoji = isSelected == true
              ? generateRatingSmilyTwo(
                  'rgb(255,255,255)', '#d9864c', '#d9864c', 1)
              : generateRatingSmilyTwo(
                  '#d9864c', 'rgb(255,255,255)', '#d9864c', 0.5);
          return emoji;
        }
        if (curIndex == 2) {
          var emoji = isSelected == true
              ? generateRatingSmilyThree(
                  'rgb(255,255,255)', '#b2a24b', '#b2a24b', 1)
              : generateRatingSmilyThree(
                  '#b2a24b', 'rgb(255,255,255)', '#b2a24b', 0.5);
          return emoji;
        }
        if (curIndex == 3) {
          var emoji = isSelected == true
              ? generateRatingSmilyFour(
                  'rgb(255,255,255)', '#84b671', '#84b671', 1)
              : generateRatingSmilyFour(
                  '#84b671', 'rgb(255,255,255)', '#84b671', 0.5);
          return emoji;
        } else {
          var emoji = isSelected == true
              ? generateRatingSmilyFive(
                  'rgb(255,255,255)', '#069858', '#069858', 1)
              : generateRatingSmilyFive(
                  '#069858', 'rgb(255,255,255)', '#069858', 0.5);
          return emoji;
        }
      case 4:
        if (curIndex == 0) {
          var emoji = isSelected == true
              ? generateRatingSimilyOne(
                  'rgb(255,255,255)', 'rgb(236,103,114)', 'rgb(236,103,114)', 1)
              : generateRatingSimilyOne('rgb(236,103,114)', 'rgb(255,255,255)',
                  'rgb(236,103,114)', 0.5);
          return emoji;
        }
        if (curIndex == 1) {
          var emoji = isSelected == true
              ? generateRatingSmilyThree(
                  'rgb(255,255,255)', '#b2a24b', '#b2a24b', 1)
              : generateRatingSmilyThree(
                  '#b2a24b', 'rgb(255,255,255)', '#b2a24b', 0.5);
          return emoji;
        }
        if (curIndex == 2) {
          var emoji = isSelected == true
              ? generateRatingSmilyFour(
                  'rgb(255,255,255)', '#84b671', '#84b671', 1)
              : generateRatingSmilyFour(
                  '#84b671', 'rgb(255,255,255)', '#84b671', 0.5);
          return emoji;
        } else {
          var emoji = isSelected == true
              ? generateRatingSmilyFive(
                  'rgb(255,255,255)', '#069858', '#069858', 1)
              : generateRatingSmilyFive(
                  '#069858', 'rgb(255,255,255)', '#069858', 0.5);
          return emoji;
        }
      case 3:
        if (curIndex == 0) {
          var emoji = isSelected == true
              ? generateRatingSimilyOne(
                  'rgb(255,255,255)', 'rgb(236,103,114)', 'rgb(236,103,114)', 1)
              : generateRatingSimilyOne('rgb(236,103,114)', 'rgb(255,255,255)',
                  'rgb(236,103,114)', 0.5);
          return emoji;
        }
        if (curIndex == 1) {
          var emoji = isSelected == true
              ? generateRatingSmilyThree(
                  'rgb(255,255,255)', '#b2a24b', '#b2a24b', 1)
              : generateRatingSmilyThree(
                  '#b2a24b', 'rgb(255,255,255)', '#b2a24b', 0.5);
          return emoji;
        } else {
          var emoji = isSelected == true
              ? generateRatingSmilyFive(
                  'rgb(255,255,255)', '#069858', '#069858', 1)
              : generateRatingSmilyFive(
                  '#069858', 'rgb(255,255,255)', '#069858', 0.5);
          return emoji;
        }
    }
  }

  _buildRatingStart(int index) {
    if (_rating - 1 == index) {
      return Row(
        children: [
          Column(
            children: [
              Container(
                height: svgHeight,
                width: svgWidth,
                child: SvgPicture.string(
                  getSmiliySvg(
                    this.question['properties']['data']['ratingScale'],
                    true,
                    index,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                opacity: widget1Opacity,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  hasNumber ? (index + 1).toString() : '',
                  style:
                      TextStyle(color: this.theme['decodedOpnionLabelColor']),
                ),
              )
            ],
          ),
          SizedBox(
            width: 10,
          )
        ],
      );
    }
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: svgHeight,
              width: svgWidth,
              child: SvgPicture.string(
                getSmiliySvg(this.question['properties']['data']['ratingScale'],
                    false, index),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AnimatedOpacity(
              opacity: widget1Opacity,
              duration: const Duration(milliseconds: 200),
              child: Text(
                hasNumber ? (index + 1).toString() : '',
                style: TextStyle(color: this.theme['decodedOpnionLabelColor']),
              ),
            )
          ],
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }

  bool hasNumber = true;
  var customSvgSelected = null;
  var svgHeight = 42.0;
  var svgWidth = 42.0;
  var hasFeedBackQuestion = false;

  @override
  initState() {
    super.initState();
    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['rating'] != null) {
        if (this.widget.euiTheme!['rating']['hasNumber'] != null) {
          hasNumber = this.widget.euiTheme!['rating']['hasNumber'];
        }
        if (this.widget.euiTheme!['rating']['customRatingSVGUnselected'] !=
            null) {
          customSvg =
              this.widget.euiTheme!['rating']['customRatingSVGUnselected'];
        }
        if (this.widget.euiTheme!['rating']['customRatingSVGSelected'] !=
            null) {
          customSvgSelected =
              this.widget.euiTheme!['rating']['customRatingSVGSelected'];
        }
        if (this.widget.euiTheme!['rating']['svgHeight'] != null) {
          svgHeight = this.widget.euiTheme!['rating']['svgHeight'];
        }
        if (this.widget.euiTheme!['rating']['svgWidth'] != null) {
          svgWidth = this.widget.euiTheme!['rating']['svgWidth'];
        }
      }
    }
    if (this.answer[this.question['id']] != null) {
      setState(() {
        _rating = this.answer[this.question['id']];
        hasFeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
      });
    } else{
      setState(() {
        hasFeedBackQuestion = checkIfTheQuestionHasAFeedBack(question);
      });
    }
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        widget1Opacity = 1.0;
      });
    });
  }

  _CsatQuestionState(
      {required this.func,
      required this.answer,
      required this.question,
      required this.theme});

  showFeedBackQuestion() {
    var feedBackQuestion = getFeedBackQuestion(question);
    var hasBranching = checkIfCXSurveyHasBranchingProperty(feedBackQuestion);
    if (hasBranching) {
      if (_rating == -1) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  handleFeedBackText(text, questionId) {
    this.widget.handleFeedBackQuestionAnswer(text, questionId);
  }

  

  @override
  Widget build(BuildContext context) {
    final stars = List<Widget>.generate(
        this.question['properties']['data']['ratingScale'], (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _rating = index + 1;
          });
          this.func(index + 1, question['id']);
          this.widget.setSelectedOption(index + 1);
        },
        child: _buildRatingStart(index),
      );
    });

    var listSubQuestions = (this.question['subQuestions'] as List)
        .map((e) => e as Map<dynamic, dynamic>)
        .toList();
    var subQuestion;
    if (listSubQuestions.length > 0) {
      subQuestion = Map<dynamic, dynamic>.from(listSubQuestions[0]);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...stars],
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
