import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/common/skipAndNext.dart';
import 'package:sizer/sizer.dart';

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
  }) : super(key: key);

  @override
  State<MultiChoice> createState() => _MultiChoiceState(
        func: this.func,
        answer: this.answer,
        question: question,
        theme: this.theme,
        customParams: this.customParams,
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
        if (this.answer[this.question['id']] != null) {
          if (this
              .answer[this.question['id']]
              .contains(question['choices'][i]['id'])) {
            hasNextButton = true;
          }
        }
        print("66ty ${question['choices'][i]['id']}");
      }
    }

    if (this.answer['${this.question['id']}_other'] != null) {
      hasOtherInputText = this.answer['${this.question['id']}_other'];
      hasNextButton = this.question['multipleAnswers'];
    } else {
      hasNextButton = this.question['multipleAnswers'];
    }

    if (this.answer[this.question['id']] != null) {
      _selectedOptions = this.answer[this.question['id']];
    }

    // print("1189-1 called in multi choice ${question['choices']}");
  }

  setSelectedOptions(options) {
    print("options obtained multi-34 ${options}");
    setState(() {
      _selectedOptions = options;
    });
  }

  setShowNextButton(val) {
    print("8897 update show next");
    if (val == true) {
      hasOtherInput = true;
    }
    setState(() {
      hasNextButton = val;
    });
  }

  setOtherTextInput(val) {
    hasOtherInputText = val;
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

  @override
  Widget build(BuildContext context) {
    print("Selected test sel-90 ${_selectedOptions.length}");
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
              currentQuestionNumber: this.currentQuestionNumber,
              customParams: this.customParams,
              theme: this.theme,
              euiTheme: this.widget.euiTheme,
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
              euiTheme: this.widget.euiTheme,
            ),
            const SizedBox(height: 30),
            SkipAndNextButtons(
              key: UniqueKey(),
              disabled: _selectedOptions.length > 0 ? false : true,
              showNext: hasNextButton || this.widget.isLastQuestion,
              showSkip:
                  (this.question['required'] || this.widget.isLastQuestion)
                      ? false
                      : true,
              showSubmit: this.widget.isLastQuestion,
              onClickNext: () {
                print("8897 test text ${hasOtherInputText}");
                print(
                    "submit answer 2xx ${this.question['properties']}  ${this.question['properties']['data']['type'] == 'EXACT'}");
                if (this.question['properties']['data']['type'] == 'EXACT') {
                  if (_selectedOptions.length ==
                      int.parse(this.question['properties']['data']
                          ['exactChoices'])) {
                    print("called func excate");
                    this.func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(true,
                        "Please select ${this.question['properties']['data']['exactChoices']} choices");
                  }
                  print(
                      "excat ${_selectedOptions.length == this.question['properties']['data']['exactChoices']} ${_selectedOptions.length} ${this.question['properties']['data']['type']} ${this.question['properties']['data']['exactChoices'].toString()}");
                } else if (this.question['properties']['data']['type'] ==
                    'RANGE') {
                  if (_selectedOptions.length >=
                          int.parse(this.question['properties']['data']
                              ['minLimit']) &&
                      _selectedOptions.length <=
                          int.parse(this.question['properties']['data']
                              ['maxLimit'])) {
                    print("called func excate");
                    this.func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(
                        true, "Please select choices between a range");
                  }

                  print(
                      "excat ${this.question['properties']['data']} ${this.question['properties']['data']['minLimit'].toString()} ${this.question['properties']['data']['maxLimit'].toString()}");
                } else {
                  if (_selectedOptions.length > 0) {
                    this.func(_selectedOptions, question['id'],
                        otherInput: _selectedOptions.contains(otherInputId),
                        otherInputId: otherInputId,
                        otherInputText: hasOtherInputText);
                    setChoiceError(false, "");
                  } else {
                    setChoiceError(true, "Please select atleast 1 choice");
                  }
                }
                if (inputError == false && this.widget.isLastQuestion) {
                  this.widget.submitData();
                }
              },
              onClickSkip: () {
                this.func(null, question['id']);
                print("skip is clicked");
              },
              theme: theme,
              euiTheme: this.widget.euiTheme,
            ),
            // ElevatedButton(onPressed: () {}, child: const Text("Submit"))
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
  }) : super(key: key);

  @override
  State<MultipleChoiceRow> createState() => _MultipleChoiceRowState(
        func: this.func,
        answer: this.answer,
        question: question,
        theme: theme,
      );
}

