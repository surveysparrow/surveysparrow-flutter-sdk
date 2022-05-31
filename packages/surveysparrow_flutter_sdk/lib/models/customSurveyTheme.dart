// To parse this JSON data, do
//
//     final CustomSurveyTheme = CustomSurveyThemeFromMap(jsonString);

import 'dart:convert';

CustomSurveyTheme customSurveyThemeFromMap(String str) =>
    CustomSurveyTheme.fromMap(json.decode(str));

String customSurveyThemeToMap(CustomSurveyTheme data) =>
    json.encode(data.toMap());

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
    this.skipButton,
    this.nextButton,
    this.animationDirection,
    this.logo,
    this.welcome,
    this.thankYouPage,
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
  SkipButton? skipButton;
  NextButton? nextButton;
  String? animationDirection;
  Logo? logo;
  WelcomePageTheme? welcome;
  ThankYouPageTheme? thankYouPage;

  factory CustomSurveyTheme.fromMap(Map<String, dynamic> json) =>
      CustomSurveyTheme(
        question: json["question"] == null
            ? null
            : Question.fromMap(json["question"]),
        font: json["font"],
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
        skipButton: json["skipButton"] == null
            ? null
            : SkipButton.fromMap(json["skipButton"]),
        nextButton: json["nextButton"] == null
            ? null
            : NextButton.fromMap(json["nextButton"]),
        animationDirection: json["animationDirection"],
        logo: json["logo"] == null ? null : Logo.fromMap(json["logo"]),
        welcome:
            json["welcome"] == null ? null : WelcomePageTheme.fromMap(json["welcome"]),
        thankYouPage: json["thankYouPage"] == null
            ? null
            : ThankYouPageTheme.fromMap(json["thankYouPage"]),
      );

  Map<String, dynamic> toMap() => {
        "question": question == null ? null : question?.toMap(),
        "font": font,
        "bottomBar": bottomBar == null ? null : bottomBar?.toMap(),
        "rating": rating == null ? null : rating?.toMap(),
        "opnionScale": opnionScale == null ? null : opnionScale?.toMap(),
        "phoneNumber": phoneNumber == null ? null : phoneNumber?.toMap(),
        "yesOrNo": yesOrNo == null ? null : yesOrNo?.toMap(),
        "multipleChoice":
            multipleChoice == null ? null : multipleChoice?.toMap(),
        "email": email == null ? null : email?.toMap(),
        "text": text == null ? null : text?.toMap(),
        "skipButton": skipButton == null ? null : skipButton?.toMap(),
        "nextButton": nextButton == null ? null : nextButton?.toMap(),
        "animationDirection": animationDirection,
        "logo": logo == null ? null : logo?.toMap(),
        "welcome": welcome == null ? null : welcome?.toMap(),
        "thankYouPage": thankYouPage == null ? null : thankYouPage?.toMap(),
      };
}

class WelcomePageTheme {
  WelcomePageTheme({
    this.headerFontSize,
    this.imageDescriptionFontSize,
    this.descriptionFontSize,
    this.imageHeight,
    this.imageWidth,
    this.buttonFontSize,
    this.buttonWidth,
    this.buttonIconSize,
  });

  double? headerFontSize;
  double? descriptionFontSize;
  double? imageDescriptionFontSize;
  double? imageWidth;
  double? imageHeight;
  double? buttonFontSize;
  double? buttonWidth;
  double? buttonIconSize;

  factory WelcomePageTheme.fromMap(Map<String, dynamic> json) => WelcomePageTheme(
        headerFontSize: json["headerFontSize"],
        imageDescriptionFontSize: json["imageDescriptionFontSize"],
        descriptionFontSize: json["descriptionFontSize"],
        imageHeight: json["imageHeight"],
        imageWidth: json["imageWidth"],
        buttonFontSize: json["buttonFontSize"],
        buttonWidth: json["buttonWidth"],
        buttonIconSize: json["buttonIconSize"],
      );

  Map<String, dynamic> toMap() => {
        "headerFontSize": headerFontSize,
        "imageDescriptionFontSize": imageDescriptionFontSize,
        "descriptionFontSize": descriptionFontSize,
        "imageHeight": imageHeight,
        "imageWidth": imageWidth,
        "buttonFontSize": buttonFontSize,
        "buttonWidth": buttonWidth,
        "buttonIconSize": buttonIconSize,
      };
}

class ThankYouPageTheme {
  ThankYouPageTheme({
    this.headerFontSize,
    this.imageDescriptionFontSize,
    this.descriptionFontSize,
    this.imageHeight,
    this.imageWidth,
    this.buttonFontSize,
    this.buttonWidth,
    this.buttonIconSize,
    this.visibilityTime
  });

