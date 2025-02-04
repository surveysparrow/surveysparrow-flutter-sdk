import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';
import 'package:provider/provider.dart';
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

  final _controller = TextEditingController();
  dynamic _text;

  _CXEmailFormState();
  @override
  Widget build(BuildContext context) {
    var survey = context.watch<SurveyProvider>().getSurvey;
    var surveyName = survey['name'] ?? '';

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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  surveyName,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text('from SurveySparrow'),
            ],
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFEDEDED),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
                width: 50,
                height: 50,
                child: Container(
                  child: SvgPicture.string(
                    getLockSVG(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                constraints: const BoxConstraints(maxWidth: 350),
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    if (_text != null) {
                      if (validateEmail(value)) {
                        setState(() {
                          _text = null;
                        });
                      }
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    border: const OutlineInputBorder(),
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
                      icon: const Icon(Icons.arrow_forward_outlined),
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
              getFooterSvg('#4A9CA6'),
            ),
          ),
        ],
      ),
    );
  }
}
