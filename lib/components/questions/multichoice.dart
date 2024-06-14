import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/common/skipAndNext.dart';

class MultiChoice extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;
  final Function toggleNextButtonBlock;

  const MultiChoice({
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
    required this.toggleNextButtonBlock,
  }) : super(key: key);

  @override
  State<MultiChoice> createState() => _MultiChoiceState(
        func: func,
        answer: answer,
        question: question,
        theme: theme,
        customParams: customParams,
        currentQuestionNumber: currentQuestionNumber,
      );
}

class _MultiChoiceState extends State<MultiChoice> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;

  var _selectedOptions = [];
  var hasNextButton = false;
  var hasOtherInput = false;
  var hasOtherInputText = "";
  var otherInputId = -1;

  var inputError = false;
  var inputErrorMsg = "Please select 1 or more choice";
  var inputErrorType = -1;

  var otherInputDisabled = false;

  _MultiChoiceState({
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

    for (var i = 0; i < question['choices'].length; i++) {
      if (question['choices'][i]['other']) {
        otherInputId = question['choices'][i]['id'];
        if (answer[question['id']] != null) {
          if (answer[question['id']].contains(question['choices'][i]['id'])) {
            hasNextButton = true;
          }
        }
      }
    }

    if (answer['${question['id']}_other'] != null) {
      hasOtherInputText = answer['${question['id']}_other'];
      hasNextButton = question['multipleAnswers'];
      if (_selectedOptions.contains(otherInputId)) {
        if (answer['${question['id']}_other'] == "") {
          widget.toggleNextButtonBlock(true);
          otherInputDisabled = true;
        } else {
          widget.toggleNextButtonBlock(false);
          otherInputDisabled = false;
        }
      }
    } else {
      hasNextButton = question['multipleAnswers'];
    }

    if (answer[question['id']] != null) {
      _selectedOptions = answer[question['id']];
      checkIfSelectedOptionsValid();
    }
  }

  setSelectedOptions(options) {
    setState(() {
      _selectedOptions = options;
    });
    checkIfSelectedOptionsValid();
  }

  setShowNextButton(val) {
    if (val == true) {
      hasOtherInput = true;
    }
    setState(() {
      hasNextButton = val;
    });
  }

  setOtherTextInput(val) {
    hasOtherInputText = val;
    if (_selectedOptions.contains(otherInputId)) {
      if (val == "") {
        widget.toggleNextButtonBlock(true);
        setState(() {
          otherInputDisabled = true;
        });
      } else {
        widget.toggleNextButtonBlock(false);
        setState(() {
          otherInputDisabled = false;
        });
      }
    }
  }

  setChoiceError(error, msg) {
    if (error) {
      setState(() {
        inputError = true;
        inputErrorMsg = msg;
      });
    } else {
      inputError = false;
    }
  }

  checkIfSelectedOptionsValid() {
    if (otherInputId != -1 && !_selectedOptions.contains(otherInputId)) {
      widget.toggleNextButtonBlock(false);
      setState(() {
        otherInputDisabled = false;
      });
    }

    if (question['properties']['data']['type'] == 'EXACT') {
      if (_selectedOptions.length ==
          int.parse(question['properties']['data']['exactChoices'])) {
        // set blocked false
        widget.toggleNextButtonBlock(false);
      } else {
        // set blocked true
        widget.toggleNextButtonBlock(true);
      }
    } else if (question['properties']['data']['type'] == 'RANGE') {
      if (_selectedOptions.length >=
              int.parse(question['properties']['data']['minLimit']) &&
          _selectedOptions.length <=
              int.parse(question['properties']['data']['maxLimit'])) {
        widget.toggleNextButtonBlock(false);
        // set blocked false
      } else {
        // set blocked true
        widget.toggleNextButtonBlock(true);
      }
    } else {
      widget.toggleNextButtonBlock(false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              currentQuestionNumber: currentQuestionNumber,
              customParams: customParams,
              theme: theme,
              euiTheme: widget.euiTheme,
            ),
            MultipleChoiceRow(
              answer: answer,
              func: func,
              question: question,
              theme: theme,
              setSelectedOptions: setSelectedOptions,
              setShowNextButton: setShowNextButton,
              setOtherTextInput: setOtherTextInput,
              inputError: inputError,
              inputErrorMsg: inputErrorMsg,
              euiTheme: widget.euiTheme,
              toggleNextButtonBlock: widget.toggleNextButtonBlock,
            ),
            const SizedBox(height: 30),
            SkipAndNextButtons(
              key: UniqueKey(),
              disabled: widget.isLastQuestion
                  ? question['required']
                      ? otherInputDisabled == true
                          ? true
                          : _selectedOptions.isNotEmpty
                              ? false
                              : true
                      : otherInputDisabled == true
                          ? true
                          : false
                  : _selectedOptions.isNotEmpty
                      ? false
                      : true,
              showNext: hasNextButton || widget.isLastQuestion,
              showSkip: (question['required'] || widget.isLastQuestion)
                  ? false
                  : true,
              showSubmit: widget.isLastQuestion,
              onClickNext: () {
                if (widget.isLastQuestion && !question['required']) {
                  widget.submitData();
                  return;
                }
                if (question['properties']['data']['type'] == 'EXACT') {
                  if (_selectedOptions.length ==
                      int.parse(
                          question['properties']['data']['exactChoices'])) {
                    func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(true,
                        "Please select ${question['properties']['data']['exactChoices']} choices");
                  }
                } else if (question['properties']['data']['type'] == 'RANGE') {
                  if (_selectedOptions.length >=
                          int.parse(
                              question['properties']['data']['minLimit']) &&
                      _selectedOptions.length <=
                          int.parse(
                              question['properties']['data']['maxLimit'])) {
                    func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(true,
                        "Please select choices between ${int.parse(question['properties']['data']['minLimit'])} and ${int.parse(question['properties']['data']['maxLimit'])} ");
                  }
                } else {
                  if (_selectedOptions.isNotEmpty) {
                    func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(true, "Please select atleast 1 choice");
                  }
                }
                if (inputError == false && widget.isLastQuestion) {
                  widget.submitData();
                }
              },
              onClickSkip: () {
                widget.toggleNextButtonBlock(false);
                func(null, question['id']);
              },
              theme: theme,
              euiTheme: widget.euiTheme,
            ),
          ],
        ),
      ],
    );
  }
}

