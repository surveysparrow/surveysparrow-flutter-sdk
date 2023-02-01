import 'package:eval_ex/expression.dart';
import 'package:surveysparrow_flutter_sdk/logics/mapLogicComparators.dart';

checkThankYouLogics(thankYouPages, _workBench,_hasThankYouLogicSkip) {
  if(_hasThankYouLogicSkip is String && _hasThankYouLogicSkip != false){
    var thankYouIndex = _hasThankYouLogicSkip.replaceAll('ty:', '');
    return thankYouPages[int.parse(thankYouIndex)];
  }

  if (thankYouPages.length == 1) {
    return thankYouPages[0];
  } else {
    var contionMapping = {'and': '&&', 'or': '||'};
    var undefinedThankyou = -1;

    for (var i = 0; i < thankYouPages.length; i++) {
      if (thankYouPages[i]['displayLogic'] == null) {
        return thankYouPages[i];
      }

      var logicEvaluation = [];
      var logicPass = false;
      var thankYouIndex = 0;

      for (var logic in thankYouPages[i]['displayLogic']['logics']) {
        if (logic['type'] == '' ||
            logic['comparator'] == '' ||
            logic['value'] == '') {
          if (undefinedThankyou == -1) {
            undefinedThankyou = i;
          }
          break;
        }
        var join_condition = logic['join_condition'];
        var result = checkLogic(logic, _workBench);
        logicEvaluation
            .add({'join_condition': join_condition, 'result': result});
      }
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
      }
      if (finalResult != null && finalResult == true) {
        return thankYouPages[i];
      }
    }
    return thankYouPages[1];
  }
}
