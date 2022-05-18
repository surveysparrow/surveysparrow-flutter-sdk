// To parse this JSON data, do
//
//     final CustomSurveyTheme = CustomSurveyThemeFromMap(jsonString);

import 'dart:convert';

CustomSurveyTheme customSurveyThemeFromMap(String str) =>
    CustomSurveyTheme.fromMap(json.decode(str));

String customSurveyThemeToMap(CustomSurveyTheme data) => json.encode(data.toMap());

class CustomSurveyTheme {
  CustomSurveyTheme({
    this.question,
    this.font,
    this.bottomBar,
    this.rating,
    this.opnionScale,
    this.phoneNumber,
    this.yesOrNo,
    this.multipleChoice,
    this.email,
    this.text,
  });

  Question? question;
  String? font;
  BottomBar? bottomBar;
  Rating? rating;
  OpnionScale? opnionScale;
  PhoneNumber? phoneNumber;
  YesOrNo? yesOrNo;
  MultipleChoice? multipleChoice;
  Email? email;
  Email? text;

  factory CustomSurveyTheme.fromMap(Map<String, dynamic> json) => CustomSurveyTheme(
        question: json["question"] == null
            ? null
            : Question.fromMap(json["question"]),
        font: json["font"] == null ? null : json["font"],
        bottomBar: json["bottomBar"] == null
            ? null
            : BottomBar.fromMap(json["bottomBar"]),
        rating: json["rating"] == null ? null : Rating.fromMap(json["rating"]),
        opnionScale: json["opnionScale"] == null
            ? null
            : OpnionScale.fromMap(json["opnionScale"]),
        phoneNumber: json["phoneNumber"] == null
            ? null
            : PhoneNumber.fromMap(json["phoneNumber"]),
        yesOrNo:
            json["yesOrNo"] == null ? null : YesOrNo.fromMap(json["yesOrNo"]),
        multipleChoice: json["multipleChoice"] == null
            ? null
            : MultipleChoice.fromMap(json["multipleChoice"]),
        email: json["email"] == null ? null : Email.fromMap(json["email"]),
        text: json["text"] == null ? null : Email.fromMap(json["text"]),
      );

  Map<String, dynamic> toMap() => {
        "question": question == null ? null : question?.toMap(),
        "font": font == null ? null : font,
        "bottomBar": bottomBar == null ? null : bottomBar?.toMap(),
        "rating": rating == null ? null : rating?.toMap(),
        "opnionScale": opnionScale == null ? null : opnionScale?.toMap(),
        "phoneNumber": phoneNumber == null ? null : phoneNumber?.toMap(),
        "yesOrNo": yesOrNo == null ? null : yesOrNo?.toMap(),
        "multipleChoice":
            multipleChoice == null ? null : multipleChoice?.toMap(),
        "email": email == null ? null : email?.toMap(),
        "text": text == null ? null : text?.toMap(),
      };
}

class BottomBar {
  BottomBar({
    this.showPadding,
    this.direction,
  });

  bool? showPadding;
  String? direction;

  factory BottomBar.fromMap(Map<String, dynamic> json) => BottomBar(
        showPadding: json["showPadding"] == null ? null : json["showPadding"],
        direction: json["direction"] == null ? null : json["direction"],
      );

  Map<String, dynamic> toMap() => {
        "showPadding": showPadding == null ? null : showPadding,
        "direction": direction == null ? null : direction,
      };
}

class Email {
  Email({
    this.fontSize,
    this.textFieldWidth,
  });

  double? fontSize;
  double? textFieldWidth;

  factory Email.fromMap(Map<String, dynamic> json) => Email(
        fontSize: json["fontSize"] == null ? null : json["fontSize"],
        textFieldWidth:
            json["textFieldWidth"] == null ? null : json["textFieldWidth"],
      );

  Map<String, dynamic> toMap() => {
        "fontSize": fontSize == null ? null : fontSize,
        "textFieldWidth": textFieldWidth == null ? null : textFieldWidth,
      };
}