  double? headerFontSize;
  double? descriptionFontSize;
  double? imageDescriptionFontSize;
  double? imageWidth;
  double? imageHeight;
  double? buttonFontSize;
  double? buttonWidth;
  double? buttonIconSize;
  int? visibilityTime;

  factory ThankYouPageTheme.fromMap(Map<String, dynamic> json) => ThankYouPageTheme(
        headerFontSize: json["headerFontSize"],
        imageDescriptionFontSize: json["imageDescriptionFontSize"],
        descriptionFontSize: json["descriptionFontSize"],
        imageHeight: json["imageHeight"],
        imageWidth: json["imageWidth"],
        buttonFontSize: json["buttonFontSize"],
        buttonWidth: json["buttonWidth"],
        buttonIconSize: json["buttonIconSize"],
        visibilityTime: json["visibilityTime"],
      );

  Map<String, dynamic> toMap() => {
        "headerFontSize": headerFontSize,
        "imageDescriptionFontSize": imageDescriptionFontSize,
        "descriptionFontSize": descriptionFontSize,
        "imageHeight": imageHeight,
        "imageWidth": imageWidth,
        "buttonFontSize": buttonFontSize,
        "buttonWidth": buttonWidth,
        "buttonIconSize": buttonIconSize,
        "visibilityTime": visibilityTime,
      };
}

class BottomBar {
  BottomBar({
    this.padding,
    this.navigationButtonSize,
  });

  double? padding;
  double? navigationButtonSize;

  factory BottomBar.fromMap(Map<String, dynamic> json) => BottomBar(
        padding: json["padding"],
        navigationButtonSize: json["navigationButtonSize"],
      );

  Map<String, dynamic> toMap() => {
        "padding": padding,
        "navigationButtonSize": navigationButtonSize,
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
        fontSize: json["fontSize"],
        textFieldWidth: json["textFieldWidth"],
      );

  Map<String, dynamic> toMap() => {
        "fontSize": fontSize,
        "textFieldWidth": textFieldWidth,
      };
}

class Logo {
  Logo({
    this.fontSize,
    this.bannerHeight,
    this.logoHeight,
    this.logoWidth,
  });

  double? fontSize;
  double? bannerHeight;
  double? logoHeight;
  double? logoWidth;

  factory Logo.fromMap(Map<String, dynamic> json) => Logo(
        fontSize: json["fontSize"],
        bannerHeight: json["bannerHeight"],
        logoHeight: json["logoHeight"],
        logoWidth: json["logoWidth"],
      );

  Map<String, dynamic> toMap() => {
        "fontSize": fontSize,
        "bannerHeight": bannerHeight,
        "logoHeight": logoHeight,
        "logoWidth": logoWidth
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
        choiceContainerWidth: json["choiceContainerWidth"],
        choiceContainerHeight: json["choiceContainerHeight"],
        fontSize: json["fontSize"],
        circularFontContainerSize: json["circularFontContainerSize"],
        otherOptionTextFieldHeight: json["otherOptionTextFieldHeight"],
        otherOptionTextFieldWidth: json["otherOptionTextFieldWidth"],
        otherOptionTextFontSize: json["otherOptionTextFontSize"],
      );

