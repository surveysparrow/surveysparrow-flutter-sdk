isEqualForRating(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'].length > 0 && answer == int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isNotEqualForRating(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'].length > 0 && answer != int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

lessThanForRating(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'].length > 0 && answer < int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isAnswered(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    return true;
  } else {
    return false;
  }
}

greaterThanForRating(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (answer > int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isNotAnswered(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    return false;
  } else {
    return true;
  }
}



// multiple choice

isSelected(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['choice_id'] != null) {
      if (answer.contains(logic['choice_id'])) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isNotSelected(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['choice_id'] != null) {
      if (answer.contains(logic['choice_id'])) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

// text input

checkContains(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'] != null) {
      if (answer.contains(logic['value'])) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkStartsWith(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'] != null) {
      if (answer.startsWith(logic['value'])) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkEndsWith(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'] != null) {
      if (answer.endsWith(logic['value'])) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkEqualsString(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (logic['value'] != null) {
      if (answer == logic['value']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkEqualToForYesNo(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (answer.toString() == logic['value']) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkNotEqualToForYesNo(logic, _myMap) {
  var _questionIdToCheck = logic['question_id'];
  if (_myMap[_questionIdToCheck] != null) {
    var answer = _myMap[_questionIdToCheck];
    if (answer.toString() != logic['value']) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}