import 'dart:convert';
import 'package:http/http.dart' as http;

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

submitAnswer(_collectedAnswers, finalTime, customParams, token) async {
  var url = Uri.parse(
      'https://madbee.surveysparrow.com/api/internal/offline-app/v3/post-sdk-data/${token}');
  Map<dynamic, dynamic> payload = {};

  payload['answers'] = _collectedAnswers;
  payload['finalTime'] = finalTime;
  payload['customParam'] = customParams;

  final String encodedData = json.encode(payload);
  var response = await http.post(url, body: encodedData);
  return response;
}

createAnswerPayload(
  _collectedAnswers,
  key,
  value,
  _surveyToMap,
  otherInput,
  otherInputText,
  otherInputId,
  isPhoneInput,
  phoneValue,
  time,
) {
  var currentAnswer;
  var currentAnswerToSync;

  var isAnswerCollected =
      _collectedAnswers.where((e) => e['question_id'] == key);

  if (isAnswerCollected.length > 0) {
    currentAnswer = isAnswerCollected.first;
    if (value == null) {
      currentAnswer[_surveyToMap[key]['type']]['data'] = null;
      currentAnswer[_surveyToMap[key]['type']]['skipped'] = true;
    } else {
      currentAnswer[_surveyToMap[key]['type']]['data'] = getAnswerValueToStore(
        value,
        otherInput,
        otherInputText,
        otherInputId,
        isPhoneInput,
        phoneValue,
      );
      currentAnswer[_surveyToMap[key]['type']]['skipped'] = false;
    }
  } else {
    currentAnswer = {};
    currentAnswerToSync = {};
    if (value == null) {
      currentAnswer['question_id'] = key;
      currentAnswer[_surveyToMap[key]['type']] = {};
      currentAnswer[_surveyToMap[key]['type']]['data'] = null;
      currentAnswer[_surveyToMap[key]['type']]['skipped'] = true;
      currentAnswer[_surveyToMap[key]['type']]['timeTaken'] = time;
    } else {
      currentAnswer['question_id'] = key;
      currentAnswer[_surveyToMap[key]['type']] = {};
      currentAnswer[_surveyToMap[key]['type']]['data'] = getAnswerValueToStore(
        value,
        otherInput,
        otherInputText,
        otherInputId,
        isPhoneInput,
        phoneValue,
      );
      currentAnswer[_surveyToMap[key]['type']]['skipped'] = false;
      currentAnswer[_surveyToMap[key]['type']]['timeTaken'] = time;
    }
    _collectedAnswers.add(currentAnswer);
  }
}

createAnswerPayloadOtherSurvey(key, value, type, surArr, skipped, time) {
  var currentAns = {};

  var isAnswerCollected = surArr.where((e) => e['question_id'] == key);
  if (isAnswerCollected.length > 0) {
    currentAns = isAnswerCollected.first;
    if (skipped) {
      currentAns[type]['data'] = null;
      currentAns[type]['skipped'] = true;
    } else {
      currentAns[type]['data'] = value;
      currentAns[type]['skipped'] = false;
    }
  } else {
    if (skipped) {
      currentAns['question_id'] = key;
      currentAns[type] = {};
      currentAns[type]['data'] = value;
      currentAns[type]['skipped'] = true;
      currentAns[type]['timeTaken'] = time;
    } else {
      currentAns['question_id'] = key;
      currentAns[type] = {};
      currentAns[type]['data'] = value;
      currentAns[type]['skipped'] = false;
      currentAns[type]['timeTaken'] = time;
    }
    surArr.add(currentAns);
  }
}

submitAnswerOtherSurvey(token, value) async {
  var url = Uri.parse(
      'https://madbee.surveysparrow.com/api/internal/offline-app/v3/post-sdk-data/${token}');
  Map<dynamic, dynamic> payload = {};

  payload['answers'] = value;
  payload['finalTime'] = 15;
  payload['customParam'] = {};

  final String encodedData = json.encode(payload);
  var response = await http.post(url, body: encodedData);

  return response;
}

getWorkBenchData(
  Map<dynamic, dynamic> _workBench,
  key,
  value,
  otherInputText,
  _answeredCount,
  otherInput,
  isPhoneInput,
  phoneValue,
) {
  if (value == null) {
    if (_workBench[key] != null && _workBench['${key}_phone'] != null) {
      _workBench.remove(key);
      _workBench.remove('${key}_phone');
    }

    if (_workBench[key] != null && _workBench['${key}_other'] != null) {
      _workBench.remove(key);
      _workBench.remove('${key}_other');
    }
    if (_workBench[key] != null) {
      _workBench.remove(key);
    }
  }

  if (value != null) {
    _answeredCount += 1;
    if (otherInput == true) {
      var _newMap = {..._workBench};
      _newMap[key] = value;
      _newMap['${key}_other'] = otherInputText;
      _workBench = _newMap;
    } else if (isPhoneInput) {
      var _newMap = {..._workBench};
      _newMap[key] = value;
      _newMap['${key}_phone'] = phoneValue;
      _workBench = _newMap;
    } else {
      _workBench[key] = value;
    }
  }

  return _workBench;
}