class MultipleChoice {
  MultipleChoice({
    this.choiceContainerWidth,
    this.choiceContainerHeight,
    this.fontSize,
    this.circularFontContainerSize,
    this.otherOptionTextFieldHeight,
    this.otherOptionTextFieldWidth,
    this.otherOptionTextFontSize,
  });

  double? choiceContainerWidth;
  double? choiceContainerHeight;
  double? fontSize;
  double? circularFontContainerSize;
  double? otherOptionTextFieldHeight;
  double? otherOptionTextFieldWidth;
  double? otherOptionTextFontSize;

  factory MultipleChoice.fromMap(Map<String, dynamic> json) => MultipleChoice(
        choiceContainerWidth: json["choiceContainerWidth"] == null
            ? null
            : json["choiceContainerWidth"],
        choiceContainerHeight: json["choiceContainerHeight"] == null
            ? null
            : json["choiceContainerHeight"],
        fontSize: json["fontSize"] == null ? null : json["fontSize"],
        circularFontContainerSize: json["circularFontContainerSize"] == null
            ? null
            : json["circularFontContainerSize"],
        otherOptionTextFieldHeight: json["otherOptionTextFieldHeight"] == null
            ? null
            : json["otherOptionTextFieldHeight"],
        otherOptionTextFieldWidth: json["otherOptionTextFieldWidth"] == null
            ? null
            : json["otherOptionTextFieldWidth"],
        otherOptionTextFontSize: json["otherOptionTextFontSize"] == null
            ? null
            : json["otherOptionTextFontSize"],
      );

  Map<String, dynamic> toMap() => {
        "choiceContainerWidth":
            choiceContainerWidth == null ? null : choiceContainerWidth,
        "choiceContainerHeight":
            choiceContainerHeight == null ? null : choiceContainerHeight,
        "fontSize": fontSize == null ? null : fontSize,
        "circularFontContainerSize": circularFontContainerSize == null
            ? null
            : circularFontContainerSize,
        "otherOptionTextFieldHeight": otherOptionTextFieldHeight == null
            ? null
            : otherOptionTextFieldHeight,
        "otherOptionTextFieldWidth": otherOptionTextFieldWidth == null
            ? null
            : otherOptionTextFieldWidth,
        "otherOptionTextFontSize":
            otherOptionTextFontSize == null ? null : otherOptionTextFontSize,
      };
}

class OpnionScale {
  OpnionScale({
    this.outerBlockSizeWidth,
    this.outerBlockSizeHeight,
    this.innerBlockSizeWidth,
    this.innerBlockSizeHeight,
    this.labelFontSize,
    this.numberFontSize,
  });

  double? outerBlockSizeWidth;
  double? outerBlockSizeHeight;
  double? innerBlockSizeWidth;
  double? innerBlockSizeHeight;
  double? labelFontSize;
  double? numberFontSize;

  factory OpnionScale.fromMap(Map<String, dynamic> json) => OpnionScale(
        outerBlockSizeWidth: json["outerBlockSizeWidth"] == null
            ? null
            : json["outerBlockSizeWidth"],
        outerBlockSizeHeight: json["outerBlockSizeHeight"] == null
            ? null
            : json["outerBlockSizeHeight"],
        innerBlockSizeWidth: json["innerBlockSizeWidth"] == null
            ? null
            : json["innerBlockSizeWidth"],
        innerBlockSizeHeight: json["innerBlockSizeHeight"] == null
            ? null
            : json["innerBlockSizeHeight"],
        labelFontSize:
            json["labelFontSize"] == null ? null : json["labelFontSize"],
        numberFontSize:
            json["numberFontSize"] == null ? null : json["numberFontSize"],
      );

