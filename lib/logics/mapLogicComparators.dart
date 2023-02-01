import 'logicComparators.dart';

checkLogic(logic,_workBench) {
    if (logic['comparator'] == 'isAnswered') {
      return isAnswered(logic, _workBench);
    }

    if (logic['comparator'] == 'isNotAnswered') {
      return isNotAnswered(logic, _workBench);
    }

    if (logic['comparator'] == 'greaterThanForRating' ||
        logic['comparator'] == 'greaterThanForScale' ||
        logic['comparator'] == 'greaterThanForNumber') {
      return greaterThanForRating(logic, _workBench);
    }
    if (logic['comparator'] == 'lessThanForRating' ||
        logic['comparator'] == 'lessThanForScale') {
      return lessThanForRating(logic, _workBench);
    }

    if (logic['comparator'] == 'equalToForRating' ||
        logic['comparator'] == 'equalToForScale') {
      return isEqualForRating(logic, _workBench);
    }

    if (logic['comparator'] == 'notEqualToForRating' ||
        logic['comparator'] == 'notEqualToForScale') {
      return isNotEqualForRating(logic, _workBench);
    }

    if (logic['comparator'] == 'isSelected') {
      return isSelected(logic, _workBench);
    }

    if (logic['comparator'] == 'isNotSelected') {
      return isNotSelected(logic, _workBench);
    }

    if (logic['comparator'] == 'contains') {
      return checkContains(logic, _workBench);
    }

    if (logic['comparator'] == 'startsWith') {
      return checkStartsWith(logic, _workBench);
    }

    if (logic['comparator'] == 'endsWith') {
      return checkEndsWith(logic, _workBench);
    }

    if (logic['comparator'] == 'equalsString') {
      return checkEqualsString(logic, _workBench);
    }

    if(logic['comparator'] == 'equalToForYesNo'){
      return checkEqualToForYesNo(logic, _workBench);
    }

    if(logic['comparator'] == 'notEqualToForYesNo'){
      return checkNotEqualToForYesNo(logic, _workBench);
    }
    
    return true;
  }