import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/common/skipAndNext.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

class ColumnPhone extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  final bool isLastQuestion;
  final Function submitData;
  final Map<dynamic, dynamic>? euiTheme;

  const ColumnPhone({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
    required this.submitData,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<ColumnPhone> createState() => _ColumnPhoneState(
        func: this.func,
        answer: this.answer,
        question: question,
        theme: this.theme,
        customParams: this.customParams,
        currentQuestionNumber: currentQuestionNumber,
        isLastQuestion: isLastQuestion,
      );
}

class _ColumnPhoneState extends State<ColumnPhone> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Map<dynamic, dynamic> theme;
  final Map<String, String> customParams;
  final int currentQuestionNumber;
  var _countryCode;
  var _phoneNumber;
  bool erroredInput = false;
  final bool isLastQuestion;

  _ColumnPhoneState({
    required this.func,
    required this.answer,
    required this.question,
    required this.theme,
    required this.customParams,
    required this.currentQuestionNumber,
    required this.isLastQuestion,
  });

  @override
  initState() {
    super.initState();
  }

  handlePhoneNumberSubmit(phoneNumber) {
    _phoneNumber = phoneNumber;
  }

  handleCountryCodeSubmit(countryCode) {
    _countryCode = countryCode;
  }

  handleErrorStateChange() {
    setState(() {
      erroredInput = true;
    });
  }

  Widget _buildDropdownItem(Country country) => Container(
        constraints: BoxConstraints(maxWidth: 280),
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 0.0,
            ),
            Text("+${country.phoneCode}"),
          ],
        ),
      );

  Widget _buildDropdownSelectedItemBuilder(Country country) => SizedBox(
      width: 80.0,
      child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: <Widget>[
              CountryPickerUtils.getDefaultFlagImage(country),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: Text(
                '${country.name}',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )),
            ],
          )));
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QuestionColumn(
          question: question,
          currentQuestionNumber: this.currentQuestionNumber,
          customParams: this.customParams,
          theme: this.theme,
          euiTheme: this.widget.euiTheme,
        ),
        PhoneQuestion(
          func: this.func,
          answer: this.answer,
          question: this.question,
          handlePhoneNumberSubmit: this.handlePhoneNumberSubmit,
          handleCountryCodeSubmit: this.handleCountryCodeSubmit,
          theme: this.theme,
          erroredInput: this.erroredInput,
          euiTheme: this.widget.euiTheme,
        ),
        SizedBox(height: 40),
        SkipAndNextButtons(
          key: UniqueKey(),
          showNext: true,
          showSkip: (this.question['required'] || this.widget.isLastQuestion)
              ? false
              : true,
          showSubmit: isLastQuestion == true ? true : false,
          onClickNext: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            final phoneParser =
                PhoneNumber.fromCountryCode(_countryCode, _phoneNumber)
                    .validate();
            if (phoneParser == false) {
              setState(() {
                erroredInput = true;
              });
            } else {
              setState(() {
                erroredInput = false;
              });
              this.func(_phoneNumber, question['id'],
                  isPhoneInput: true,
                  phoneValue: "+${_countryCode} ${_phoneNumber}");
              if (isLastQuestion) {
                this.widget.submitData();
              }
            }
          },
          onClickSkip: () {
            this.func(null, question['id']);
            if (isLastQuestion) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(context).pop();
              });
            }
          },
          theme: theme,
          euiTheme: this.widget.euiTheme,
        )
      ],
    );
  }
}

class PhoneQuestion extends StatefulWidget {
  final Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  final Function handlePhoneNumberSubmit;
  final Function handleCountryCodeSubmit;
  final Map<dynamic, dynamic> theme;
  final Map<dynamic, dynamic>? euiTheme;

