getFeedBackQuestion(question) {
  var listSubQuestions = (question['subQuestions'] as List)
      .map((e) => e as Map<dynamic, dynamic>)
      .toList();
  var subQuestion = <dynamic, dynamic>{};
  if (listSubQuestions.length > 0) {
    subQuestion = Map<dynamic, dynamic>.from(listSubQuestions[0]);
  }
  return subQuestion;
}

checkIfTheQuestionHasAFeedBack(question) {
  if (question['properties'] != null &&
      question['properties']['data'] != null &&
      question['properties']['data']['includeFeedback'] != null) {
    return question['properties']['data']['includeFeedback'];
  }
  return false;
}

checkIfCXSurveyHasBranchingProperty(question) {
  var hasBranching = question['properties'] != null &&
          question['properties']['data'] != null &&
          question['properties']['data']['branching'] != null
      ? question['properties']['data']['branching']
      : false;
  return hasBranching;
}

checkIfCXSurveyHasSegmentedOption(question) {
  var hasSegmentedOption = question['properties'] != null &&
          question['properties']['data'] != null &&
          question['properties']['data']['segmentedOptions'] != null
      ? question['properties']['data']['segmentedOptions']
      : false;
  return hasSegmentedOption;
}

getCXFeedBackQuestionHeading(
    question, parentQuestion, replacementVal, providerAnswer, survey) {
  if (question['rtxt'] == null ||
      question['rtxt']['blocks'] == null ||
      question['rtxt']['blocks'][0] == null ||
      question['rtxt']['blocks'][0]['text'] == null) {
    return '';
  }

  var currentQuestion = question['rtxt'];

  var hasBranching = checkIfCXSurveyHasBranchingProperty(question);
  if (hasBranching) {
    var parentQuestionAnswer = providerAnswer[parentQuestion['id']];
    var surveyType = survey['survey_type'];

    if (surveyType == 'CSAT') {
      if (parentQuestionAnswer >= 4) {
        currentQuestion = question['properties']['data']['rtxt']['satisfied'];
      }
      else if (parentQuestionAnswer >= 3) {
        currentQuestion = question['properties']['data']['rtxt']['neutral'];
      }
      if (parentQuestionAnswer <= 2) {
        currentQuestion =
            question['properties']['data']['rtxt']['dissatisfied'];
      }
    } else if (surveyType == 'CES'){
      if (parentQuestionAnswer >= 5) {
        currentQuestion = question['properties']['data']['rtxt']['lowEffort'];
      }
      else if (parentQuestionAnswer >= 4) {
        currentQuestion = question['properties']['data']['rtxt']['neutral'];
      }
      else if (parentQuestionAnswer <= 2) {
        currentQuestion =
            question['properties']['data']['rtxt']['highEffort'];
      }  
    }    
    else {
      if (parentQuestionAnswer >= 9) {
        currentQuestion = question['properties']['data']['rtxt']['promoter'];
      }
      else if (parentQuestionAnswer >= 7) {
        currentQuestion = question['properties']['data']['rtxt']['passive'];
      }
      if (parentQuestionAnswer <= 6) {
        currentQuestion = question['properties']['data']['rtxt']['detractor'];
      }
    }
  }
  
  var entityRanges = currentQuestion['blocks'][0]['entityRanges'];
  var entityMapping = currentQuestion['entityMap'];
  final Map<dynamic, dynamic> stringToReplace = {};

  if (entityRanges.length <= 0) {
    return currentQuestion['blocks'][0]['text'];
  }

  var replacedString = currentQuestion['blocks'][0]['text'];
  var extraOffset = 0;

  for (var i = 0; i < entityRanges.length; i++) {
    var currentEntity = entityRanges[i];
    var textToReplace =
        '#CHANGE_${entityMapping[currentEntity['key'].toString()]['data']['component_txt']}';
    replacedString = replacedString.replaceFirst(
        RegExp(entityMapping[currentEntity['key'].toString()]['data']
            ['component_txt']),
        textToReplace,
        currentEntity['offset'] + extraOffset);
    extraOffset += 8;
    stringToReplace[i] = {};
    stringToReplace[i]['pramKey'] =
        entityMapping[currentEntity['key'].toString()]['data']['component_txt'];
    stringToReplace[i]['regexKey'] = textToReplace;

    // entityMapping[currentEntity['key'].toString()]['data']['component_txt']['replace_txt'] = textToReplace;
  }

  for (var i = 0; i < stringToReplace.length; i++) {
    var stringToReplaceHere =
        replacementVal[stringToReplace[i]['pramKey']] ?? '';
    replacedString = replacedString.replaceAll(
        stringToReplace[i]['regexKey'], stringToReplaceHere);
  }
  return replacedString;
}
