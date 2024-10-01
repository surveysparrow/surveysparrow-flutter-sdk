import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/questions/cesScore.dart';
import 'package:surveysparrow_flutter_sdk/components/questions/csatFeedback.dart';
import 'package:surveysparrow_flutter_sdk/components/questions/yesorno.dart';

import '../components/questions/multichoice.dart';
import '../components/questions/opnion.dart';
import '../components/questions/phone.dart';
import '../components/questions/rating.dart';
import '../components/questions/text.dart';
import '../components/questions/npsScore.dart';

parsedHeading(question, replacementVal) {
  String replacedString = "" ;
  if (question['rtxt'] != null &&
      question['rtxt']['blocks'] != null) {
        question['rtxt']['blocks'].forEach((e) {
          if(e['text'] != null && e['text'].toString().isNotEmpty ){
            replacedString += """${e['text']}
            """ ;
          }
        });
  }else {
    replacedString = "";
  }

  var blocks = question['rtxt']['blocks'];
  var entityRanges = [];
  blocks.forEach((e) { 
    entityRanges.addAll(e['entityRanges']);
    }
  );
  
  var entityMapping = question['rtxt']['entityMap'];
  final Map<dynamic, dynamic> stringToReplace = {};

  if (entityRanges.isEmpty) {
    return replacedString;
  }


  for (var i = 0; i < entityRanges.length; i++) {
    var currentEntity = entityRanges[i];
    var textToReplace = entityMapping[currentEntity['key'].toString()]['data']['component_txt'];
    replacedString = replacedString.replaceAll(
        RegExp(entityMapping[currentEntity['key'].toString()]['data']
            ['component_txt']),
        textToReplace);
    stringToReplace[i] = {};
    stringToReplace[i]['pramKey'] =
        entityMapping[currentEntity['key'].toString()]['data']['component_txt'];
    stringToReplace[i]['regexKey'] = textToReplace;
  }

  for (var i = 0; i < stringToReplace.length; i++) {
    var stringToReplaceHere =
        replacementVal[stringToReplace[i]['pramKey']] ?? '';
    replacedString = replacedString.replaceAll(
        stringToReplace[i]['regexKey'], stringToReplaceHere);
  }
  return replacedString;
}

