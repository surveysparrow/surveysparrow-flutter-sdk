import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class FullPage3 extends StatelessWidget {
  const FullPage3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: ((context) => const SizedBox(
            width: double.infinity, height: double.infinity, child: Page3())),
      ),
    );
  }
}

class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  double value = 0.0;
  double value2 = 0.0;
  final List<Map<dynamic, dynamic>> surveyAns = [];
  var selectedChoice = [];

  handleSelectedChoice(val) {
    var newChoices = [...selectedChoice];
    if (selectedChoice.contains(val)) {
      newChoices.removeWhere((element) => element == val);
    } else {
      newChoices.add(val);
    }
    setState(() {
      selectedChoice = newChoices;
    });
    var multipleObj = CustomMultiChoice(
        data: newChoices, skipped: false, timeTaken: 2, key: 1656);
    createAnswerPayloadOtherSurvey(multipleObj, surveyAns);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rate Your Order: Fipola"),
                const SizedBox(height: 5),
                RatingStars(
                  value: value,
                  onValueChanged: (v) {
                    var ratingObj = CustomRating(
                        data: v.toInt(),
                        skipped: false,
                        timeTaken: 1,
                        key: 1655);
                    createAnswerPayloadOtherSurvey(ratingObj, surveyAns);
                    setState(() {
                      value = v;
                    });
                  },
                  starBuilder: (index, color) => Icon(
                    Icons.star,
                    color: color,
                    size: 40,
                  ),
                  starCount: 5,
                  starSize: 40,
                  valueLabelColor: const Color(0xff9b9b9b),
                  valueLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0),
                  valueLabelRadius: 10,
                  maxValue: 5,
                  starSpacing: 2,
                  maxValueVisibility: false,
                  valueLabelVisibility: false,
                  animationDuration: const Duration(milliseconds: 1000),
                  valueLabelPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  valueLabelMargin: const EdgeInsets.only(right: 8),
                  starOffColor: const Color(0xffe7e8ea),
                  starColor: Colors.yellow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What Did you like"),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4651);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4651)
                              ? const Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Product Quality",
                              style: TextStyle(
                                  color: selectedChoice.contains(4651)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            Icon(
                              Icons.check,
                              color: selectedChoice.contains(4651)
                                  ? Colors.white
                                  : Colors.black,
                            )
                          ],
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4652);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4652)
                              ? const Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Packaging",
                              style: TextStyle(
                                  color: selectedChoice.contains(4652)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            Icon(
                              Icons.check,
                              color: selectedChoice.contains(4652)
                                  ? Colors.white
                                  : Colors.black,
                            )
                          ],
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4653);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4653)
                              ? const Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Product Prices",
                              style: TextStyle(
                                  color: selectedChoice.contains(4653)
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            Icon(
                              Icons.check,
                              color: selectedChoice.contains(4653)
                                  ? Colors.white
                                  : Colors.black,
                            )
                          ],
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.black,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rate Delivery by: N Nagaraj"),
                const SizedBox(height: 5),
                RatingStars(
                  value: value2,
                  onValueChanged: (v) {
                    var ratingObj = CustomRating(
                        data: v.toInt(),
                        skipped: false,
                        timeTaken: 1,
                        key: 1657);
                    createAnswerPayloadOtherSurvey(ratingObj, surveyAns);
                    setState(() {
                      value2 = v;
                    });
                  },
                  starBuilder: (index, color) => Icon(
                    Icons.star,
                    color: color,
                    size: 40,
                  ),
                  starCount: 5,
                  starSize: 40,
                  valueLabelColor: const Color(0xff9b9b9b),
                  valueLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0),
                  valueLabelRadius: 10,
                  maxValue: 5,
                  starSpacing: 2,
                  maxValueVisibility: false,
                  valueLabelVisibility: false,
                  animationDuration: const Duration(milliseconds: 1000),
                  valueLabelPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  valueLabelMargin: const EdgeInsets.only(right: 8),
                  starOffColor: const Color(0xffe7e8ea),
                  starColor: Colors.yellow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.black,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 390,
                    child: TextField(
                      onChanged: (text) {
                        var textObj = CustomTextInput(
                            data: text,
                            skipped: false,
                            timeTaken: 1,
                            key: 1658);
                        createAnswerPayloadOtherSurvey(textObj, surveyAns);
                      },
                      style: const TextStyle(color: Colors.black),
                      cursorColor: const Color.fromRGBO(252, 128, 25, 1.0),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: "Got any other suggestions? Let us know...",
                        hintStyle: TextStyle(color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  submitAnswerOtherSurvey('sample.surveysparrow.test','tt-3a462d', surveyAns);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Enter Delivery Rating")),
          )
        ],
      ),
    );
  }
}