class MultipleChoiceRow extends StatefulWidget {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Function? setSelectedOptions;
  final Function? setShowNextButton;
  final Function? setOtherTextInput;
  final bool inputError;
  final String inputErrorMsg;
  final Map<dynamic, dynamic>? euiTheme;
  final Function toggleNextButtonBlock;

  MultipleChoiceRow({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    this.setSelectedOptions,
    this.setShowNextButton,
    this.setOtherTextInput,
    required this.inputError,
    required this.inputErrorMsg,
    this.euiTheme,
    required this.toggleNextButtonBlock,
  }) : super(key: key);

  @override
  State<MultipleChoiceRow> createState() => _MultipleChoiceRowState(
        func: func,
        answer: answer,
        question: question,
        theme: theme,
      );
}

class _MultipleChoiceRowState extends State<MultipleChoiceRow> {
  TextEditingController inputController = TextEditingController();
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  var _selectedOption = [];
  var choiceToUpdateIs = [];

  var luminanceValue = 0.5;
  var isMultipleAnswer = false;
  var hasNoneOfOption = -1;
  var hasAllOfOption = -1;
  var hasOtherOption = -1;
  var allOptions = [];

  var inputError = false;
  var inputErrorMsg = "Please select 1 or more choice";
  var inputErrorType = -1;

