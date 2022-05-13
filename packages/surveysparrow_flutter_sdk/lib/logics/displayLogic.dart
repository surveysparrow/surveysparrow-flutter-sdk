  import 'jumpLogic.dart';
import 'logics.dart';

handleDisplayLogic(questionId,_allQuestionList,_allowedQuestionIds, _workBench,_questionPos) {
    var canDisplay = false;
    var _currentId = questionId;
    var questionToCheck;
    dynamic hasThankYouJumpLogic = false;
    while (!canDisplay) {
      var jumpEvaluation =  newJumpLogic(_currentId, _questionPos, _allQuestionList, _allowedQuestionIds, _workBench);
      
      print("jump evaluation is ${jumpEvaluation} ");
      if(jumpEvaluation[1] is String && jumpEvaluation[1] != false){
        hasThankYouJumpLogic = jumpEvaluation[1];
      }
      var nextIndex = jumpEvaluation[0];
      if (_allQuestionList.asMap()[nextIndex] != null) {
        questionToCheck = _allQuestionList[nextIndex]; // 67 question obj
        _currentId = questionToCheck['id'];
      } else {
        questionToCheck = null;
        _currentId = null;
      }
      canDisplay = handleDisplayAndSkipLogic(questionToCheck, 'dl', _allowedQuestionIds, _workBench);
    }
    if (questionToCheck != null) {
      return [questionToCheck['id'],hasThankYouJumpLogic];
    }
    return [questionToCheck,hasThankYouJumpLogic];
  }