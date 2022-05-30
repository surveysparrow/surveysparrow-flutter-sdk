// To parse this JSON data, do
//
//     final FirstQuestionAnswer = FirstQuestionAnswerFromMap(jsonString);

import 'dart:convert';

import 'package:surveysparrow_flutter_sdk/models/answer.dart';

String firstQuestionAnswerToMap(FirstQuestionAnswer data) =>
    json.encode(data.toMap());

class FirstQuestionAnswer {
  FirstQuestionAnswer({
    required this.pageNumber,
    required this.answers,
  });

  int pageNumber;
  List<Answer> answers;

  Map<String, dynamic> toMap() => {
        "pageNumber":
            pageNumber == null ? null : pageNumber,
        "answers": answers == null
            ? null
            : List<dynamic>.from(answers.map((x) => x.toMap())),
      };
}

class Answer {
  Answer({
    this.rating,
    this.text,
    this.opnionScale,
    this.email,
    this.yesOrNo,
    this.phoneNumber,
    this.multipleChoice,
  });
  CustomRating? rating;
  CustomTextInput? text;
  CustomOpinionScale? opnionScale;
  CustomEmailInput? email;
  CustomYesNo? yesOrNo;
  CustomPhoneNumber? phoneNumber;
  CustomMultiChoice? multipleChoice;

  Map<String, dynamic> toMap() => {
        "rating": rating == null ? null : rating?.toMap(),
        "text": text == null ? null : text?.toMap(),
        "opnionScale": opnionScale == null ? null : opnionScale?.toMap(),
        "email": email == null ? null : email?.toMap(),
        "yesOrNo": yesOrNo == null ? null : yesOrNo?.toMap(),
        "phoneNumber": phoneNumber == null ? null : phoneNumber?.toMap(),
        "multipleChoice":
            multipleChoice == null ? null : multipleChoice?.toMap(),
      };
}
