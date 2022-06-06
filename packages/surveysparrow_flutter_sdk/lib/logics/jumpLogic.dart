import 'logics.dart';

hasJumpLogic(question) {
  return question['jumpLogic']['logics'].length >= 1;
}

newJumpLogic(_currentId, _questionPos, _allQuestionList, _allowedQuestionIds,
    _workBench) {
  var nextIndex = _questionPos[_currentId] + 1;
  var questionToCheck = _allQuestionList[_questionPos[_currentId]];
  dynamic hasThankYouLogic = false;

  if (hasJumpLogic(questionToCheck)) {
    var questionIdToJump =
        questionToCheck['jumpLogic']['logics'][0]['jump_to_id'];
    var questionJumpLogics =
        questionToCheck['jumpLogic']['logics'][0]['logics'];

    var jump = handleDisplayAndSkipLogic(
        questionToCheck, 'jl', _allowedQuestionIds, _workBench);
    
    if (jump) {
      if(questionToCheck['jumpLogic']['logics'][0]['jump_to_id'].toString().contains("ty:")){
        hasThankYouLogic = questionToCheck['jumpLogic']['logics'][0]['jump_to_id'];
      }
      if(questionToCheck['jumpLogic']['logics'][0]['jump_to_id'].toString() == "-2"){
        hasThankYouLogic = questionToCheck['jumpLogic']['logics'][0]['redirectUrl'];
      }
      nextIndex = _questionPos[questionIdToJump];
    }
  }
  return [nextIndex,hasThankYouLogic];
}
