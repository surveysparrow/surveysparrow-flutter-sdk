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
    currentQuestionToRender,
    storeAnswers,
    workBench,
    themeData,
    customParams,
    currentQuestionNumber,
    submitData,
    lastQuestion,
    scrollController,
    euiTheme,
    toggleNextButtonBlock) {
  List<Widget> newquestionList = List<Widget>.empty(growable: true);

  var i = 0;

  for (var question in questionsToConvert) {
    if (question['type'] == 'Rating') {
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ColumnRating(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                isLastQuestion: question['id'] == lastQuestion['id'],
                lastQuestionId: lastQuestion['id'],
                submitData: submitData,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'TextInput' || question['type'] == 'EmailInput') {
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: TextRating(
                  func: storeAnswers,
                  answer: workBench,
                  question: question,
                  theme: themeData,
                  customParams: customParams,
                  currentQuestionNumber: i + 1,
                  isLastQuestion: question['id'] == lastQuestion['id'],
                  submitData: submitData,
                  euiTheme: euiTheme,
                  toggleNextButtonBlock: toggleNextButtonBlock),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'MultiChoice') {
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: MultiChoice(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestion['id'],
                euiTheme: euiTheme,
                toggleNextButtonBlock: toggleNextButtonBlock,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'OpinionScale') {
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: ColumnOpnionScale(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestion['id'],
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'NPSScore') {
      var isLastQuestionSubQuestion = lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = lastQuestion['id'];
      if (isLastQuestionSubQuestion) {
        lastQuestionId = lastQuestion['parent_question_id'];
      }
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: NpsScore(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
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
      var isLastQuestionSubQuestion = lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = lastQuestion['id'];
      if (isLastQuestionSubQuestion) {
        lastQuestionId = lastQuestion['parent_question_id'];
      }
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: CesScore(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
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
    if (question['type'] == 'CSATScore') {
      var isLastQuestionSubQuestion = lastQuestion['subQuestion'] ?? false;
      var lastQuestionId = lastQuestion['id'];
      if (isLastQuestionSubQuestion) {
        lastQuestionId = lastQuestion['parent_question_id'];
      }
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: Csat(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
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
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ColumnPhone(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                isLastQuestion: question['id'] == lastQuestion['id'],
                submitData: submitData,
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    if (question['type'] == 'YesNo') {
      newquestionList.add(
        AnimatedOpacity(
          opacity: currentQuestionToRender['id'] == null
              ? 1.0
              : currentQuestionToRender['id'] == question['id']
                  ? 1.0
                  : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: YesOrNo(
                func: storeAnswers,
                answer: workBench,
                question: question,
                theme: themeData,
                customParams: customParams,
                currentQuestionNumber: i + 1,
                submitData: submitData,
                isLastQuestion: question['id'] == lastQuestion['id'],
                euiTheme: euiTheme,
              ),
            ),
          ),
        ),
      );
    }
    i += 1;
  }
  return newquestionList;
}

setTheme(themeData, surveyThemeClass) {
  themeData['questionColor'] = surveyThemeClass.questionColor;
  themeData['answerColor'] = surveyThemeClass.answerColor;
  themeData['backgroundColor'] = surveyThemeClass.backgroundColor;
  themeData['questionDescriptionColor'] =
      surveyThemeClass.questionDescriptionColor;
  themeData['questionNumberColor'] = surveyThemeClass.questionNumberColor;
  themeData['decodedOpnionBackgroundColorSelected'] =
      surveyThemeClass.decodedOpnionBackgroundColorSelected;
  themeData['decodedOpnionBackgroundColorUnSelected'] =
      surveyThemeClass.decodedOpnionBackgroundColorUnSelected;
  themeData['decodedOpnionBorderColor'] =
      surveyThemeClass.decodedOpnionBorderColor;
  themeData['decodedOpnionLabelColor'] =
      surveyThemeClass.decodedOpnionLabelColor;
  themeData['ctaButtonColor'] = surveyThemeClass.ctaButtonColor;
  themeData['ratingRgba'] = surveyThemeClass.ratingRgba;
  themeData['ratingRgbaBorder'] = surveyThemeClass.ratingRgbaBorder;
  themeData['ctaButtonDisabledColor'] = surveyThemeClass.ctaButtonDisabledColor;
  themeData['showRequired'] = surveyThemeClass.showRequired;
  themeData['buttonStyle'] = surveyThemeClass.buttonStyle;
  themeData['showBranding'] = surveyThemeClass.showBranding;
  themeData['questionString'] = surveyThemeClass.questionString;
  themeData['hasGradient'] = surveyThemeClass.hasGradient;
  themeData['gradientColors'] = surveyThemeClass.gradientColors;
  themeData['showQuestionNumber'] = surveyThemeClass.showQuestionNumber;
  themeData['showProgressBar'] = surveyThemeClass.showProgressBar;
  themeData['hasHeader'] = surveyThemeClass.hasHeader;
  themeData['headerText'] = surveyThemeClass.headerText;
  themeData['headerLogoUrl'] = surveyThemeClass.headerLogoUrl;
  themeData['hasFooter'] = surveyThemeClass.hasFooter;
  themeData['footerText'] = surveyThemeClass.footerText;
}

getPrefilledAnswers(firstQuestionAnswer, createAnswerPayload, collectedAnswers,
    surveyToMap, onError) {
  try {
    var workBenchDatas = {};

    for (var i = 0; i < firstQuestionAnswer!.answers.length; i++) {
      if (firstQuestionAnswer!.answers[i].rating != null) {
        var key = firstQuestionAnswer!.answers[i].rating?.key;
        var data = firstQuestionAnswer!.answers[i].rating?.data;
        var skipped = firstQuestionAnswer!.answers[i].rating!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].rating?.timeTaken;
        workBenchDatas[key] = data?.toDouble();

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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
        workBenchDatas[key] = data;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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
        workBenchDatas[key] = data;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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

        workBenchDatas[key] = data;
        workBenchDatas['${key}_phone'] = phoneData;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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
        workBenchDatas[key] = data;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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
        workBenchDatas[key] = data;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
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
        workBenchDatas[key] = data;

        createAnswerPayload(
          collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }
    }

    return workBenchDatas;
  } catch (e) {
    if (onError != null) {
      onError!('prefilled Answers is not configured properly');
    }
    throw Exception('prefilled Answers is not configured properly');
  }
}
