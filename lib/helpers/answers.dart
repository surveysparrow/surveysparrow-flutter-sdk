import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:surveysparrow_flutter_sdk/models/answer.dart';

getAnswerValueToStore(
    value, otherInput, otherInputText, otherInputId, isPhoneInput, phoneValue) {
  if (otherInput == false && isPhoneInput == false) {
    return value;
  }

  if (isPhoneInput == true) {
    return phoneValue;
  }

  if (otherInput == true) {
    var newValue = [...value];
    var otherInputIndex = newValue.indexOf(otherInputId);
    newValue[otherInputIndex] = {
      'id': otherInputId,
      'other_txt': otherInputText
    };
    return newValue;
  }
}

submitAnswer(collectedAnswers, finalTime, customParams, token, domain, email,
    isSubmissionQueued) async {
  // check url before prod
  var url = isSubmissionQueued
      ? Uri.parse(
          'https://${domain}/api/internal/v1/submission/answers/${token}')
      : Uri.parse('https://${domain}/api/internal/submission/answers/${token}');
  Map<dynamic, dynamic> payload = {};
  final ua = "${Platform.operatingSystem} ${Platform.operatingSystemVersion} Mobile - Flutter SDK";
  var submissionObjPayload = {
    'answers': collectedAnswers,
    'stripe': {
      'currency': {},
      'amount': '',
      'cardCompleted': false,
      'discountCoupon': {},
    },
    'customParams': customParams,
    'additionalAttributes': {},
    'timeTaken': finalTime,
    'timeZone': 'Asia/Calcutta',
    'browserLanguage': 'en-GB',
    'language': 'en',
  };

  if (email != "") {
    submissionObjPayload['email'] = email;
  }

  payload['answers'] = collectedAnswers;
  payload['finalTime'] = finalTime;
  payload['customParam'] = customParams;

  var body = json.encode(submissionObjPayload);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", "User-Agent": ua},
      body: body);
  return response;
}

createAnswerPayload(
  collectedAnswers,
  key,
  value,
  surveyToMap,
  otherInput,
  otherInputText,
  otherInputId,
  isPhoneInput,
  phoneValue,
  time,
) {
  
  dynamic currentAnswer;

  var isAnswerCollected =
      collectedAnswers.where((e) => e['question_id'] == key);

  if (isAnswerCollected.length > 0) {
    currentAnswer = isAnswerCollected.first;
    if (value == null) {
      currentAnswer[surveyToMap[key]['type']]
          .removeWhere((key, value) => key == "data");
      if (currentAnswer[surveyToMap[key]['type']]['notApplicable'] != null) {
        currentAnswer[surveyToMap[key]['type']]
            .removeWhere((key, value) => key == "notApplicable");
      }
      // currentAnswer[surveyToMap[key]['type']]['data'] = null;
      currentAnswer[surveyToMap[key]['type']]['skipped'] = true;
    } else {
      if (value == -2) {
        currentAnswer[surveyToMap[key]['type']]
            .removeWhere((key, value) => key == "data");
        currentAnswer[surveyToMap[key]['type']]['skipped'] = true;
        currentAnswer[surveyToMap[key]['type']]['notApplicable'] = true;
      } else {
        currentAnswer[surveyToMap[key]['type']]['data'] =
            getAnswerValueToStore(
          value,
          otherInput,
          otherInputText,
          otherInputId,
          isPhoneInput,
          phoneValue,
        );
        if (currentAnswer[surveyToMap[key]['type']]['notApplicable'] != null) {
          currentAnswer[surveyToMap[key]['type']]
              .removeWhere((key, value) => key == "notApplicable");
        }
        currentAnswer[surveyToMap[key]['type']]['skipped'] = false;
      }
    }
  } else {
    currentAnswer = {};
    if (value == null) {
      currentAnswer['question_id'] = key;
      currentAnswer[surveyToMap[key]['type']] = {};
      currentAnswer[surveyToMap[key]['type']]['skipped'] = true;
      currentAnswer[surveyToMap[key]['type']]['timeTaken'] = time;
    } else {
      if (value == -2) {
        currentAnswer['question_id'] = key;
        currentAnswer[surveyToMap[key]['type']] = {};
        currentAnswer[surveyToMap[key]['type']]['skipped'] = true;
        currentAnswer[surveyToMap[key]['type']]['notApplicable'] = true;
        currentAnswer[surveyToMap[key]['type']]['timeTaken'] = time;
      } else {
        currentAnswer['question_id'] = key;
        currentAnswer[surveyToMap[key]['type']] = {};
        currentAnswer[surveyToMap[key]['type']]['data'] =
            getAnswerValueToStore(
          value,
          otherInput,
          otherInputText,
          otherInputId,
          isPhoneInput,
          phoneValue,
        );
        currentAnswer[surveyToMap[key]['type']]['skipped'] = false;
        currentAnswer[surveyToMap[key]['type']]['timeTaken'] = time;
      }
    }
    collectedAnswers.add(currentAnswer);
  }
}