  Map<String, dynamic> toMap() => {
        "outerBlockSizeWidth":
            outerBlockSizeWidth == null ? null : outerBlockSizeWidth,
        "outerBlockSizeHeight":
            outerBlockSizeHeight == null ? null : outerBlockSizeHeight,
        "innerBlockSizeWidth":
            innerBlockSizeWidth == null ? null : innerBlockSizeWidth,
        "innerBlockSizeHeight":
            innerBlockSizeHeight == null ? null : innerBlockSizeHeight,
        "labelFontSize": labelFontSize == null ? null : labelFontSize,
        "numberFontSize": numberFontSize == null ? null : numberFontSize,
      };
}

class PhoneNumber {
  PhoneNumber({
    this.defaultNumber,
    this.fontSize,
    this.countryPickerWidth,
    this.countryPickerHeight,
    this.countryCodeInputWidth,
    this.countryCodeInputHeight,
    this.countryCodeNumberInputHeight,
    this.countryCodeNumberInputWidth,
  });

  String? defaultNumber;
  double? fontSize;
  double? countryPickerWidth;
  double? countryPickerHeight;
  double? countryCodeInputWidth;
  double? countryCodeInputHeight;
  double? countryCodeNumberInputHeight;
  double? countryCodeNumberInputWidth;

  factory PhoneNumber.fromMap(Map<String, dynamic> json) => PhoneNumber(
        defaultNumber:
            json["defaultNumber"] == null ? null : json["defaultNumber"],
        fontSize: json["fontSize"] == null ? null : json["fontSize"],
        countryPickerWidth: json["countryPickerWidth"] == null
            ? null
            : json["countryPickerWidth"],
        countryPickerHeight: json["countryPickerHeight"] == null
            ? null
            : json["countryPickerHeight"],
        countryCodeInputWidth: json["countryCodeInputWidth"] == null
            ? null
            : json["countryCodeInputWidth"],
        countryCodeInputHeight: json["countryCodeInputHeight"] == null
            ? null
            : json["countryCodeInputHeight"],
        countryCodeNumberInputHeight:
            json["countryCodeNumberInputHeight"] == null
                ? null
                : json["countryCodeNumberInputHeight"],
        countryCodeNumberInputWidth: json["countryCodeNumberInputWidth"] == null
            ? null
            : json["countryCodeNumberInputWidth"],
      );

  Map<String, dynamic> toMap() => {
        "defaultNumber": defaultNumber == null ? null : defaultNumber,
        "fontSize": fontSize == null ? null : fontSize,
        "countryPickerWidth":
            countryPickerWidth == null ? null : countryPickerWidth,
        "countryPickerHeight":
            countryPickerHeight == null ? null : countryPickerHeight,
        "countryCodeInputWidth":
            countryCodeInputWidth == null ? null : countryCodeInputWidth,
        "countryCodeInputHeight":
            countryCodeInputHeight == null ? null : countryCodeInputHeight,
        "countryCodeNumberInputHeight": countryCodeNumberInputHeight == null
            ? null
            : countryCodeNumberInputHeight,
        "countryCodeNumberInputWidth": countryCodeNumberInputWidth == null
            ? null
            : countryCodeNumberInputWidth,
      };
}

class Question {
  Question({
    this.questionNumberFontSize,
    this.questionHeadingFontSize,
    this.questionDescriptionFontSize,
  });

  double? questionNumberFontSize;
  double? questionHeadingFontSize;
  double? questionDescriptionFontSize;

  factory Question.fromMap(Map<String, dynamic> json) => Question(
        questionNumberFontSize: json["questionNumberFontSize"] == null
            ? null
            : json["questionNumberFontSize"],
        questionHeadingFontSize: json["questionHeadingFontSize"] == null
            ? null
            : json["questionHeadingFontSize"],
        questionDescriptionFontSize: json["questionDescriptionFontSize"] == null
            ? null
            : json["questionDescriptionFontSize"],
      );

