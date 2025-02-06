import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/components/common/questionColumn.dart';
import 'package:surveysparrow_flutter_sdk/components/common/skipAndNext.dart';
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
        func: func,
        answer: answer,
        question: question,
        theme: theme,
        customParams: customParams,
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
    if (answer[question['id']] != null) {
      var phoneCode =
          answer['${question['id']}_phone'].split(' ')[0].substring(1);
      var number = answer[question['id']];
      handleCountryCodeSubmit(phoneCode);
      hanldePhoneNumberInital(number);
    }
  }

  handlePhoneNumberSubmit(phoneNumber) {
    setState(() {
      _phoneNumber = phoneNumber;
    });
  }

  hanldePhoneNumberInital(phoneNumber) {
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
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(
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
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: Text(
                country.name,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
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
          currentQuestionNumber: currentQuestionNumber,
          customParams: customParams,
          theme: theme,
          euiTheme: widget.euiTheme,
        ),
        PhoneQuestion(
          func: func,
          answer: answer,
          question: question,
          handlePhoneNumberSubmit: handlePhoneNumberSubmit,
          handleCountryCodeSubmit: handleCountryCodeSubmit,
          hanldePhoneNumberInital: hanldePhoneNumberInital,
          theme: theme,
          erroredInput: erroredInput,
          euiTheme: widget.euiTheme,
        ),
        const SizedBox(height: 40),
        SkipAndNextButtons(
          key: UniqueKey(),
          showNext: true,
          disabled: widget.isLastQuestion
              ? question['required']
                  ? (_phoneNumber == null || _phoneNumber == '')
                  : false
              : (_phoneNumber == null || _phoneNumber == ''),
          showSkip:
              (question['required'] || widget.isLastQuestion) ? false : true,
          showSubmit: isLastQuestion == true ? true : false,
          onClickNext: () {
            if (_phoneNumber == null || _phoneNumber == '') {
              if (widget.isLastQuestion && !question['required']) {
                widget.submitData();
              }
              setState(() {
                erroredInput = true;
              });
              return;
            }
            FocusScope.of(context).requestFocus(FocusNode());
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
              func(_phoneNumber, question['id'],
                  isPhoneInput: true,
                  phoneValue: "+$_countryCode $_phoneNumber");
              if (isLastQuestion) {
                widget.submitData();
              }
            }
          },
          onClickSkip: () {
            func(null, question['id']);
            if (isLastQuestion) {
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(context).pop();
              });
            }
          },
          theme: theme,
          euiTheme: widget.euiTheme,
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
  final Function hanldePhoneNumberInital;
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
    required this.hanldePhoneNumberInital,
    required this.theme,
    required this.erroredInput,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<PhoneQuestion> createState() => _PhoneQuestionState(
        func: func,
        answer: answer,
        question: question,
        handlePhoneNumberSubmit: handlePhoneNumberSubmit,
        handleCountryCodeSubmit: handleCountryCodeSubmit,
        hanldePhoneNumberInital: hanldePhoneNumberInital,
        theme: theme,
        erroredInput: erroredInput,
      );
}

class _PhoneQuestionState extends State<PhoneQuestion> {
  Function func;
  final Map<dynamic, dynamic> answer;
  final Map<dynamic, dynamic> question;
  Function handlePhoneNumberSubmit;
  Function hanldePhoneNumberInital;
  Function handleCountryCodeSubmit;
  final Map<dynamic, dynamic> theme;
  bool erroredInput;
  var initalCountryCode = "91";
  late Country _selectedDialogCountry;