createAnswerPayloadOtherSurvey(obj, surArr) {
  if (!(obj is CustomRating ||
      obj is CustomEmailInput ||
      obj is CustomMultiChoice ||
      obj is CustomTextInput ||
      obj is CustomYesNo ||
      obj is CustomOpinionScale ||
      obj is CustomPhoneNumber)) {
    throw Exception(
        'obj has to be a instance of CustomRating or CustomEmailInput or CustomPhoneNumber or CustomOpnionScale');
  }

  var currentAns = {};

  var isAnswerCollected = surArr.where((e) => e['question_id'] == obj.key);
  if (isAnswerCollected.length > 0) {
    currentAns = isAnswerCollected.first;
    if (obj.skipped) {
      currentAns[obj.name]['data'] = null;
      currentAns[obj.name]['skipped'] = obj.skipped;
    } else {
      currentAns[obj.name]['data'] = obj.data;
      currentAns[obj.name]['skipped'] = obj.skipped;
    }
  } else {
    if (obj.skipped) {
      currentAns['question_id'] = obj.key;
      currentAns[obj.name] = {};
      currentAns[obj.name]['data'] = obj.data;
      currentAns[obj.name]['skipped'] = obj.skipped;
      currentAns[obj.name]['timeTaken'] = obj.timeTaken;
    } else {
      currentAns['question_id'] = obj.key;
      currentAns[obj.name] = {};
      currentAns[obj.name]['data'] = obj.data;
      currentAns[obj.name]['skipped'] = obj.skipped;
      currentAns[obj.name]['timeTaken'] = obj.timeTaken;
    }
    surArr.add(currentAns);
  }
}

submitAnswerOtherSurvey(domain, token, value) async {
  var url =
      Uri.parse('https://$domain/api/internal/submission/answers/$token');


  var submissionObjPayload = {
    'answers': value,
    'stripe': {
      'currency': {},
      'amount': '',
      'cardCompleted': false,
      'discountCoupon': {},
    },
    'customParams': {},
    'additionalAttributes': {},
    'timeTaken': 24,
    'timeZone': 'Asia/Calcutta',
    'browserLanguage': 'en-GB',
    'language': 'en',
  };

  var body = json.encode(submissionObjPayload);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  return response;
}

getWorkBenchData(
  Map<dynamic, dynamic> workBench,
  key,
  value,
  otherInputText,
  answeredCount,
  otherInput,
  isPhoneInput,
  phoneValue,
) {
  if (value == null) {
    if (workBench[key] != null && workBench['${key}_phone'] != null) {
      workBench.remove(key);
      workBench.remove('${key}_phone');
    }

    if (workBench[key] != null && workBench['${key}_other'] != null) {
      workBench.remove(key);
      workBench.remove('${key}_other');
    }
    if (workBench[key] != null) {
      workBench.remove(key);
    }
  }

  if (value != null) {
    answeredCount += 1;
    if (otherInput == true) {
      var newMap = {...workBench};
      newMap[key] = value;
      newMap['${key}_other'] = otherInputText;
      workBench = newMap;
    } else if (isPhoneInput) {
      var newMap = {...workBench};
      newMap[key] = value;
      newMap['${key}_phone'] = phoneValue;
      workBench = newMap;
    } else {
      workBench[key] = value;
    }
  }

  return workBench;
}