class _MultipleChoiceRowState extends State<MultipleChoiceRow> {
  TextEditingController inputController = new TextEditingController();
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  var _selectedOption = [];
  var choiceToUpdateIs = [];
  bool _isRadioSelected = false;
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

  _MultipleChoiceRowState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
  });

  var customFont = null;
  var newList = [];
  @override
  initState() {
    super.initState();

    if (this.widget.euiTheme != null) {
      print("q-eui-theme ${this.widget.euiTheme} ");
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }
    }

    inputController.text = '';
    print("selected 8897 90 ${this.answer}");

    if (this.answer['${this.question['id']}_other'] != null) {
      inputController.text = this.answer['${this.question['id']}_other'];
    } else {
      inputController.text = '';
    }

    luminanceValue =
        this.theme['decodedOpnionBackgroundColorUnSelected'].computeLuminance();

    print(
        "multi-34 called in multi choice inside row ${this.question['properties']} ${this.question['multipleAnswers']}");
    isMultipleAnswer = this.question['multipleAnswers'];

    for (var i = 0; i < question['choices'].length; i++) {
      initilizeChoices(question['choices'][i], question['choices'][i]['id']);
    }

    
 

    

    if (this.answer[this.question['id']] != null) {
      setState(() {
        _selectedOption = this.answer[this.question['id']];
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
      print(
          "0098 uui ${hasAllOfOption} ${val[0]} ${hasAllOfOption != -1} ${val[0] == hasAllOfOption}");
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
          ..removeWhere((element) => element == hasAllOfOption);

        print(
            "0098op ${listEquals(arrayWithoutSelectedOption, allOptions)} ${arrayWithoutSelectedOption} ${allOptions} ");
        arrayWithoutSelectedOption.sort();
        allOptions.sort();
        if (listEquals(arrayWithoutSelectedOption, allOptions)) {
          print("0098op");
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
      print("multi-34567 ${val.length}");
      var alllTheAbovePresent = _selectedOption.contains(hasNoneOfOption);

      if (!(val.contains(hasNoneOfOption)) && !(alllTheAbovePresent)) {
        print("hasn 0098 called here multi all ${val}");
        multiSelected = checkForAllOptions(val, false, val);
        return multiSelected;
      } else {
        print("out el 0098 called here multi all ${val}");
        if (alllTheAbovePresent) {
          var currentSelectedOptions = [..._selectedOption, ...val];
          currentSelectedOptions
              .removeWhere((element) => element == hasNoneOfOption);
          multiSelected = checkForAllOptions(val, true, currentSelectedOptions);
          print("0098 all multi options ${multiSelected} ${hasNoneOfOption} ");
          return multiSelected;
        } else {
          print(" 0098 called here multi all ${val}");
          multiSelected = val;
          return multiSelected;
        }
      }
    }
    if (hasAllOfOption != -1) {
      print(
          "0098 ${hasAllOfOption} ${val[0]} ${hasAllOfOption != -1} ${val[0] == hasAllOfOption}");
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
    print(
        "all 0098 options ${_selectedOption} ${hasNoneOfOption} ${hasAllOfOption} ${allOptions} ");

    //handle single answer
    if (isMultipleAnswer == false) {
      if (hasOtherOption == -1) {
        var singleSelected = val;
        setState(() {
          _selectedOption = singleSelected;
        });
        this.func(singleSelected, question['id']);
        this.widget.setSelectedOptions!(singleSelected);
      } else {
        var singleSelected = val;
        setState(() {
          _selectedOption = singleSelected;
        });
        if (_selectedOption.contains(hasOtherOption)) {
          print("8897 cll in");
          this.widget.setSelectedOptions!(singleSelected);
          this.widget.setShowNextButton!(true);
        } else {
          this.widget.setShowNextButton!(false);
          this.func(singleSelected, question['id']);
          this.widget.setSelectedOptions!(singleSelected);
        }
      }
    }

    //handle multiple answer
    else {
      var multiSelected = getMultiSelectedValue(val);

      print("0098 multi select ${multiSelected}");

      if (multiSelected.contains(hasOtherOption)) {
        this.widget.setShowNextButton!(true);
      }

      print("multi-3456 final ${multiSelected}");

      setState(() {
        _selectedOption = multiSelected;
      });
      this.widget.setSelectedOptions!(multiSelected);
    }

    print("multi-34 val to update is ${val}");
  }

  removeChoice(val) {
    print("remove 0098op ${val} ${hasAllOfOption}");
    if (hasAllOfOption != -1 && val == hasAllOfOption) {
      var currentSelectedOptions = [];
      setState(() {
        _selectedOption = currentSelectedOptions;
      });
      this.widget.setSelectedOptions!(currentSelectedOptions);
      if (isMultipleAnswer == false) {
        this.func(currentSelectedOptions, question['id']);
      }
    } else {
      var currentSelectedOptions = [..._selectedOption];
      currentSelectedOptions.removeWhere(
          (element) => element == val || element == hasAllOfOption);
      setState(() {
        _selectedOption = currentSelectedOptions;
      });
      this.widget.setSelectedOptions!(currentSelectedOptions);
      if (isMultipleAnswer == false) {
        this.func(currentSelectedOptions, question['id']);
      }
    }
  }

  initilizeChoices(val, id) {
    print("init choices 8897 ${val['other']}");

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
    final bool useMobileLayout = shortestSide < 600;
    print("dd 11 ${_selectedOption} ");
    List<Widget> list = List<Widget>.empty(growable: true);
    var charc = 65;
    for (var i = 0; i < question['choices'].length; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            var isNoneAboveChoice = hasNoneOfOption == -1 ? false : true;

            print(
                "choice tapped multi-3456 isNoneAboveChoice ${isNoneAboveChoice} ${hasNoneOfOption}");

            choiceToUpdateIs = [];
            choiceToUpdateIs.add(question['choices'][i]['id']);

            var choicePresent =
                _selectedOption.contains(question['choices'][i]['id']);

            if (choicePresent) {
              removeChoice(question['choices'][i]['id']);
              print("multi-34 remove and update");
            } else {
              updateChoice(choiceToUpdateIs, isNoneAboveChoice);
            }
          },
          child: Container(
            constraints: BoxConstraints(maxHeight: 50, maxWidth: 250),
            decoration: BoxDecoration(
              color: _selectedOption.contains(question['choices'][i]['id'])
                  ? this.theme['decodedOpnionBackgroundColorSelected']
                  : this.theme['decodedOpnionBackgroundColorUnSelected'],
              border: Border.all(
                color: this.theme['decodedOpnionBorderColor'],
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(question['choices'][i]['txt'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: customFont,
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _selectedOption
                                  .contains(question['choices'][i]['id'])
                              ? luminanceValue > 0.5
                                  ? Colors.black
                                  : Colors.white
                              : this.theme['answerColor'],
                        )),
                    Container(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: Text(
                          String.fromCharCode(charc + i),
                          style: TextStyle(
                            fontFamily: customFont,
                            decoration: TextDecoration.none,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: luminanceValue > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: this.theme['answerColor'],
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

    return Container(
      child: Wrap(
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
                  maxHeight: 50, maxWidth: useMobileLayout ? 320 : 500),
              child: TextField(
                key: Key(question['id'].toString()),
                onChanged: (text) {
                  setState(() {
                    this.widget.setOtherTextInput!(text);
                  });
                },
                style: TextStyle(
                    fontFamily: customFont, color: this.theme['answerColor']),
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
          ],
          if (this.widget.inputError) ...[
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 11,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  this.widget.inputErrorMsg,
                  style: TextStyle(
                      fontFamily: customFont, color: Colors.red, fontSize: 10),
                ),
              ],
            )
          ]
        ],
      ),
    );

    // Wrap(
    //   crossAxisAlignment: WrapCrossAlignment.center,
    //   alignment: WrapAlignment.center,
    //   spacing: 10,
    //   runSpacing: 10,
    //   direction: Axis.vertical,
    //   children: [...list],
    // );
  }
}
