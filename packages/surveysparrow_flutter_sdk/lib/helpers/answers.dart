import 'dart:convert';
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

submitAnswer(_collectedAnswers, finalTime, customParams, token, domain) async {
  var url =
      Uri.parse('http://${domain}/api/internal/submission/answers/${token}');
  Map<dynamic, dynamic> payload = {};

  var submissionObjPayload = {
    'answers': _collectedAnswers,
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

  payload['answers'] = _collectedAnswers;
  payload['finalTime'] = finalTime;
  payload['customParam'] = customParams;

  var body = json.encode(submissionObjPayload);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);

  // final String encodedData = json.encode(payload);
  // var response = await http.post(url, body: encodedData);
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
      currentAnswer[_surveyToMap[key]['type']]
          .removeWhere((key, value) => key == "data");
      // currentAnswer[_surveyToMap[key]['type']]['data'] = null;
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

createAnswerPayloadOtherSurvey(obj, surArr) {
  if (!(obj is CustomRating ||
      obj is CustomEmailInput ||
      obj is CustomMultiChoice ||
      obj is CustomTextInput ||
      obj is CustomYesNo ||
      obj is CustomOpinionScale ||
      obj is CustomPhoneNumber)) {
    throw Exception(
        'obj has to be a instance of CustomRating or CustomEmailInput');
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

submitAnswerOtherSurvey(token, value) async {
  var url = Uri.parse(
      'http://sample.surveysparrow.test/api/internal/submission/answers/${token}');
  Map<dynamic, dynamic> payload = {};

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
