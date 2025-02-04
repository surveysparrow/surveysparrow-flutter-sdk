import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';

import '../common/skipAndNext.dart';

class ColumnRating extends StatefulWidget {
  const ColumnRating({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
    required this.lastQuestionId,
    required this.submitData,
    required this.euiTheme,
  }) : super(key: key);

  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final lastQuestionId;
  final Map<dynamic, dynamic>? euiTheme;

  @override
  State<ColumnRating> createState() => _ColumnRatingState(
        func: func,
        answer: answer,
        question: question,
        theme: theme,
        customParams: customParams,
        currentQuestionNumber: currentQuestionNumber,
      );
}

class _ColumnRatingState extends State<ColumnRating> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  double _selectedOption = -1.0;

  _ColumnRatingState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
  });

  @override
  initState() {
    super.initState();
    if (answer[question['id']] != null) {
      _selectedOption = answer[question['id']];
    }
  }

  setSelectedOption(val) {
    _selectedOption = val;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QuestionColumn(
          question: question,
          currentQuestionNumber: currentQuestionNumber,
          customParams: customParams,
          theme: theme,
          euiTheme: widget.euiTheme,
        ),
        RatingQuestion(
          func: func,
          answer: answer,
          question: question,
          theme: theme,
          setSelectedOption: setSelectedOption,
          euiTheme: widget.euiTheme,
        ),
        const SizedBox(height: 40),
        SkipAndNextButtons(
          key: UniqueKey(),
          disabled: widget.isLastQuestion
              ? question['required']
                  ? _selectedOption == -1.0
                  : false
              : _selectedOption == -1.0,
          showNext: widget.isLastQuestion,
          showSkip:
              (question['required'] || widget.isLastQuestion) ? false : true,
          showSubmit: widget.isLastQuestion,
          onClickSkip: () {
            func(null, question['id']);
          },
          onClickNext: () {
            if (_selectedOption != -1.0) {
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

class RatingQuestion extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function setSelectedOption;
  final Map<dynamic, dynamic>? euiTheme;
  const RatingQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.setSelectedOption,
    required this.euiTheme,
  }) : super(key: key);

  @override
  State<RatingQuestion> createState() => _RatingQuestionState(
      func: func, answer: answer, question: question, theme: theme);
}

class _RatingQuestionState extends State<RatingQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  double _rating = -1.0;
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
    if (question['properties']['data']['iconArrayName'] == "RATING_SMILEY") {
      if (_rating - 1 == index.toDouble()) {
        return Row(
          children: [
            Column(
              children: [
                SizedBox(
                  height: svgHeight,
                  width: svgWidth,
                  child: SvgPicture.string(
                    getSmiliySvg(
                      question['properties']['data']['ratingScale'],
                      true,
                      index,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedOpacity(
                  opacity: widget1Opacity,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    hasNumber ? (index + 1).toString() : '',
                    style: TextStyle(color: theme['decodedOpnionLabelColor']),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            )
          ],
        );
      }
      return Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: svgHeight,
                width: svgWidth,
                child: SvgPicture.string(
                  getSmiliySvg(question['properties']['data']['ratingScale'],
                      false, index),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                opacity: widget1Opacity,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  hasNumber ? (index + 1).toString() : '',
                  style: TextStyle(color: theme['decodedOpnionLabelColor']),
                ),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          )
        ],
      );
    } else {
      if (_rating > index.toDouble()) {
        return Row(
          children: [
            Column(
              children: [
                SizedBox(
                  height: svgHeight,
                  width: svgWidth,
                  child: SvgPicture.string(
                    getRatingSvg(
                      question['properties']['data']['iconArrayName'],
                      1,
                      theme['ratingRgba'],
                      theme['ratingRgba'],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedOpacity(
                  opacity: widget1Opacity,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    hasNumber ? (index + 1).toString() : '',
                    style: TextStyle(color: theme['decodedOpnionLabelColor']),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            )
          ],
        );
      }
      return Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: svgHeight,
                width: svgWidth,
                child: SvgPicture.string(
                  getRatingSvg(
                    question['properties']['data']['iconArrayName'],
                    0.5,
                    'none',
                    theme['ratingRgba'],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                opacity: widget1Opacity,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  hasNumber ? (index + 1).toString() : '',
                  style: TextStyle(color: theme['decodedOpnionLabelColor']),
                ),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          )
        ],
      );
    }
  }

  bool hasNumber = true;
  var customSvgSelected = null;
  var svgHeight = 42.0;
  var svgWidth = 42.0;

  @override
  initState() {
    super.initState();
    if (widget.euiTheme != null) {
      if (widget.euiTheme!['rating'] != null) {
        if (widget.euiTheme!['rating']['hasNumber'] != null) {
          hasNumber = widget.euiTheme!['rating']['hasNumber'];
        }
        if (widget.euiTheme!['rating']['customRatingSVGUnselected'] != null) {
          customSvg = widget.euiTheme!['rating']['customRatingSVGUnselected'];
        }
        if (widget.euiTheme!['rating']['customRatingSVGSelected'] != null) {
          customSvgSelected =
              widget.euiTheme!['rating']['customRatingSVGSelected'];
        }
        if (widget.euiTheme!['rating']['svgHeight'] != null) {
          svgHeight = widget.euiTheme!['rating']['svgHeight'];
        }
        if (widget.euiTheme!['rating']['svgWidth'] != null) {
          svgWidth = widget.euiTheme!['rating']['svgWidth'];
        }
      }
    }
    if (answer[question['id']] != null) {
      setState(() {
        _rating = answer[question['id']];
      });
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        widget1Opacity = 1.0;
      });
    });
  }

  _RatingQuestionState(
      {required this.func,
      required this.answer,
      required this.question,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    final stars = List<Widget>.generate(
        question['properties']['data']['ratingScale'], (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _rating = index + 1.toDouble();
          });
          func(index + 1.toDouble(), question['id']);
          widget.setSelectedOption(index + 1.toDouble());
        },
        child: _buildRatingStart(index),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...stars],
    );
  }
}

class RatingSvg extends StatefulWidget {
  const RatingSvg({Key? key}) : super(key: key);

  @override
  State<RatingSvg> createState() => _RatingSvgState();
}

class _RatingSvgState extends State<RatingSvg> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}