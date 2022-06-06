import 'dart:ffi';

import 'package:flutter/material.dart';

class SurveyThemeData {
  final Color questionColor;
  final Color questionDescriptionColor;
  final Color questionNumberColor;
  final Color answerColor;
  final Color backgroundColor;
  final String backgroundImage;
  final Color decodedOpnionBackgroundColorSelected;
  final Color decodedOpnionBackgroundColorUnSelected;
  final Color decodedOpnionBorderColor;
  final Color decodedOpnionLabelColor;
  final Color backgroundImageColor;
  final double backgroundImageColorOpacity;
  final Color ctaButtonColor;
  final String ratingRgba;
  final String ratingRgbaBorder;
  final Color ctaButtonDisabledColor;
  final bool showRequired;
  final String buttonStyle;
  final bool showBranding;
  final String questionString;
  final bool hasGradient;
  final List gradientColors;
  final bool showQuestionNumber;
  final bool showProgressBar;
  final bool hasHeader;
  final String headerText;
  final String headerLogoUrl;
  final bool hasFooter;
  final String footerText;

  SurveyThemeData(
    this.questionColor,
    this.questionDescriptionColor,
    this.questionNumberColor,
    this.answerColor,
    this.backgroundColor,
    this.backgroundImage,
    this.decodedOpnionBackgroundColorSelected,
    this.decodedOpnionBackgroundColorUnSelected,
    this.decodedOpnionBorderColor,
    this.decodedOpnionLabelColor,
    this.backgroundImageColor,
    this.backgroundImageColorOpacity,
    this.ctaButtonColor,
    this.ratingRgba,
    this.ratingRgbaBorder,
    this.ctaButtonDisabledColor,
    this.showRequired,
    this.buttonStyle,
    this.showBranding,
    this.questionString,
    this.hasGradient,
    this.gradientColors,
    this.showQuestionNumber,
    this.showProgressBar,
    this.hasHeader,
    this.headerText,
    this.headerLogoUrl,
    this.hasFooter,
    this.footerText,
  );

  factory SurveyThemeData.fromJson({Map<String, dynamic> json = const {}}) {
    convertRgbStringToColor(String colorToConvert, opacity) {
      if (colorToConvert.contains("#")) {
        String color = colorToConvert.replaceAll('#', '0xff');
        return Color(int.parse(color));
      }
      var convertedString = colorToConvert
          .substring(4, colorToConvert.length - 1)
          .replaceAll(RegExp(' +'), ' ')
          .split(',');
      if (convertedString.length < 3) {
        return Color.fromRGBO(255, 255, 255, opacity);
      }
      return Color.fromRGBO(
          int.parse(convertedString[0]),
          int.parse(convertedString[1]),
          int.parse(convertedString[2]),
          opacity);
    }

    getBackgroundImageOpacity(brightness) {
      int absoluteNumber = brightness.abs();
      if (absoluteNumber == 0) {
        return 1.0;
      } else {
        int numberToConvert = (absoluteNumber - 100).abs();
        double doubleVar = numberToConvert / 100;
        return doubleVar;
      }
    }

    getBackgroundImageColor(brightness) {
      if (brightness < 0) {
        return Colors.black;
      }
      return Colors.white;
    }

    getRatingBorderColor(color) {
      var newString = color.replaceAll(")", ", 0.1)").replaceAll('rgb', 'rgba');
      return newString;
    }

    getGradientColors(id) {
      switch (id) {
        case 1:
          return [Color(0xffD31027), Color(0xffEA384D)];
        case 2:
          return [Color(0xff8E2DE2), Color(0xff4A00E0)];
        case 3:
          return [Color(0xff3f51b5), Color(0xff283593)];
        case 4:
          return [Color(0xff396afc2), Color(0xff396afc)];
        case 5:
          return [Color(0xff0ba360), Color(0xff3cba92)];
        case 6:
          return [Color(0xff070d58), Color(0xff000000)];
        case 7:
          return [Color(0xffeb3349), Color(0xfff45c43)];
        case 8:
          return [Color(0xffcc2b5e), Color(0xff753a88)];
        case 9:
          return [Color(0xff606c88), Color(0xff3f4c6b)];
        case 10:
          return [Color(0xff000000), Color(0xff434343)];
        case 11:
          return [Color(0xffd7a2f9), Color(0xfff0d8ff)];
        case 12:
          return [Color(0xfff4dc89), Color(0xfffcf3d3)];
        case 13:
          return [Color(0xffffa2a6), Color(0xffffd1c4)];
        case 14:
          return [Color(0xff757F9A), Color(0xff757F9A)];
        case 16:
          return [Color(0xffffccf3), Color(0xffffb7ba)];
        default:
          return [Color(0xffD31027), Color(0xffEA384D)];
      }
    }
    var backGroundImage = json['properties'] != null &&
            json['properties']['backgroundImage'] != null &&
            json['properties']['backgroundImage']['url'] != null
        ? json['properties']['backgroundImage']['url']
        : 'noImage';
    // Question Color Settings
    var decodedQuestionColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['questions'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['questions'], 1.0)
        : Color.fromRGBO(57, 57, 57, 1.0);

    var decodedQuestionDescriptionColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['questions'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['questions'], 0.7)
        : Color.fromRGBO(57, 57, 57, 0.7);

    var decodedQuestionNumberColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['questions'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['questions'], 0.5)
        : Color.fromRGBO(57, 57, 57, 0.5);

    // Answer Theme
    var decodedAnswerColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['answers'], 1.0)
        : Color.fromRGBO(63, 63, 63, 1.0);