  Map<String, dynamic> toMap() => {
        "questionNumberFontSize":
            questionNumberFontSize == null ? null : questionNumberFontSize,
        "questionHeadingFontSize":
            questionHeadingFontSize == null ? null : questionHeadingFontSize,
        "questionDescriptionFontSize": questionDescriptionFontSize == null
            ? null
            : questionDescriptionFontSize,
      };
}

class Rating {
  Rating({
    this.showNumber,
    this.customRatingSvgUnselected,
    this.customRatingSvgSelected,
    this.svgHeight,
    this.svgWidth,
  });

  bool? showNumber;
  String? customRatingSvgUnselected;
  String? customRatingSvgSelected;
  double? svgHeight;
  double? svgWidth;

  factory Rating.fromMap(Map<String, dynamic> json) => Rating(
        showNumber: json["showNumber"] == null ? null : json["showNumber"],
        customRatingSvgUnselected: json["customRatingSVGUnselected"] == null
            ? null
            : json["customRatingSVGUnselected"],
        customRatingSvgSelected: json["customRatingSVGSelected"] == null
            ? null
            : json["customRatingSVGSelected"],
        svgHeight: json["svgHeight"] == null ? null : json["svgHeight"],
        svgWidth: json["svgWidth"] == null ? null : json["svgWidth"],
      );

  Map<String, dynamic> toMap() => {
        "showNumber": showNumber == null ? null : showNumber,
        "customRatingSVGUnselected": customRatingSvgUnselected == null
            ? null
            : customRatingSvgUnselected,
        "customRatingSVGSelected":
            customRatingSvgSelected == null ? null : customRatingSvgSelected,
        "svgHeight": svgHeight == null ? null : svgHeight,
        "svgWidth": svgWidth == null ? null : svgWidth,
      };
}

class YesOrNo {
  YesOrNo({
    this.svgWidth,
    this.svgHeight,
    this.outerContainerWidth,
    this.outerContainerHeight,
    this.fontSize,
    this.circleFontIndicatorSize,
    this.customSvgStringSelected,
    this.customSvgStringUnSelected,
  });

  double? svgWidth;
  double? svgHeight;
  double? outerContainerWidth;
  double? outerContainerHeight;
  double? fontSize;
  double? circleFontIndicatorSize;
  String? customSvgStringSelected;
  String? customSvgStringUnSelected;

  factory YesOrNo.fromMap(Map<String, dynamic> json) => YesOrNo(
        svgWidth: json["svgWidth"] == null ? null : json["svgWidth"],
        svgHeight: json["svgHeight"] == null ? null : json["svgHeight"],
        outerContainerWidth: json["outerContainerWidth"] == null
            ? null
            : json["outerContainerWidth"],
        outerContainerHeight: json["outerContainerHeight"] == null
            ? null
            : json["outerContainerHeight"],
        fontSize: json["fontSize"] == null ? null : json["fontSize"],
        circleFontIndicatorSize: json["circleFontIndicatorSize"] == null
            ? null
            : json["circleFontIndicatorSize"],
        customSvgStringSelected: json["customSvgStringSelected"] == null
            ? null
            : json["customSvgStringSelected"],
        customSvgStringUnSelected: json["customSvgStringUnSelected"] == null
            ? null
            : json["customSvgStringUnSelected"],
      );

  Map<String, dynamic> toMap() => {
        "svgWidth": svgWidth == null ? null : svgWidth,
        "svgHeight": svgHeight == null ? null : svgHeight,
        "outerContainerWidth":
            outerContainerWidth == null ? null : outerContainerWidth,
        "outerContainerHeight":
            outerContainerHeight == null ? null : outerContainerHeight,
        "fontSize": fontSize == null ? null : fontSize,
        "circleFontIndicatorSize":
            circleFontIndicatorSize == null ? null : circleFontIndicatorSize,
        "customSvgStringSelected":
            customSvgStringSelected == null ? null : customSvgStringSelected,
        "customSvgStringUnSelected": customSvgStringUnSelected == null
            ? null
            : customSvgStringUnSelected,
      };
}
