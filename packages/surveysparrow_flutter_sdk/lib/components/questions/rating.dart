import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
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
        func: this.func,
        answer: this.answer,
        question: question,
        theme: this.theme,
        customParams: this.customParams,
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
    if (this.answer[this.question['id']] != null) {
      _selectedOption = this.answer[this.question['id']];
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
          currentQuestionNumber: this.currentQuestionNumber,
          customParams: this.customParams,
          theme: this.theme,
          euiTheme: this.widget.euiTheme,
        ),
        RatingQuestion(
          func: this.func,
          answer: this.answer,
          question: this.question,
          theme: this.theme,
          setSelectedOption: setSelectedOption,
          euiTheme: this.widget.euiTheme,
        ),
        SizedBox(height: 40),
        //!this.question['required']
        SkipAndNextButtons(
          key: UniqueKey(),
          disabled: _selectedOption == -1.0,
          showNext: this.widget.isLastQuestion,
          showSkip: (this.question['required'] || this.widget.isLastQuestion)
              ? false
              : true,
          showSubmit: this.widget.isLastQuestion,
          onClickSkip: () {
            this.func(null, question['id']);
          },
          onClickNext: () {
            if (_selectedOption != -1.0) {
              this.widget.submitData();
            }
          },
          theme: theme,
          euiTheme: this.widget.euiTheme,
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
      func: this.func,
      answer: this.answer,
      question: this.question,
      theme: this.theme);
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
    if (this.question['properties']['data']['iconArrayName'] ==
        "RATING_SMILEY") {
      if (_rating - 1 == index.toDouble()) {
        return Row(
          children: [
            Column(
              children: [
                SvgPicture.string(
                  getSmiliySvg(
                    this.question['properties']['data']['ratingScale'],
                    true,
                    index,
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
              SvgPicture.string(
                getSmiliySvg(this.question['properties']['data']['ratingScale'],
                    false, index),
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
    } else {
      if (_rating > index.toDouble()) {
        return Row(
          children: [
            Column(
              children: [
                Container(
                  height: svgHeight,
                  width: svgWidth,
                  child: SvgPicture.string(
                    getRatingSvg(
                      this.question['properties']['data']['iconArrayName'],
                      1,
                      this.theme['ratingRgba'],
                      this.theme['ratingRgba'],
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
                  getRatingSvg(
                    this.question['properties']['data']['iconArrayName'],
                    0.5,
                    'none',
                    this.theme['ratingRgba'],
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
  }

  bool hasNumber = true;
  var customSvgSelected = null;
  var svgHeight = 42.0;
  var svgWidth = 42.0;

  @override
  initState() {
    super.initState();
    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['rating'] != null) {
        if (this.widget.euiTheme!['rating']['hasNumber'] != null) {
          hasNumber = this.widget.euiTheme!['rating']['hasNumber'];
        }
        if (this.widget.euiTheme!['rating']['customRatingSVGUnselected'] != null) {
          customSvg = this.widget.euiTheme!['rating']['customRatingSVGUnselected'];
        }
        if (this.widget.euiTheme!['rating']['customRatingSVGSelected'] != null) {
          customSvgSelected = this.widget.euiTheme!['rating']['customRatingSVGSelected'];
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
      });
    }
    Future.delayed(Duration(milliseconds: 400), () {
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
        this.question['properties']['data']['ratingScale'], (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _rating = index + 1.toDouble();
          });
          this.func(index + 1.toDouble(), question['id']);
          this.widget.setSelectedOption(index + 1.toDouble());
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


// Icon(
//   Icons.star_rounded,
//   size: 60,
//   color: this.theme['answerColor'],
// ),