    // Opnion Scale Theme
    var decodedOpnionBackgroundColorSelected = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['answers'], 0.8)
        : Color.fromRGBO(63, 63, 63, 0.8);

    var decodedOpnionBackgroundColorUnSelected = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['answers'], 0.1)
        : Color.fromRGBO(63, 63, 63, 0.1);

    var decodedOpnionBorderColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['answers'], 0.5)
        : Color.fromRGBO(63, 63, 63, 0.5);

    var decodedOpnionLabelColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['answers'], 0.8)
        : Color.fromRGBO(63, 63, 63, 0.8);

    var decodedBackgroundColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['backgroundColor'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['backgroundColor'], 1.0)
        : Color.fromRGBO(255, 255, 255, 1.0);

    var decodedBackgroundImageColor = json['properties'] != null &&
            json['properties']['backgroundImage'] != null &&
            json['properties']['backgroundImage']['brightness'] != null
        ? getBackgroundImageColor(
            json['properties']['backgroundImage']['brightness'])
        : Color.fromRGBO(255, 255, 255, 1.0);

    var decodedBackgroundImageColorOpacity = json['properties'] != null &&
            json['properties']['backgroundImage'] != null &&
            json['properties']['backgroundImage']['brightness'] != null
        ? getBackgroundImageOpacity(
            json['properties']['backgroundImage']['brightness'])
        : 1.0;

    var ctaButtonDecodedColor = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['ctaButton'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['ctaButton'], 1.0)
        : Color.fromRGBO(4, 191, 116, 1.0);

    var ctaButtonDecodedColorDisabled = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['ctaButton'] != null
        ? convertRgbStringToColor(
            json['properties']['colors']['overrides']['ctaButton'], 0.5)
        : Color.fromRGBO(4, 191, 116, 0.5);

    var decodedRatingRgba = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? json['properties']['colors']['overrides']['answers']
        : "rgba(63, 63, 63,1)";

    var decodedRatingRgbaBorder = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['answers'] != null
        ? getRatingBorderColor(
            json['properties']['colors']['overrides']['answers'])
        : "rgba(63, 63, 63,0.5)";

    var decodedShowRequired = json['properties'] != null &&
            json['properties']['mandatoryIndicator'] != null
        ? json['properties']['mandatoryIndicator']
        : true;

    var decodedButtonStyle = json['properties'] != null &&
            json['properties']['buttons'] != null &&
            json['properties']['buttons']['fillStyle'] != null
        ? json['properties']['buttons']['fillStyle']
        : 'filled';

    var decodedShowBranding = json['properties'] != null &&
            json['properties']['branding'] != null &&
            json['properties']['branding']['type'] == "removeBadge"
        ? false
        : true;

    var decodedQuestionColorString = json['properties'] != null &&
            json['properties']['colors'] != null &&
            json['properties']['colors']['overrides'] != null &&
            json['properties']['colors']['overrides']['questions'] != null
        ? json['properties']['colors']['overrides']['questions']
        : "rgba(63, 63, 63,0.5)";

    var decodedHasGradient = json['properties'] != null &&
            json['properties']['backgroundType'] != null &&
            json['properties']['backgroundType'] == "Gradient"
        ? true
        : false;

    var decodedGradientColors = json['properties'] != null &&
            json['properties']['backgroundGradientId'] != null
        ? getGradientColors(json['properties']['backgroundGradientId'])
        : [Color(0xffD31027), Color(0xffEA384D)];

    var decodedShowQuestionNumber = json['properties'] != null &&
            json['properties']['showQuestionNumber'] != null
        ? json['properties']['showQuestionNumber']
        : true;

    var decodedShowProgressBar =
        json['properties'] != null && json['properties']['progressBar'] != null
            ? json['properties']['progressBar']
            : true;

    var decodedHasHeader = json['properties'] != null &&
            json['properties']['header'] != null &&
            json['properties']['header']['visible'] != null
        ? json['properties']['header']['visible']
        : false;

    var decodedHeaderText = json['properties'] != null &&
            json['properties']['header'] != null &&
            json['properties']['header']['title'] != null
        ? json['properties']['header']['title']
        : "none";

    var decodedHeaderImgSrc = json['properties'] != null &&
            json['properties']['header'] != null &&
            json['properties']['header']['logoUrl'] != null && json['properties']['header']['logoUrl'] != ''
        ? json['properties']['header']['logoUrl']
        : "none";

    var decodedHasFooter = json['properties'] != null &&
            json['properties']['footer'] != null &&
            json['properties']['footer']['visible'] != null
        ? json['properties']['footer']['visible']
        : false;

    var decodedFooterText = json['properties'] != null &&
            json['properties']['footer'] != null &&
            json['properties']['footer']['title'] != null &&
            json['properties']['footer']['title'] != '' &&
            json['properties']['footer']['title']['blocks'] !=null && 
            json['properties']['footer']['title']['blocks'][0] !=null &&
            json['properties']['footer']['title']['blocks'][0]['text'] !=null
        ? json['properties']['footer']['title']['blocks'][0]['text']
        : "";

    return SurveyThemeData(
      decodedQuestionColor,
      decodedQuestionDescriptionColor,
      decodedQuestionNumberColor,
      decodedAnswerColor,
      decodedBackgroundColor,
      backGroundImage,
      decodedOpnionBackgroundColorSelected,
      decodedOpnionBackgroundColorUnSelected,
      decodedOpnionBorderColor,
      decodedOpnionLabelColor,
      decodedBackgroundImageColor,
      decodedBackgroundImageColorOpacity,
      ctaButtonDecodedColor,
      decodedRatingRgba,
      decodedRatingRgbaBorder,
      ctaButtonDecodedColorDisabled,
      decodedShowRequired,
      decodedButtonStyle,
      decodedShowBranding,
      decodedQuestionColorString,
      decodedHasGradient,
      decodedGradientColors,
      decodedShowQuestionNumber,
      decodedShowProgressBar,
      decodedHasHeader,
      decodedHeaderText,
      decodedHeaderImgSrc,
      decodedHasFooter,
      decodedFooterText,
    );
  }
}