  bool erroredInput;
  PhoneQuestion({
    Key? key,
    required this.func,
    required this.answer,
    required this.question,
    required this.handlePhoneNumberSubmit,
    required this.handleCountryCodeSubmit,
    required this.theme,
    required this.erroredInput,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<PhoneQuestion> createState() => _PhoneQuestionState(
        func: this.func,
        answer: this.answer,
        question: this.question,
        handlePhoneNumberSubmit: this.handlePhoneNumberSubmit,
        handleCountryCodeSubmit: this.handleCountryCodeSubmit,
        theme: this.theme,
        erroredInput: this.erroredInput,
      );
}

class _PhoneQuestionState extends State<PhoneQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  Function handlePhoneNumberSubmit;
  Function handleCountryCodeSubmit;
  final Map<dynamic, dynamic> theme;
  bool erroredInput;
  var initalCountryCode = "91";
  late Country _selectedDialogCountry;

  TextEditingController ContryCodeInputController = new TextEditingController();
  TextEditingController PhoneInputController = new TextEditingController();

  double fontSize = 18.0;

  double countryPickerWidth = 14.w;
  double countryPickerHeight = 44.0;

  double countryCodeInputWidth = 13.w;
  double countryCodeInputHeight = 50;

  double countryCodeNumberInputHeight = 50.0;
  double countryCodeNumberInputWidth = 48.w;

  var customFont = null;

  @override
  initState() {
    super.initState();

    _selectedDialogCountry =
        CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);

    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }    
    }

    if (this.widget.euiTheme!['phoneNumber'] != null) {
      if (this.widget.euiTheme!['phoneNumber']['fontSize'] != null) {
        fontSize = this.widget.euiTheme!['phoneNumber']['fontSize'];
      }

      if (this.widget.euiTheme!['phoneNumber']['countryPickerWidth'] != null) {
        countryPickerWidth =
            this.widget.euiTheme!['phoneNumber']['countryPickerWidth'];
      }
      if (this.widget.euiTheme!['phoneNumber']['countryPickerHeight'] != null) {
        countryPickerHeight =
            this.widget.euiTheme!['phoneNumber']['countryPickerHeight'];
      }

      if (this.widget.euiTheme!['phoneNumber']['countryCodeInputWidth'] !=
          null) {
        countryCodeInputWidth =
            this.widget.euiTheme!['phoneNumber']['countryCodeInputWidth'];
      }
      if (this.widget.euiTheme!['phoneNumber']['countryCodeInputHeight'] !=
          null) {
        countryCodeInputHeight =
            this.widget.euiTheme!['phoneNumber']['countryCodeInputHeight'];
      }

      if (this.widget.euiTheme!['phoneNumber']
              ['phoneNumberInputHeight'] !=
          null) {
        countryCodeNumberInputHeight = this.widget.euiTheme!['phoneNumber']
            ['phoneNumberInputHeight'];
      }
      if (this.widget.euiTheme!['phoneNumber']['phoneNumberInputWidth'] !=
          null) {
        countryCodeNumberInputWidth =
            this.widget.euiTheme!['phoneNumber']['phoneNumberInputWidth'];
      }
    }

    if (this.answer[this.question['id']] != null) {
      var phoneCode = this
          .answer['${this.question['id']}_phone']
          .split(' ')[0]
          .substring(1);
      var number = this.answer[this.question['id']];
      PhoneInputController.text = number;
      ContryCodeInputController.text = '+${phoneCode}';
      _selectedDialogCountry =
          CountryPickerUtils.getCountryByPhoneCode(phoneCode);
      this.handleCountryCodeSubmit(phoneCode);
      this.handlePhoneNumberSubmit(number);
    } else {
      if (this.widget.euiTheme != null) {
        if (this.widget.euiTheme!['phoneNumber'] != null) {
          if (this.widget.euiTheme!['phoneNumber']['defaultNumber'] != null) {
            ContryCodeInputController.text =
                '+${this.widget.euiTheme!['phoneNumber']['defaultNumber']}';
            _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode(
                this.widget.euiTheme!['phoneNumber']['defaultNumber']);
            this.handleCountryCodeSubmit(
                this.widget.euiTheme!['phoneNumber']['defaultNumber']);
          } else {
            ContryCodeInputController.text = '+${initalCountryCode}';
            _selectedDialogCountry =
                CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
            this.handleCountryCodeSubmit(initalCountryCode);
          }
        } else {
          ContryCodeInputController.text = '+${initalCountryCode}';
          _selectedDialogCountry =
              CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
          this.handleCountryCodeSubmit(initalCountryCode);
        }
      } else {
        ContryCodeInputController.text = '+${initalCountryCode}';
        _selectedDialogCountry =
            CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
        this.handleCountryCodeSubmit(initalCountryCode);
      }
    }
  }

  _PhoneQuestionState({
    required this.func,
    required this.answer,
    required this.question,
    required this.handlePhoneNumberSubmit,
    required this.handleCountryCodeSubmit,
    required this.theme,
    required this.erroredInput,
  });

  Widget _buildDialogItemPicker(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  Widget _buildDialogItemPickerPhone(Country country) => Container(
        child: CountryPickerUtils.getDefaultFlagImage(country),
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          titlePadding: EdgeInsets.all(8.0),
          searchInputDecoration: InputDecoration(hintText: 'Search...',hintStyle:TextStyle(fontFamily: customFont)),
          isSearchable: true,
          title: Text('Select your phone code',style: TextStyle(fontFamily: customFont),),
          onValuePicked: (Country country) {
            ContryCodeInputController.text = '+${country.phoneCode}';
            setState(() => _selectedDialogCountry = country);
            this.handleCountryCodeSubmit(country.phoneCode);
          },
          itemBuilder: _buildDialogItemPicker,
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _openCountryPickerDialog();
                },
                child: Container(
                  color: this.theme['decodedOpnionBackgroundColorUnSelected'],
                  // constraints: BoxConstraints(maxWidth: 65),
                  width: countryPickerWidth,
                  height: countryPickerHeight,
                  padding: EdgeInsets.all(10),
                  child: _buildDialogItemPickerPhone(_selectedDialogCountry),
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Container(
                width: countryCodeInputWidth,
                height: countryCodeInputHeight,
                child: TextField(
                  readOnly: true,
                  style: TextStyle(
                      color: this.theme['answerColor'], fontSize: fontSize),
                  controller: ContryCodeInputController,
                  cursorColor: this.theme['answerColor'],
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: this.theme['answerColor']),
                    ),
                    hintText: "+1",
                    hintStyle:
                        TextStyle(color: this.theme['questionNumberColor']),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: this.theme['questionDescriptionColor'],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Container(
                height: countryCodeNumberInputHeight,
                width: countryCodeNumberInputWidth,
                constraints: BoxConstraints(maxHeight: double.infinity),
                child: TextField(
                  style: TextStyle(
                      color: this.theme['answerColor'], fontSize: fontSize),
                  cursorColor: this.theme['answerColor'],
                  controller: PhoneInputController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  onChanged: (e) {
                    this.handlePhoneNumberSubmit(e);
                  },
                  decoration: InputDecoration(
                    // errorText:"invalid phone number",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: this.theme['answerColor']),
                    ),
                    hintText: "Phone Number",
                    hintStyle:
                        TextStyle(color: this.theme['questionNumberColor'],fontFamily: customFont),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: this.theme['questionDescriptionColor'],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (widget.erroredInput == true) ...[
                Icon(
                  Icons.info_outline_rounded,
                  size: 11,
                  color: Colors.red,
                ),
                Text(
                  "The phone number isn't valid",
                  style: TextStyle(color: Colors.red, fontSize: 10,fontFamily: customFont),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }
}