  Map<String, dynamic> toMap() => {
        "choiceContainerWidth": choiceContainerWidth,
        "choiceContainerHeight": choiceContainerHeight,
        "fontSize": fontSize,
        "circularFontContainerSize": circularFontContainerSize,
        "otherOptionTextFieldHeight": otherOptionTextFieldHeight,
        "otherOptionTextFieldWidth": otherOptionTextFieldWidth,
        "otherOptionTextFontSize": otherOptionTextFontSize,
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
    this.runSpacing,
    this.positionedLabelTopValue,
  });

  double? outerBlockSizeWidth;
  double? outerBlockSizeHeight;
  double? innerBlockSizeWidth;
  double? innerBlockSizeHeight;
  double? labelFontSize;
  double? numberFontSize;
  double? runSpacing;
  double? positionedLabelTopValue;

  factory OpnionScale.fromMap(Map<String, dynamic> json) => OpnionScale(
        outerBlockSizeWidth: json["outerBlockSizeWidth"],
        outerBlockSizeHeight: json["outerBlockSizeHeight"],
        innerBlockSizeWidth: json["innerBlockSizeWidth"],
        innerBlockSizeHeight: json["innerBlockSizeHeight"],
        labelFontSize: json["labelFontSize"],
        numberFontSize: json["numberFontSize"],
        runSpacing: json["runSpacing"],
        positionedLabelTopValue: json["positionedLabelTopValue"],
      );

  Map<String, dynamic> toMap() => {
        "outerBlockSizeWidth": outerBlockSizeWidth,
        "outerBlockSizeHeight": outerBlockSizeHeight,
        "innerBlockSizeWidth": innerBlockSizeWidth,
        "innerBlockSizeHeight": innerBlockSizeHeight,
        "labelFontSize": labelFontSize,
        "numberFontSize": numberFontSize,
        "runSpacing": runSpacing,
        "positionedLabelTopValue": positionedLabelTopValue
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
        defaultNumber: json["defaultNumber"],
        fontSize: json["fontSize"],
        countryPickerWidth: json["countryPickerWidth"],
        countryPickerHeight: json["countryPickerHeight"],
        countryCodeInputWidth: json["countryCodeInputWidth"],
        countryCodeInputHeight: json["countryCodeInputHeight"],
        countryCodeNumberInputHeight: json["countryCodeNumberInputHeight"],
        countryCodeNumberInputWidth: json["countryCodeNumberInputWidth"],
      );

  Map<String, dynamic> toMap() => {
        "defaultNumber": defaultNumber,
        "fontSize": fontSize,
        "countryPickerWidth": countryPickerWidth,
        "countryPickerHeight": countryPickerHeight,
        "countryCodeInputWidth": countryCodeInputWidth,
        "countryCodeInputHeight": countryCodeInputHeight,
        "countryCodeNumberInputHeight": countryCodeNumberInputHeight,
        "countryCodeNumberInputWidth": countryCodeNumberInputWidth,
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
        questionNumberFontSize: json["questionNumberFontSize"],
        questionHeadingFontSize: json["questionHeadingFontSize"],
        questionDescriptionFontSize: json["questionDescriptionFontSize"],
      );

  Map<String, dynamic> toMap() => {
        "questionNumberFontSize": questionNumberFontSize,
        "questionHeadingFontSize": questionHeadingFontSize,
        "questionDescriptionFontSize": questionDescriptionFontSize,
      };
}

class SkipButton {
  SkipButton({
    this.fontSize,
  });

  double? fontSize;

  factory SkipButton.fromMap(Map<String, dynamic> json) => SkipButton(
        fontSize: json["fontSize"],
      );

  Map<String, dynamic> toMap() => {
        "fontSize": fontSize,
      };
}

class NextButton {
  NextButton({
    this.fontSize,
    this.width,
    this.iconSize,
  });

  double? fontSize;
  double? width;
  double? iconSize;

  factory NextButton.fromMap(Map<String, dynamic> json) => NextButton(
        fontSize: json["fontSize"],
        width: json["width"],
        iconSize: json["iconSize"],
      );

  Map<String, dynamic> toMap() => {
        "fontSize": fontSize,
        "width": width,
        "iconSize": iconSize,
      };
}

class Rating {
  Rating({
    this.hasNumber,
    this.customRatingSvgUnselected,
    this.customRatingSvgSelected,
    this.svgHeight,
    this.svgWidth,
  });

  bool? hasNumber;
  String? customRatingSvgUnselected;
  String? customRatingSvgSelected;
  double? svgHeight;
  double? svgWidth;

  factory Rating.fromMap(Map<String, dynamic> json) => Rating(
        hasNumber: json["hasNumber"],
        customRatingSvgUnselected: json["customRatingSVGUnselected"],
        customRatingSvgSelected: json["customRatingSVGSelected"],
        svgHeight: json["svgHeight"],
        svgWidth: json["svgWidth"],
      );

  Map<String, dynamic> toMap() => {
        "hasNumber": hasNumber,
        "customRatingSVGUnselected": customRatingSvgUnselected,
        "customRatingSVGSelected": customRatingSvgSelected,
        "svgHeight": svgHeight,
        "svgWidth": svgWidth,
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
    this.customSvgSelected,
    this.customSvgUnSelected,
  });

  double? svgWidth;
  double? svgHeight;
  double? outerContainerWidth;
  double? outerContainerHeight;
  double? fontSize;
  double? circleFontIndicatorSize;
  String? customSvgSelected;
  String? customSvgUnSelected;

  factory YesOrNo.fromMap(Map<String, dynamic> json) => YesOrNo(
        svgWidth: json["svgWidth"],
        svgHeight: json["svgHeight"],
        outerContainerWidth: json["outerContainerWidth"],
        outerContainerHeight: json["outerContainerHeight"],
        fontSize: json["fontSize"],
        circleFontIndicatorSize: json["circleFontIndicatorSize"],
        customSvgSelected: json["customSvgSelected"],
        customSvgUnSelected: json["customSvgUnSelected"],
      );

  Map<String, dynamic> toMap() => {
        "svgWidth": svgWidth,
        "svgHeight": svgHeight,
        "outerContainerWidth": outerContainerWidth,
        "outerContainerHeight": outerContainerHeight,
        "fontSize": fontSize,
        "circleFontIndicatorSize": circleFontIndicatorSize,
        "customSvgSelected": customSvgSelected,
        "customSvgUnSelected": customSvgUnSelected,
      };
}