  TextEditingController ContryCodeInputController = TextEditingController();
  TextEditingController PhoneInputController = TextEditingController();

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

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }
    }

    if (widget.euiTheme!['phoneNumber'] != null) {
      if (widget.euiTheme!['phoneNumber']['fontSize'] != null) {
        fontSize = widget.euiTheme!['phoneNumber']['fontSize'];
      }

      if (widget.euiTheme!['phoneNumber']['countryPickerWidth'] != null) {
        countryPickerWidth =
            widget.euiTheme!['phoneNumber']['countryPickerWidth'];
      }
      if (widget.euiTheme!['phoneNumber']['countryPickerHeight'] != null) {
        countryPickerHeight =
            widget.euiTheme!['phoneNumber']['countryPickerHeight'];
      }

      if (widget.euiTheme!['phoneNumber']['countryCodeInputWidth'] != null) {
        countryCodeInputWidth =
            widget.euiTheme!['phoneNumber']['countryCodeInputWidth'];
      }
      if (widget.euiTheme!['phoneNumber']['countryCodeInputHeight'] != null) {
        countryCodeInputHeight =
            widget.euiTheme!['phoneNumber']['countryCodeInputHeight'];
      }

      if (widget.euiTheme!['phoneNumber']['phoneNumberInputHeight'] != null) {
        countryCodeNumberInputHeight =
            widget.euiTheme!['phoneNumber']['phoneNumberInputHeight'];
      }
      if (widget.euiTheme!['phoneNumber']['phoneNumberInputWidth'] != null) {
        countryCodeNumberInputWidth =
            widget.euiTheme!['phoneNumber']['phoneNumberInputWidth'];
      }
    }

    if (answer[question['id']] != null) {
      var phoneCode =
          answer['${question['id']}_phone'].split(' ')[0].substring(1);
      var number = answer[question['id']];
      PhoneInputController.text = number;
      ContryCodeInputController.text = '+$phoneCode';
      _selectedDialogCountry =
          CountryPickerUtils.getCountryByPhoneCode(phoneCode);
      handleCountryCodeSubmit(phoneCode);
      hanldePhoneNumberInital(number);
    } else {
      if (widget.euiTheme != null) {
        if (widget.euiTheme!['phoneNumber'] != null) {
          if (widget.euiTheme!['phoneNumber']['defaultNumber'] != null) {
            ContryCodeInputController.text =
                '+${widget.euiTheme!['phoneNumber']['defaultNumber']}';
            _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode(
                widget.euiTheme!['phoneNumber']['defaultNumber']);
            handleCountryCodeSubmit(
                widget.euiTheme!['phoneNumber']['defaultNumber']);
          } else {
            ContryCodeInputController.text = '+$initalCountryCode';
            _selectedDialogCountry =
                CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
            handleCountryCodeSubmit(initalCountryCode);
          }
        } else {
          ContryCodeInputController.text = '+$initalCountryCode';
          _selectedDialogCountry =
              CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
          handleCountryCodeSubmit(initalCountryCode);
        }
      } else {
        ContryCodeInputController.text = '+$initalCountryCode';
        _selectedDialogCountry =
            CountryPickerUtils.getCountryByPhoneCode(initalCountryCode);
        handleCountryCodeSubmit(initalCountryCode);
      }
    }
  }

  _PhoneQuestionState({
    required this.func,
    required this.answer,
    required this.question,
    required this.handlePhoneNumberSubmit,
    required this.hanldePhoneNumberInital,
    required this.handleCountryCodeSubmit,
    required this.theme,
    required this.erroredInput,
  });

  Widget _buildDialogItemPicker(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          const SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );

  Widget _buildDialogItemPickerPhone(Country country) => Container(
        child: CountryPickerUtils.getDefaultFlagImage(country),
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          searchInputDecoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(fontFamily: customFont)),
          isSearchable: true,
          title: Text(
            'Select your phone code',
            style: TextStyle(fontFamily: customFont),
          ),
          onValuePicked: (Country country) {
            ContryCodeInputController.text = '+${country.phoneCode}';
            setState(() => _selectedDialogCountry = country);
            handleCountryCodeSubmit(country.phoneCode);
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
                  color: theme['decodedOpnionBackgroundColorUnSelected'],
                  // constraints: BoxConstraints(maxWidth: 65),
                  width: countryPickerWidth,
                  height: countryPickerHeight,
                  padding: const EdgeInsets.all(10),
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
                      color: theme['answerColor'], fontSize: fontSize),
                  controller: ContryCodeInputController,
                  cursorColor: theme['answerColor'],
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme['answerColor']),
                    ),
                    hintText: "+1",
                    hintStyle: TextStyle(color: theme['questionNumberColor']),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme['questionDescriptionColor'],
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
                constraints: const BoxConstraints(maxHeight: double.infinity),
                child: TextField(
                  style: TextStyle(
                      color: theme['answerColor'], fontSize: fontSize),
                  cursorColor: theme['answerColor'],
                  controller: PhoneInputController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  onChanged: (e) {
                    handlePhoneNumberSubmit(e);
                  },
                  decoration: InputDecoration(
                    // errorText:"invalid phone number",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme['answerColor']),
                    ),
                    hintText: "Phone Number",
                    hintStyle: TextStyle(
                        color: theme['questionNumberColor'],
                        fontFamily: customFont),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme['questionDescriptionColor'],
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
                const SizedBox(
                  height: 25,
                ),
                const Icon(
                  Icons.info_outline_rounded,
                  size: 11,
                  color: Colors.red,
                ),
                Text(
                  "The phone number isn't valid",
                  style: TextStyle(
                      color: Colors.red, fontSize: 10, fontFamily: customFont),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }
}
