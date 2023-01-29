import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';
import 'package:readmore/readmore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:provider/provider.dart';
import 'package:surveysparrow_flutter_sdk/providers/answer_provider.dart';
import 'package:surveysparrow_flutter_sdk/providers/survey_provider.dart';

class CXEmailForm extends StatefulWidget {
  const CXEmailForm({Key? key}) : super(key: key);

  @override
  State<CXEmailForm> createState() => _CXEmailFormState();
}

class _CXEmailFormState extends State<CXEmailForm> {
  @override
  void initState() {
    super.initState();
  }

  var _controller = TextEditingController();
  var _text = null;

  _CXEmailFormState();
  @override
  Widget build(BuildContext context) {

    var survey = context.watch<SurveyProvider>().getSurvey;
    var surveyName =
        survey != null && survey['name'] != null ? survey['name'] : '';

    validateEmail(value) {
      var validEmail = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value);
      return validEmail;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    surveyName,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('from SurveySparrow'),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFEDEDED),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                width: 50,
                height: 50,
                child: Container(
                  child: SvgPicture.string(
                    getLockSVG(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                constraints: BoxConstraints(maxWidth: 350),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    if(_text != null){
                      if(validateEmail(value)){
                        setState(() {
                            _text = null;
                          });
                      }
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(),
                    errorText: _text,
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (validateEmail(_controller.text)) {
                          context
                              .read<SurveyProvider>()
                              .setEmail(_controller.text);
                        } else {
                          setState(() {
                            _text = "Invalid Email ID";
                          });
                        }
                      },
                      icon: Icon(Icons.arrow_forward_outlined),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 160,
            height: 65,
            child: SvgPicture.string(
              getFooterSvg('rgba(63, 63, 63,0.5)'),
            ),
          ),
        ],
      ),
    );
  }
}
