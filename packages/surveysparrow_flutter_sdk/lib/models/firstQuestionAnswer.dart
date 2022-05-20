// To parse this JSON data, do
//
//     final FirstQuestionAnswer = FirstQuestionAnswerFromMap(jsonString);

import 'dart:convert';

FirstQuestionAnswer firstQuestionAnswerFromMap(String str) => FirstQuestionAnswer.fromMap(json.decode(str));

String firstQuestionAnswerToMap(FirstQuestionAnswer data) => json.encode(data.toMap());

class FirstQuestionAnswer {
    FirstQuestionAnswer({
        this.rating,
        this.text,
        this.opnionScale,
        this.email,
        this.yesOrNo,
        this.phoneNumber,
        this.multipleChoice,
    });

    int? rating;
    String? text;
    int? opnionScale;
    String? email;
    bool? yesOrNo;
    String? phoneNumber;
    List<int>? multipleChoice;

    factory FirstQuestionAnswer.fromMap(Map<String, dynamic> json) => FirstQuestionAnswer(
        rating: json["rating"] == null ? null : json["rating"],
        text: json["text"] == null ? null : json["text"],
        opnionScale: json["opnionScale"] == null ? null : json["opnionScale"],
        email: json["email"] == null ? null : json["email"],
        yesOrNo: json["yesOrNo"] == null ? null : json["yesOrNo"],
        phoneNumber: json["phoneNumber"] == null ? null : json["phoneNumber"],
        multipleChoice: json["multipleChoice"] == null ? null : List<int>.from(json["multipleChoice"].map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "rating": rating == null ? null : rating,
        "text": text == null ? null : text,
        "opnionScale": opnionScale == null ? null : opnionScale,
        "email": email == null ? null : email,
        "yesOrNo": yesOrNo == null ? null : yesOrNo,
        "phoneNumber": phoneNumber == null ? null : phoneNumber,
        "multipleChoice": multipleChoice == null ? null : List<dynamic>.from(multipleChoice!.map((x) => x)),
    };
}