  var hasNoneOfOptionJson = {};
  var hasAllOfOptionJson = {};
  var hasOtherOptionJson = {};

  var isNextButtonBlocked = false;

  _MultipleChoiceRowState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
  });

  var customFont = null;
  var newList = [];

  double choiceContainerWidth = 320.0;
  double choiceContainerHeight = 50.0;
  double fontSize = 16.0;
  double circularFontContainerSize = 32.0;
  double otherOptionTextFieldHeight = 50.0;
  var otherOptionTextFieldWidth;
  double otherOptionTextFontSize = 20.0;

  var multipleChoiceChoices = [];

  var shuffle = false;

  @override
  initState() {
    super.initState();

    isNextButtonBlocked = false;

    if (question['randomized'] != null) {
      shuffle = question['randomized'];
    }

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['multipleChoice'] != null) {
        if (widget.euiTheme!['multipleChoice']['choiceContainerWidth'] !=
            null) {
          choiceContainerWidth =
              widget.euiTheme!['multipleChoice']['choiceContainerWidth'];
        }
        if (widget.euiTheme!['multipleChoice']['choiceContainerHeight'] !=
            null) {
          choiceContainerHeight =
              widget.euiTheme!['multipleChoice']['choiceContainerHeight'];
        }
        if (widget.euiTheme!['multipleChoice']['fontSize'] != null) {
          fontSize = widget.euiTheme!['multipleChoice']['fontSize'];
        }
        if (widget.euiTheme!['multipleChoice']['circularFontContainerSize'] !=
            null) {
          circularFontContainerSize =
              widget.euiTheme!['multipleChoice']['circularFontContainerSize'];
        }
        if (widget.euiTheme!['multipleChoice']['otherOptionTextFieldHeight'] !=
            null) {
          otherOptionTextFieldHeight =
              widget.euiTheme!['multipleChoice']['otherOptionTextFieldHeight'];
        }
        if (widget.euiTheme!['multipleChoice']['otherOptionTextFieldWidth'] !=
            null) {
          otherOptionTextFieldWidth =
              widget.euiTheme!['multipleChoice']['otherOptionTextFieldWidth'];
        }
        if (widget.euiTheme!['multipleChoice']['otherOptionTextFontSize'] !=
            null) {
          otherOptionTextFontSize =
              widget.euiTheme!['multipleChoice']['otherOptionTextFontSize'];
        }
      }
    }

    inputController.text = '';

    if (answer['${question['id']}_other'] != null) {
      inputController.text = answer['${question['id']}_other'];
    } else {
      inputController.text = '';
    }

    luminanceValue =
        theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    isMultipleAnswer = question['multipleAnswers'];

    for (var i = 0; i < question['choices'].length; i++) {
      initilizeChoices(question['choices'][i], question['choices'][i]['id']);
    }

    var normalChoices = [];
    var specialChoices = [];

    //     var hasNoneOfOption = -1;
    // var hasAllOfOption = -1;
    // var hasOtherOption = -1;
    for (var i = 0; i < question['choices'].length; i++) {
      if (question['choices'][i]['id'] == hasAllOfOption ||
          question['choices'][i]['id'] == hasNoneOfOption ||
          question['choices'][i]['id'] == hasOtherOption) {
        specialChoices.add(question['choices'][i]);
      } else {
        normalChoices.add(question['choices'][i]);
      }
    }
    if (shuffle) {
      normalChoices.shuffle();
    }

    multipleChoiceChoices = [...normalChoices, ...specialChoices];
    if (answer[question['id']] != null) {
      setState(() {
        _selectedOption = answer[question['id']];
      });
    } else {
      setState(() {
        _selectedOption = [];
      });
    }
  }

  checkForAllOptions(val, singleUpdate, options) {
    var multiSelected;
    if (hasAllOfOption != -1) {
      if (hasAllOfOption != -1 && val[0] == hasAllOfOption) {
        multiSelected = [...allOptions, hasAllOfOption];
        return multiSelected;
      } else {
        if (singleUpdate) {
          multiSelected = [...options];
          return multiSelected;
        }

        var arrayWithoutSelectedOption = [..._selectedOption, ...val];
        arrayWithoutSelectedOption
            .removeWhere((element) => element == hasAllOfOption);

        arrayWithoutSelectedOption.sort();
        allOptions.sort();
        if (listEquals(arrayWithoutSelectedOption, allOptions)) {
          multiSelected = [...allOptions, hasAllOfOption];
          return multiSelected;
        }

        multiSelected = [...arrayWithoutSelectedOption];
        return multiSelected;
      }
    } else {
      if (singleUpdate) {
        multiSelected = [...options];
        return multiSelected;
      }
      multiSelected = [..._selectedOption, ...val];
      return multiSelected;
    }
  }

  getMultiSelectedValue(val) {
    var multiSelected;
    if (hasNoneOfOption != -1) {
      var alllTheAbovePresent = _selectedOption.contains(hasNoneOfOption);

      if (!(val.contains(hasNoneOfOption)) && !(alllTheAbovePresent)) {
        multiSelected = checkForAllOptions(val, false, val);
        return multiSelected;
      } else {
        if (alllTheAbovePresent) {
          var currentSelectedOptions = [..._selectedOption, ...val];
          currentSelectedOptions
              .removeWhere((element) => element == hasNoneOfOption);
          multiSelected = checkForAllOptions(val, true, currentSelectedOptions);
          return multiSelected;
        } else {
          multiSelected = val;
          return multiSelected;
        }
      }
    }
    if (hasAllOfOption != -1) {
      if (hasAllOfOption != -1 && val[0] == hasAllOfOption) {
        multiSelected = [...allOptions, hasAllOfOption];
        return multiSelected;
      } else {
        var currentSelected = [..._selectedOption, ...val];
        currentSelected.sort();
        allOptions.sort();
        if (listEquals(currentSelected, allOptions)) {
          multiSelected = [...currentSelected, hasAllOfOption];
        } else {
          multiSelected = [..._selectedOption, ...val];
        }
        return multiSelected;
      }
    } else {
      multiSelected = [..._selectedOption, ...val];
      return multiSelected;
    }
  }

  updateChoice(val, isNoneAboveChoice) {
    //handle single answer
    if (isMultipleAnswer == false) {
      if (hasOtherOption == -1) {
        var singleSelected = val;
        setState(() {
          _selectedOption = singleSelected;
        });
        func(singleSelected, question['id']);
        widget.setSelectedOptions!(singleSelected);
      } else {
        var singleSelected = val;
        setState(() {
          _selectedOption = singleSelected;
        });
        if (_selectedOption.contains(hasOtherOption)) {
          widget.setSelectedOptions!(singleSelected);
          widget.setShowNextButton!(true);
        } else {
          widget.setShowNextButton!(false);
          func(singleSelected, question['id']);
          widget.setSelectedOptions!(singleSelected);
        }
      }
    }

    //handle multiple answer
    else {
      var multiSelected = getMultiSelectedValue(val);
      if (multiSelected.contains(hasOtherOption)) {
        widget.setShowNextButton!(true);
      }
      setState(() {
        _selectedOption = multiSelected;
      });
      widget.setSelectedOptions!(multiSelected);
      func(multiSelected, question['id'], changePage: false);
    }
  }

  removeChoice(val) {
    if (hasAllOfOption != -1 && val == hasAllOfOption) {
      var currentSelectedOptions = [];
      setState(() {
        _selectedOption = currentSelectedOptions;
      });
      widget.setSelectedOptions!(currentSelectedOptions);
      if (isMultipleAnswer == false) {
        func(currentSelectedOptions, question['id']);
      } else {
        func(currentSelectedOptions, question['id'], changePage: false);
      }
    } else {
      var currentSelectedOptions = [..._selectedOption];
      currentSelectedOptions.removeWhere(
          (element) => element == val || element == hasAllOfOption);
      setState(() {
        _selectedOption = currentSelectedOptions;
      });
      widget.setSelectedOptions!(currentSelectedOptions);
      if (isMultipleAnswer == false) {
        func(currentSelectedOptions, question['id']);
      } else {
        func(currentSelectedOptions, question['id'], changePage: false);
      }
    }
  }

  initilizeChoices(val, id) {
    if (val['other']) {
      hasOtherOption = id;
      hasOtherOptionJson = val;
    }

    if (val['properties'] != null &&
        val['properties']['noneOfTheAbove'] != null &&
        val['properties']['noneOfTheAbove'] == true) {
      hasNoneOfOption = id;
      hasNoneOfOptionJson = val;
      return;
    }

    if (val['properties'] != null &&
        val['properties']['allOfTheAbove'] != null &&
        val['properties']['allOfTheAbove'] == true) {
      hasAllOfOption = id;
      hasAllOfOptionJson = val;
      return;
    }
    allOptions.add(id);
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    choiceContainerWidth = MediaQuery.of(context).size.width - 60;
    final bool useMobileLayout = shortestSide < 600;
    List<Widget> list = List<Widget>.empty(growable: true);
    for (var i = 0; i < multipleChoiceChoices.length; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            var isNoneAboveChoice = hasNoneOfOption == -1 ? false : true;
            choiceToUpdateIs = [];
            choiceToUpdateIs.add(multipleChoiceChoices[i]['id']);

            var choicePresent =
                _selectedOption.contains(multipleChoiceChoices[i]['id']);

            if (choicePresent) {
              removeChoice(multipleChoiceChoices[i]['id']);
            } else {
              updateChoice(choiceToUpdateIs, isNoneAboveChoice);
            }

            if (multipleChoiceChoices[i]['id'] == hasOtherOption) {}
            widget.setOtherTextInput!(inputController.text);
          },
          child: Container(
            constraints: BoxConstraints(
                minHeight: choiceContainerHeight,
                maxWidth: choiceContainerWidth),
            decoration: BoxDecoration(
              color: _selectedOption.contains(multipleChoiceChoices[i]['id'])
                  ? theme['decodedOpnionBackgroundColorSelected']
                  : theme['decodedOpnionBackgroundColorUnSelected'],
              border: Border.all(
                color: theme['decodedOpnionBorderColor'],
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(multipleChoiceChoices[i]['txt'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: customFont,
                                decoration: TextDecoration.none,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w400,
                                color: _selectedOption.contains(
                                        multipleChoiceChoices[i]['id'])
                                    ? luminanceValue > 0.5
                                        ? Colors.black
                                        : Colors.white
                                    : theme['answerColor'],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // style change can be added is
    // direction: Axis.horizontal,
    //  alignment: WrapAlignment.start,

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      direction: Axis.vertical,
      children: [
        ...list,
        if (_selectedOption.contains(hasOtherOption)) ...[
          Container(
            // color: Colors.red,
            constraints: BoxConstraints(
                maxHeight: otherOptionTextFieldHeight,
                maxWidth:
                    otherOptionTextFieldWidth ?? (useMobileLayout ? 320 : 500)),
            child: TextField(
              key: Key(question['id'].toString()),
              onChanged: (text) {
                setState(() {
                  widget.setOtherTextInput!(text);
                });
              },
              style: TextStyle(
                  fontFamily: customFont,
                  color: theme['answerColor'],
                  fontSize: otherOptionTextFontSize),
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
        if (widget.inputError) ...[
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 11,
                color: Colors.red,
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                widget.inputErrorMsg,
                style: TextStyle(
                    fontFamily: customFont, color: Colors.red, fontSize: 10),
              ),
            ],
          )
        ]
      ],
    );
  }
}
