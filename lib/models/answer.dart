// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

class CustomEmailInput {
    CustomEmailInput({
        required this.skipped,
        required this.data,
        required this.timeTaken,
        this.name = "EmailInput",
        required this.key,
    });

    bool skipped;
    String data;
    int timeTaken;
    String name;
    int key;

    factory CustomEmailInput.fromMap(Map<String, dynamic> json) => CustomEmailInput(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
    };
}

class CustomMultiChoice {
    CustomMultiChoice({
      required this.data,
      required this.skipped,
      required this.timeTaken,
      this.name = "MultiChoice",
      required this.key,
    });

    List<dynamic>? data;
    bool? skipped;
    int? timeTaken;
    String name;
    int key;

    factory CustomMultiChoice.fromMap(Map<String, dynamic> json) => CustomMultiChoice(
        data: json["data"] == null ? null : List<dynamic>.from(json["data"].map((x) => x)),
        skipped: json["skipped"] == null ? null : json["skipped"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x)),
        "skipped": skipped == null ? null : skipped,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
    };
}

class CustomOpinionScale {
    CustomOpinionScale({
        this.skipped,
        this.data,
        this.timeTaken,
        this.name = "OpinionScale",
        required this.key,
    });

    bool? skipped;
    int? data;
    int? timeTaken;
    String name;
    int key;

    factory CustomOpinionScale.fromMap(Map<String, dynamic> json) => CustomOpinionScale(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
    };
}

class CustomRating {
    CustomRating({
        this.skipped,
        this.data,
        this.timeTaken,
        this.name = "Rating",
        required this.key,
    });

    bool? skipped;
    int? data;
    int? timeTaken;
    String name;
    int key;

    factory CustomRating.fromMap(Map<String, dynamic> json) => CustomRating(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
    };
}

class CustomYesNo {
    CustomYesNo({
        this.skipped,
        this.data,
        this.timeTaken,
        this.name = "YesNo",
        required this.key,
    });

    bool? skipped;
    bool? data;
    int? timeTaken;
    String name;
    int key;

    factory CustomYesNo.fromMap(Map<String, dynamic> json) => CustomYesNo(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
        "key": key == null ? null : key,
    };
}

class CustomTextInput {
    CustomTextInput({
        required this.skipped,
        required this.data,
        required this.timeTaken,
        this.name = "TextInput",
        required this.key,
    });

    bool skipped;
    String data;
    int timeTaken;
    String name;
    int key;

    factory CustomTextInput.fromMap(Map<String, dynamic> json) => CustomTextInput(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
    };
}

class CustomPhoneNumber {
    CustomPhoneNumber({
        required this.skipped,
        required this.data,
        required this.timeTaken,
        this.name = "PhoneNumber",
        required this.key,
    });

    bool skipped;
    String data;
    int timeTaken;
    String name;
    int key;

    factory CustomPhoneNumber.fromMap(Map<String, dynamic> json) => CustomPhoneNumber(
        skipped: json["skipped"] == null ? null : json["skipped"],
        data: json["data"] == null ? null : json["data"],
        timeTaken: json["timeTaken"] == null ? null : json["timeTaken"],
        name: json["name"] == null ? null : json["name"],
        key: json["key"] == null ? null : json["key"],
    );

    Map<String, dynamic> toMap() => {
        "skipped": skipped == null ? null : skipped,
        "data": data == null ? null : data,
        "timeTaken": timeTaken == null ? null : timeTaken,
        "name": name == null ? null : name,
    };
}