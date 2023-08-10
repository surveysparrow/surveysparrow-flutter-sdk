SurveySparrow's flutter SDK lets you collect feedback at various touchpoints from your mobile app users. You can easily embed surveys in your mobile app with a few lines of code. This documentation walks you through the possibilities of the SDK before you begin integrating the mobile SDK with your app.
# How it works?
You can install the SDK on Xcode or Android Studio and configure when you want to invoke the survey. Based on those conditions, you will be able to call the survey when a particular condition is met. For instance, let’s say your app lets people book a cab (like Uber or Lyft). You may want to display feedback surveys at after a trip is complete. You can easily do that with our SDK. 
# Steps to get started with the SDK
* Create a free account on [Build better experiences, the right way | SurveySparrow](https://surveysparrow.com/) and build a sample classic survey. You can also use our templates to get started easily. Please note that only these question types are supported for the flutter SDK: Opinion Scale, Text, Rating, Welcome page, Thank you page, Yes or No, Multiple Choice, Phone Number, Email.
* After building the survey, navigate to the “Share“ window. Click on “Mobile SDK“ and copy the access token. You will need this access token to call the survey.
* Copy the URL of your account (*.surveysparrow.com) and keep it handy.
# Supported versions
* Android minSdkVersion >= 21
* IOS version >= 11.0
# Installation:
To install the SDK, simply run this command:
```dart
$ flutter pub add surveysparrow_flutter_sdk
```
# Getting started
Check SurveySparrow Flutter Sdk documentation for in-depth instructions on configuring and customization 
SurveySparrow Flutter Sdk can be used in two ways either you can use the in-built survey modal for collecting the feedback or you can use your own UI and use the helper functions to collect and submit responses

# Examples
### Example 1
```dart
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
 
class SurveyScreen extends StatelessWidget {
 const SurveyScreen({
   Key? key,
 }) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("SurveySparrow"),
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Builder(
       builder: ((context) => Container(
             width: double.infinity,
             height: double.infinity,
             child: SurveyModal(
               token: 'tt-0daa18',
               domain: 'sachin.officesparrow.com',
               onNext: (val) {
                 print("Currently collected answer ${val} ");
               },
               onError: () {
                 Navigator.pop(context);
               },
               onSubmit: (val) {
                 print("All collected answer ${val} ");
                 Future.delayed(const Duration(milliseconds: 500), () {
                   Navigator.pop(context);
                 });
               },
             ),
           )),
     ),
   );
 }
}
```
### Example 2 (Advanced Customization)
```dart
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
 
class SurveyScreen extends StatelessWidget {
 const SurveyScreen({
   Key? key,
 }) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text("SurveySparrow"),
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: Builder(
       builder: ((context) => Container(
             width: double.infinity,
             height: double.infinity,
             child: SurveyModal(
               token: 'tt-0daa18',
               domain: 'sachin.officesparrow.com',
               variables: const {
                 "custom_name": "surveysparrow",
                 "custom_number": "2"
               },
               firstQuestionAnswer: FirstQuestionAnswer(
                 pageNumber: 1, // number of pages to skip when the user takes the survey
                 answers: [
                   Answer(
                     opnionScale: CustomOpinionScale(
                       key: 22864,
                       data: 3,
                       timeTaken: 1,
                       skipped: false,
                     ),
                   ),
                   Answer(
                     rating: CustomRating(
                       key: 22865,
                       data: 3,
                       timeTaken: 1,
                       skipped: false,
                     ),
                   ),
                   Answer(
                     multipleChoice : CustomMultiChoice(
                       key: 22866,
                       data: [20862, 20864],
                       timeTaken: 1,
                       skipped: false,
                     ),
                   )
                 ],
               ),
               customSurveyTheme: CustomSurveyTheme(
                 question: Question(
                     questionNumberFontSize: 20.0,
                     questionHeadingFontSize: 30.0,
                     questionDescriptionFontSize: 20.0),
                 logo: Logo(fontSize: 20.0),
                 bottomBar: BottomBar(navigationButtonSize: 50.0),
                 nextButton:
                     NextButton(fontSize: 20.0, width: 120.0, iconSize: 30.0),
                 email: Email(fontSize: 30.0),
                 skipButton: SkipButton(fontSize: 20.0),
                 rating: Rating(
                   svgHeight: 80,
                   svgWidth: 80,
                   customRatingSvgUnselected:
                       '<svg width="23" height="22" viewBox="0 0 23 22" fill="none" xmlns="http://www.w3.org/2000/svg"><path clip-rule="evenodd" d="m11.5 17.5-5.878 3.09 1.123-6.545L1.989 9.41l6.572-.955L11.5 2.5l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545L11.5 17.5Z" stroke="#007AFF" stroke-width="1.5"/></svg>',
                   customRatingSvgSelected:
                       '<svg width="23" height="21" viewBox="0 0 23 21" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="m11.5 16.5-5.878 3.09 1.123-6.545L1.989 8.41l6.572-.955L11.5 1.5l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545L11.5 16.5Z" fill="#007AFF" stroke="#007AFF"/></svg>',
                 ),
                 yesOrNo: YesOrNo(
                     outerContainerHeight: 200.0,
                     outerContainerWidth: 180.0,
                     svgHeight: 70.0,
                     svgWidth: 70.0,
                     fontSize: 20.0,
                     circleFontIndicatorSize: 30.0),
                 phoneNumber: PhoneNumber(
                     countryPickerWidth: 100.0,
                     countryPickerHeight: 80.0,
                     fontSize: 28.0),
                 opinionScale: OpinionScale(
                   labelFontSize: 20,
                   numberFontSize: 18,
                   runSpacing: 28.0,
                 ),
                 welcome: WelcomePageTheme(
                   headerFontSize: 30.0,
                   imageDescriptionFontSize: 25.0,
                   descriptionFontSize: 30.0,
                   imageHeight: 350,
                   imageWidth: 550,
                   buttonFontSize: 30.0,
                   buttonWidth: 500.0,
                   buttonIconSize: 44.0,
                 ),
                 thankYouPage: ThankYouPageTheme(
                   headerFontSize: 30.0,
                   imageDescriptionFontSize: 25.0,
                   descriptionFontSize: 30.0,
                   imageHeight: 550,
                   imageWidth: 650,
                   buttonFontSize: 30.0,
                   buttonWidth: 500.0,
                   buttonIconSize: 44.0,
                   visibilityTime: 5000,
                 ),
               ),
               onNext: (val) {
                 print("Currently collected answer ${val} ");
               },
               onError: () {
                 Navigator.pop(context);
               },
               onSubmit: (val) {
                 print("All collected answer ${val} ");
                 Future.delayed(const Duration(milliseconds: 500), () {
                   Navigator.pop(context);
                 });
               },
             ),
           )),
     ),
   );
 }
}
```
### Example 3 (Preloading survey and using it)
```dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
 
Future<Map<dynamic, dynamic>> fetchSurvey() async {
 var domain = "sachin.officesparrow.com"; // use your domain
 var token = "tt-0daa18"; // use your mobile sdk share token
 
 var url = 'https://${domain}/api/internal/sdk/get-survey/${token}';
 
 final response = await http.get(Uri.parse(url));
 if (response.statusCode == 200) {
   // If the server did return a 200 OK response,
   // then parse the JSON.
   final parsedJson = jsonDecode(response.body);
   return parsedJson;
 } else {
   // If the server did not return a 200 OK response,
   // then throw an exception.
   throw Exception('Failed to load survey');
 }
}
 
class PreLoadedSurveyScreen extends StatelessWidget {
 const PreLoadedSurveyScreen({
   Key? key,
 }) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("SurveySparrow"),
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: FutureBuilder(
       future: fetchSurvey(),
       builder: (BuildContext context, AsyncSnapshot snapshot) {
         if (snapshot.hasData) {
           return Container(
             width: double.infinity,
             height: double.infinity,
             child: SurveyModal(
               token: 'tt-0daa18',
               domain: 'sachin.officesparrow.com',
               variables: const {
                 "custom_name": "surveysparrow",
                 "custom_number": "2"
               },
               survey: snapshot.data,
               onNext: (val) {
                 print("Currently collected answer ${val} ");
               },
               onError: () {
                 Navigator.pop(context);
               },
               onSubmit: (val) {
                 print("All collected answer ${val} ");
                 Future.delayed(const Duration(milliseconds: 500), () {
                   Navigator.pop(context);
                 });
               },
             ),
           );
         } else {
           return Container(
             child: const Text("Loading"),
           );
         }
       },
     ),
   );
 }
}
```
# Handle Survey Validation

Use the below snippet in any component which requires a survey validation before popping up

```dart
import 'package:surveysparrow_flutter_sdk/helpers/survey.dart';

late Future<Map<dynamic, dynamic>> surveyValidation =
    handleSurveyValidation(this.token, this.domain);
  // response will be 
```



# Customizations For SurveyModal
You can also customize the appearance of each question type with these functions:

Question font customizations:
```dart
question questionNumberFontSize(double)
 DESC -> question number font size 

questionHeadingFontSize(double)
 DESC -> question header font size 

questionDescriptionFontSize(double)
 DESC -> question description font size
```
Skip button customizations:
```dart
 fontSize(double)
 DESC -> skip button font size 
```
Animation Direction customizations:
```dart
 animationDirection(String)
 DESC -> animation direction of question value can be horizontal or vertical
```
Bottom Bar customizations:
```dart
 padding(double)
 DESC -> bottom bar padding

 navigationButtonSize(double)
 DESC -> bottom bar navigation button size
```
Next button customizations:
```dart
 fontSize(double)
 DESC ->  the font size that appears inside the button 

 width(double)
 DESC -> width of the next button

 iconSize(double)
 DESC -> icon size that is displayed in next button
```
Logo customization:
```dart
  bannerHeight(double)
  DESC -> banner height that is displayed for showing the logo
 
  fontSize(double)
  DESC -> fontsize of the logo name

  logoHeight(double)
  DESC -> logo height of the logo in banner

  logoWidth(double)
  DESC -> logo width of the logo in banner
```
Rating question type customizations:
```dart
  hasNumber(bool)
  DESC -> can be used to toggle the number that is shown below rating
 
  svgHeight(double)
  DESC -> height of the rating svg

  svgWidth(double)
  DESC -> width of the rating svg

  customRatingSVGUnselected(double)
  DESC -> custom unselected svg to display instead of default surveysparrow svg

  customRatingSVGSelected(double)
  DESC -> custom selected svg to display instead of default surveysparrow svg
```
Opinion scale question type customizations:
```dart
 outerBlockWidth(double)
 DESC -> opnionScale outer block width

 outerBlockHeight(double)
 DESC -> opnionScale outer block height

 innerBlockWidth(double)
 DESC -> opnionScale inner block width

 innerBlockHeight(double)
 DESC -> opnionScale inner block height

 labelFontSize(double)
 DESC -> the font size of most Likely, least Likely labels

 numberFontSize(double)
 DESC -> the font size of number inside the block

 runSpacing(double)
 DESC -> run spacing for the blocks

 positionedLabelTopValue(double)
 DESC -> labels top value offset
```
Yes or no question type customizations: 
```dart
 svgHeight(double)
 DESC ->  yesOrNo svg icon height

 svgWidth(double)
 DESC ->  yesOrNo svg icon width

 customSVGUnselected( String )
 DESC -> custom unselected svg to display instead of default surveysparrow svg

 customSVGSelected( String )
 DESC -> custom selected svg to display instead of default surveysparrow svg

 outerContainerWidth ( double )
 DESC -> outer container size of yes or no question card

 outerContainerHeight ( double )
 DESC -> outer container height of yes or no question card

 circularFontIndicatorSize ( double )
 DESC -> circle Font Indicator Size size of yes or no

 fontSize(double)
 DESC -> font size used
```
Text and Email question type customizations: 
```dart
 fontSize(double)
 DESC -> font size of input

 textFieldWidth(double)
 DESC -> width of text field
```
Multiple choice question type customizations: 
```dart 
 choiceContainerWidth( String)
 DESC -> choice Container Width to be set

 choiceContainerHeight( String)
 DESC -> choice Container Height to be set

 fontSize(Double)
 DESC -> font size of choice text

 circularFontContainerSize(Double)
 DESC -> circular Font Container Size of choice bar

 otherOptionTextFieldHeight( String)
 DESC -> other Option Text Field Height to be set

 otherOptionTextFieldWidth( String)
 DESC -> other Option TextField Width to be set
 
 otherOptionTextFontSize( String)
 DESC -> other Option Text Font Size to be set
```
Phone number question type customizations:
```dart
 defaultcountryCode( String)
 DESC -> default country code to be set

 fontSize(Double)
 DESC -> font size of input fields

 countryPickerWidth(double)
 DESC -> width of country Picker Width

 countryPickerHeight(double)
 DESC -> height of country Picker Height

 countryCodeInputWidth(double)
 DESC -> width of country CodeInput Width

 countryCodeInputHeight(double)
 DESC -> height of country CodeInput Height

 phoneNumberInputWidth(double)
 DESC -> width of country CodeNumber Input Width

 phoneNumberInputHeight(double)
 DESC -> height of country Code Number Input Height
```
Welcome Page customizations:
```dart
headerFontSize(double)
DESC -> welcome page header font size

imageDescriptionFontSize(double)
DESC -> welcome page image description font size

descriptionFontSize(double)
DESC -> welcome page description font size

imageHeight(double)
DESC -> welcome page image height

imageWidth(double)
DESC -> welcome page image width

buttonFontSize(double)
DESC -> welcome page button font size

buttonWidth(double)
DESC -> welcome page buttonWidth

buttonIconSize(double)
DESC -> welcome page buttonIconSize

```
ThankYou Page customizations:
```dart
headerFontSize(double)
DESC -> thank you page header font size

imageDescriptionFontSize(double)
DESC -> thank you page image description font size

descriptionFontSize(double)
DESC -> thank you page description font size

imageHeight(double)
DESC -> thank you page image height

imageWidth(double)
DESC -> thank you page image width

buttonFontSize(double)
DESC -> thank you page button font size

buttonWidth(double)
DESC -> thank you page buttonWidth

buttonIconSize(double)
DESC -> thank you page buttonIconSize

visibilityTime(int)
DESC -> how long the thank you page should be visible

```
# Event listeners:
| Listener name | Description |
| ----------- | ----------- |
| onError | callback function will get fired when there’s an error. Example: Wrong survey type, wrong SDK token, wrong domain name, error while fetching survey data |
| onNext | callback function will get fired when user answers current question and moves to the next question |
| onSubmit | callback function will get fired after user completes the survey |

# Using SurveySparrow Flutter SDK Helper functions for collecting feedback from a custom Survey UI:
Responses can be collected from a custom survey ui using the createAnswerPayloadCustomSurvey and submitCustomSurvey functions
## Collecting The Response
Example:
```dart
// pass the same surveyObj array to all the createAnswerPayloadCustomSurvey function calls , all the answers should be collected as a single array of map for submission
var surveyObj = [];
 
// rating question
var ratingObj = CustomRating(data:4, skipped: false, timeTaken: 1, key: 1245);
createAnswerPayloadOtherSurvey(ratingObj, surveyObj);
 
// text question
var textObj = CustomTextInput(skipped: false, data: "some input", timeTaken: 1, key: 1234);
createAnswerPayloadOtherSurvey(textObj, surveyObj);
 
// multiple choice questions
var multipleChoiceObj = CustomMultiChoice(data: [1,2,3], skipped: false, timeTaken: 3, key: 1289);
createAnswerPayloadOtherSurvey(multipleChoiceObj, surveyObj);
 
// yesno
var yesOrNoObj = CustomYesNo(key: 123,skipped: false,data: true,timeTaken:4);
createAnswerPayloadOtherSurvey(yesOrNoObj, surveyObj);
 
//email
var emailObj = CustomEmailInput(skipped: false, data: "abc@gmail.com", timeTaken: 2, key: 2908);
createAnswerPayloadOtherSurvey(emailObj, surveyObj);
 
// opnionScale
var opnionScaleObj = CustomOpinionScale(key: 1908,skipped: false,data: 2,timeTaken: 3);
createAnswerPayloadOtherSurvey(opnionScaleObj, surveyObj);
 
//phone number
var phoneNumberObj = CustomPhoneNumber(skipped: true, data: "+91 8976546789", timeTaken: 2, key: 1289);
createAnswerPayloadOtherSurvey(phoneNumberObj, surveyObj);

```

## Submitting the response
Example:
```dart
token = “tt-3d4efc”
domain = “sample.surveysparrow.com”
submitCustomSurvey(domain,token,surveyObj);
```
