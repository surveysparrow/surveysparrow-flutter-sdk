import 'package:flutter/material.dart';

class SurveyProvider with ChangeNotifier {
    Map<dynamic, dynamic> _survey = {};
    String _email = '';

    Map<dynamic, dynamic> get getSurvey => _survey;
    String get getEmail => _email;

    void setSurvey(surveyData){
      _survey = surveyData;
    } 

    void setEmail(emailData){
      _email = emailData;
      notifyListeners();
    } 

    void setInitalEmail(emailData){
      _email = emailData;
    }
}