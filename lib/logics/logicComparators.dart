isEqualForRating(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (logic['value'].length > 0 && answer == int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isNotEqualForRating(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (logic['value'].length > 0 && answer != int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

lessThanForRating(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (logic['value'].length > 0 && answer < int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isAnswered(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    return true;
  } else {
    return false;
  }
}

greaterThanForRating(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (answer > int.parse(logic['value'])) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

isNotAnswered(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    return false;
  } else {
    return true;
  }
}

// multiple choice
isSelected(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

isNotSelected(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

checkContains(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

checkStartsWith(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

checkEndsWith(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

checkEqualsString(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
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

checkEqualToForYesNo(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (answer.toString() == logic['value']) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

checkNotEqualToForYesNo(logic, myMap) {
  var questionIdToCheck = logic['question_id'];
  if (myMap[questionIdToCheck] != null) {
    var answer = myMap[questionIdToCheck];
    if (answer.toString() != logic['value']) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
