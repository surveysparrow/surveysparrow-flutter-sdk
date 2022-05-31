import 'mapLogicComparators.dart';
import 'package:eval_ex/expression.dart';

handleDisplayAndSkipLogic(question, type,_allowedQuestionIds,_workBench) {
    var questionLogics;
    if (question == null) {
      return true;
    } else {
      var contionMapping = {'and': '&&', 'or': '||'};
      if (type == 'dl') {
        if (question['displayLogic']['logics'].length > 0) {
          questionLogics = question['displayLogic']['logics'];
          var logicEvaluation = [];
          for (var logic in questionLogics) {
            if (_allowedQuestionIds.contains(logic['question_id'])) {
              var join_condition = logic['join_condition'];
              var result = checkLogic(logic, _workBench);
              logicEvaluation
                  .add({'join_condition': join_condition, 'result': result});
            }
          }
          var evalString;
          var index = 0;
          var tempEvalString = '';
          for (var logicEval in logicEvaluation) {
            if (index == 0) {
              tempEvalString = '${true} && ${logicEval['result']}';
            } else {
              tempEvalString = tempEvalString +
                  ' ${contionMapping[logicEval['join_condition']]} ${logicEval['result']}';
            }
            index += 1;
          }

          Expression exp = Expression(tempEvalString);
          var finalResult;
          if (tempEvalString.length > 0) {
            Expression exp = Expression(tempEvalString);
            finalResult = int.parse(exp.eval().toString()) == 0 ? false : true;
          } else {
            finalResult = true;
          }
          return finalResult;
        } else {
          return true;
        }
      }

      // jumplogic
      if (type == 'jl') {
        if (question['jumpLogic']['logics'][0]['logics'].length > 0) {
          questionLogics = question['jumpLogic']['logics'][0]['logics'];
          var logicEvaluation = [];
          for (var logic in questionLogics) {
            if (_allowedQuestionIds.contains(logic['question_id'])) {
              var join_condition = logic['join_condition'];
              var result = checkLogic(logic, _workBench);
              logicEvaluation
                  .add({'join_condition': join_condition, 'result': result});
            }
          }
          var evalString;
          var index = 0;
          var tempEvalString = '';
          for (var logicEval in logicEvaluation) {
            if (index == 0) {
              tempEvalString = '${true} && ${logicEval['result']}';
            } else {
              tempEvalString = tempEvalString +
                  ' ${contionMapping[logicEval['join_condition']]} ${logicEval['result']}';
            }
            index += 1;
          }
          var finalResult;
          if (tempEvalString.length > 0) {
            Expression exp = Expression(tempEvalString);
            finalResult = int.parse(exp.eval().toString()) == 0 ? false : true;
          } else {
            finalResult = false;
          }
          return finalResult;
        } else {
          return true;
        }
      }
    }
  }