convertQuestionListToWidget(
    questionsToConvert,
    _currentQuestionToRender,
    storeAnswers,
    _workBench,
    _themeData,
    customParams,
    _currentQuestionNumber,
    submitData,
    _lastQuestion,
    _scrollController,
    euiTheme,
    toggleNextButtonBlock) {
  List<Widget> _newquestionList = List<Widget>.empty(growable: true);

  var i = 0;

  for (var question in questionsToConvert) {
    if (question['type'] == 'Rating') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ColumnRating(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                isLastQuestion: question['id'] == _lastQuestion['id'],
                lastQuestionId: _lastQuestion['id'],
                submitData: submitData,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'TextInput' || question['type'] == 'EmailInput') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: TextRating(
                  func: storeAnswers,
                  answer: _workBench,
                  question: question,
                  theme: _themeData,
                  customParams: customParams,
                  currentQuestionNumber: i + 1,
                  isLastQuestion: question['id'] == _lastQuestion['id'],
                  submitData: submitData,
                  euiTheme: euiTheme,
                  toggleNextButtonBlock: toggleNextButtonBlock),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'MultiChoice') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: MultiChoice(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == _lastQuestion['id'],
                euiTheme: euiTheme,
                toggleNextButtonBlock: toggleNextButtonBlock,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'OpinionScale') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: ColumnOpnionScale(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == _lastQuestion['id'],
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'NPSScore') {
      var isLastQuestionSubQuestion = _lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = _lastQuestion['id'];
      if(isLastQuestionSubQuestion){
        lastQuestionId = _lastQuestion['parent_question_id'];
      }
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: NpsScore(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestionId,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'CESScore') {
      var isLastQuestionSubQuestion = _lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = _lastQuestion['id'];
      if(isLastQuestionSubQuestion){
        lastQuestionId = _lastQuestion['parent_question_id'];
      }
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: CesScore(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestionId,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if(question['type'] == 'CSATScore'){
var isLastQuestionSubQuestion = _lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = _lastQuestion['id'];
      if(isLastQuestionSubQuestion){
        lastQuestionId = _lastQuestion['parent_question_id'];
      }
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              controller: _scrollController,
              child: Csat(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestionId,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'PhoneNumber') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ColumnPhone(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                isLastQuestion: question['id'] == _lastQuestion['id'],
                submitData: submitData,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'YesNo') {
      _newquestionList.add(
        AnimatedOpacity(
          opacity: _currentQuestionToRender['id'] == null
              ? 1.0
              : _currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: YesOrNo(
                func: storeAnswers,
                answer: _workBench,
                question: question,
                theme: _themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == _lastQuestion['id'],
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    i += 1;
  }
  return _newquestionList;
}

setTheme(_themeData, _surveyThemeClass) {
  _themeData['questionColor'] = _surveyThemeClass.questionColor;
  _themeData['answerColor'] = _surveyThemeClass.answerColor;
  _themeData['backgroundColor'] = _surveyThemeClass.backgroundColor;
  _themeData['questionDescriptionColor'] =
      _surveyThemeClass.questionDescriptionColor;
  _themeData['questionNumberColor'] = _surveyThemeClass.questionNumberColor;
  _themeData['decodedOpnionBackgroundColorSelected'] =
      _surveyThemeClass.decodedOpnionBackgroundColorSelected;
  _themeData['decodedOpnionBackgroundColorUnSelected'] =
      _surveyThemeClass.decodedOpnionBackgroundColorUnSelected;
  _themeData['decodedOpnionBorderColor'] =
      _surveyThemeClass.decodedOpnionBorderColor;
  _themeData['decodedOpnionLabelColor'] =
      _surveyThemeClass.decodedOpnionLabelColor;
  _themeData['ctaButtonColor'] = _surveyThemeClass.ctaButtonColor;
  _themeData['ratingRgba'] = _surveyThemeClass.ratingRgba;
  _themeData['ratingRgbaBorder'] = _surveyThemeClass.ratingRgbaBorder;
  _themeData['ctaButtonDisabledColor'] =
      _surveyThemeClass.ctaButtonDisabledColor;
  _themeData['showRequired'] = _surveyThemeClass.showRequired;
  _themeData['buttonStyle'] = _surveyThemeClass.buttonStyle;
  _themeData['showBranding'] = _surveyThemeClass.showBranding;
  _themeData['questionString'] = _surveyThemeClass.questionString;
  _themeData['hasGradient'] = _surveyThemeClass.hasGradient;
  _themeData['gradientColors'] = _surveyThemeClass.gradientColors;
  _themeData['showQuestionNumber'] = _surveyThemeClass.showQuestionNumber;
  _themeData['showProgressBar'] = _surveyThemeClass.showProgressBar;
  _themeData['hasHeader'] = _surveyThemeClass.hasHeader;
  _themeData['headerText'] = _surveyThemeClass.headerText;
  _themeData['headerLogoUrl'] = _surveyThemeClass.headerLogoUrl;
  _themeData['hasFooter'] = _surveyThemeClass.hasFooter;
  _themeData['footerText'] = _surveyThemeClass.footerText;
}

getPrefilledAnswers(firstQuestionAnswer, createAnswerPayload, _collectedAnswers,
    _surveyToMap, onError) {
  try {
    var _workBenchDatas = {};

    for (var i = 0; i < firstQuestionAnswer!.answers.length; i++) {
      if (firstQuestionAnswer!.answers[i].rating != null) {
        var key = firstQuestionAnswer!.answers[i].rating?.key;
        var data = firstQuestionAnswer!.answers[i].rating?.data;
        var skipped = firstQuestionAnswer!.answers[i].rating!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].rating?.timeTaken;
        _workBenchDatas[key] = data?.toDouble();

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].opnionScale != null) {
        var key = firstQuestionAnswer!.answers[i].opnionScale?.key;
        var data = firstQuestionAnswer!.answers[i].opnionScale?.data;
        var skipped = firstQuestionAnswer!.answers[i].opnionScale!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].opnionScale?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].yesOrNo != null) {
        var key = firstQuestionAnswer!.answers[i].yesOrNo?.key;
        var data = firstQuestionAnswer!.answers[i].yesOrNo?.data;
        var skipped = firstQuestionAnswer!.answers[i].yesOrNo!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].yesOrNo?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].phoneNumber != null) {
        var key = firstQuestionAnswer!.answers[i].phoneNumber?.key;
        var data =
            firstQuestionAnswer!.answers[i].phoneNumber?.data.split(" ")[1];
        var phoneData = firstQuestionAnswer!.answers[i].phoneNumber?.data;
        var skipped = firstQuestionAnswer!.answers[i].phoneNumber!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].phoneNumber?.timeTaken;

        _workBenchDatas[key] = data;
        _workBenchDatas['${key}_phone'] = phoneData;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          true,
          phoneData,
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].text != null) {
        var key = firstQuestionAnswer!.answers[i].text?.key;
        var data = firstQuestionAnswer!.answers[i].text?.data;
        var skipped = firstQuestionAnswer!.answers[i].text!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].text?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].email != null) {
        var key = firstQuestionAnswer!.answers[i].email?.key;
        var data = firstQuestionAnswer!.answers[i].email?.data;
        var skipped = firstQuestionAnswer!.answers[i].email!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].email?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].multipleChoice != null) {
        var key = firstQuestionAnswer!.answers[i].multipleChoice?.key;
        var data = firstQuestionAnswer!.answers[i].multipleChoice?.data;
        var skipped = firstQuestionAnswer!.answers[i].multipleChoice!.skipped;
        var timeTaken =
            firstQuestionAnswer!.answers[i].multipleChoice?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }
    }

    return _workBenchDatas;
  } catch (e) {
    if (onError != null) {
      onError!('prefilled Answers is not configured properly');
    }
    throw Exception('prefilled Answers is not configured properly');
  }
}
