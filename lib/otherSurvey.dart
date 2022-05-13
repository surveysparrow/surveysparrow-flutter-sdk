import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:surveysparrow_flutter_sdk/helpers/answers.dart';

import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';

class FullPage3 extends StatelessWidget {
  const FullPage3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: ((context) => Container(
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
    createAnswerPayloadOtherSurvey(
        1246, newChoices, 'MultiChoice', surveyAns, false, 1);
    print("nn-90 new choice is ${newChoices} ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate Your Order: Fipola"),
                SizedBox(height: 5),
                RatingStars(
                  value: value,
                  onValueChanged: (v) {
                    print("new rating is ${v}");
                    createAnswerPayloadOtherSurvey(
                        1245, v.toInt(), 'Rating', surveyAns, false, 1);
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
                  animationDuration: Duration(milliseconds: 1000),
                  valueLabelPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  valueLabelMargin: const EdgeInsets.only(right: 8),
                  starOffColor: const Color(0xffe7e8ea),
                  starColor: Colors.yellow,
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Divider(
            color: Colors.grey,
            indent: 10,
            endIndent: 10,
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("What Did you like"),
                SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  direction: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4389);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4389)
                              ? Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [Text("Product Quality",style: TextStyle(color:selectedChoice.contains(4389) ? Colors.white : Colors.black),), Icon(Icons.check, color: selectedChoice.contains(4389) ? Colors.white : Colors.black,)],
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4390);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4390)
                              ? Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [Text("Packaging",style: TextStyle(color:selectedChoice.contains(4390) ? Colors.white : Colors.black),), Icon(Icons.check, color: selectedChoice.contains(4390) ? Colors.white : Colors.black,)],
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleSelectedChoice(4391);
                      },
                      child: Container(
                        height: 40,
                        width: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: selectedChoice.contains(4391)
                              ? Color.fromRGBO(252, 128, 25, 1.0)
                              : Colors.white,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [Text("Product Prices",style: TextStyle(color:selectedChoice.contains(4391) ? Colors.white : Colors.black),), Icon(Icons.check, color: selectedChoice.contains(4391) ? Colors.white : Colors.black,)],
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.black,
            indent: 10,
            endIndent: 10,
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate Delivery by: N Nagaraj"),
                SizedBox(height: 5),
                RatingStars(
                  value: value2,
                  onValueChanged: (v) {
                    print("new rating is ${v}");
                    createAnswerPayloadOtherSurvey(
                        1247, v.toInt(), 'Rating', surveyAns, false, 1);
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
                  animationDuration: Duration(milliseconds: 1000),
                  valueLabelPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  valueLabelMargin: const EdgeInsets.only(right: 8),
                  starOffColor: const Color(0xffe7e8ea),
                  starColor: Colors.yellow,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.black,
            indent: 10,
            endIndent: 10,
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 390,
                    child: TextField(
                      onChanged: (text) {
                        createAnswerPayloadOtherSurvey(
                            1248, text, 'TextInput', surveyAns, false, 1);
                      },
                      style: TextStyle(color: Colors.black),
                      cursorColor: Color.fromRGBO(252, 128, 25, 1.0),
                      decoration: InputDecoration(
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
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  submitAnswerOtherSurvey('tt-e7297f', surveyAns);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Enter Delivery Rating")),
          )
        ],
      ),
    );
  }
}
