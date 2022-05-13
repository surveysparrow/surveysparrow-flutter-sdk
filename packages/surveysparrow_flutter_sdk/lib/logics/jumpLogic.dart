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
    // var jump = _coreDisplayLogic(questionToCheck, 'jl');

    var jump = handleDisplayAndSkipLogic(
        questionToCheck, 'jl', _allowedQuestionIds, _workBench);
    
    if (jump) {
      if(questionToCheck['jumpLogic']['logics'][0]['jump_to_id'].toString().contains("ty:")){
        print("lq12 inside jump //////// ");
        hasThankYouLogic = questionToCheck['jumpLogic']['logics'][0]['jump_to_id'];
      }
      if(questionToCheck['jumpLogic']['logics'][0]['jump_to_id'].toString() == "-2"){
        print("lq12 inside jump redirect //////// ");
        hasThankYouLogic = questionToCheck['jumpLogic']['logics'][0]['jump_to_id'];
      }
      print("lq12 jump q is ${questionToCheck['jumpLogic']['logics'][0]} ");
      // if(questionToCheck[])
      nextIndex = _questionPos[questionIdToJump];
    }
  }
  // print("lq12 next index is ${questionToCheck} ");

  return [nextIndex,hasThankYouLogic];
}
