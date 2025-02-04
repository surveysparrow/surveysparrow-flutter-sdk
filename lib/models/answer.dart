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

  factory CustomEmailInput.fromMap(Map<String, dynamic> json) =>
      CustomEmailInput(
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
        "key": key,
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

  factory CustomMultiChoice.fromMap(Map<String, dynamic> json) =>
      CustomMultiChoice(
        data: json["data"] == null
            ? null
            : List<dynamic>.from(json["data"].map((x) => x)),
        skipped: json["skipped"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x)),
        "skipped": skipped,
        "timeTaken": timeTaken,
        "name": name,
        "key": key,
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

  factory CustomOpinionScale.fromMap(Map<String, dynamic> json) =>
      CustomOpinionScale(
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
        "key": key,
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
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
        "key": key,
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
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
        "key": key,
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
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
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

  factory CustomPhoneNumber.fromMap(Map<String, dynamic> json) =>
      CustomPhoneNumber(
        skipped: json["skipped"],
        data: json["data"],
        timeTaken: json["timeTaken"],
        name: json["name"],
        key: json["key"],
      );

  Map<String, dynamic> toMap() => {
        "skipped": skipped,
        "data": data,
        "timeTaken": timeTaken,
        "name": name,
      };
}
