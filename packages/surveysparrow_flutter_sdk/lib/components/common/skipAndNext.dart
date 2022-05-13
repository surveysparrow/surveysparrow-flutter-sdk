import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SkipAndNextButtons extends StatefulWidget {
  final bool showNext;
  final bool showSkip;
  final bool? showSubmit;
  final Function? onClickNext;
  final Function? onClickSkip;
  final Map<dynamic, dynamic> theme;
  final bool? disabled;
  final Map<dynamic, dynamic>? euiTheme;

  const SkipAndNextButtons({
    Key? key,
    required this.showNext,
    required this.showSkip,
    this.onClickNext,
    this.onClickSkip,
    required this.theme,
    this.showSubmit,
    this.disabled,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<SkipAndNextButtons> createState() => _SkipAndNextButtonsState(
        showNext: this.showNext,
        showSkip: this.showSkip,
        onClickNext: this.onClickNext,
        onClickSkip: this.onClickSkip,
        theme: this.theme,
        showSubmit: showSubmit,
      );
}

class _SkipAndNextButtonsState extends State<SkipAndNextButtons> {
  final bool showNext;
  final bool showSkip;
  final Function? onClickNext;
  final Function? onClickSkip;
  final Map<dynamic, dynamic> theme;
  final bool? showSubmit;
  double luminanceValue = 0.5;

  _SkipAndNextButtonsState({
    required this.showNext,
    required this.showSkip,
    this.onClickNext,
    this.onClickSkip,
    required this.theme,
    this.showSubmit,
  });

  var customFont = null;

  var skipButtonFontSize = 12.0;

  var nextButtonFontSize = 14.0; 
  var nextButtonWidth = 100.0; 
  var nextButtonIconSize = 22.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(this.widget.euiTheme != null){
      print("q-eui-theme ${this.widget.euiTheme} ");
      if(this.widget.euiTheme!['font'] != null){
        customFont = this.widget.euiTheme!['font'];
      }

      if(this.widget.euiTheme!['skipButton'] != null){
        if(this.widget.euiTheme!['skipButton']['fontSize'] != null ){
          skipButtonFontSize = this.widget.euiTheme!['skipButton']['fontSize'];
        }
      }

      if(this.widget.euiTheme!['nextButton'] != null){
        if(this.widget.euiTheme!['nextButton']['fontSize'] != null ){
          nextButtonFontSize = this.widget.euiTheme!['nextButton']['fontSize'];
        }

        if(this.widget.euiTheme!['nextButton']['width'] != null ){
          nextButtonWidth = this.widget.euiTheme!['nextButton']['width'];
        }

        if(this.widget.euiTheme!['nextButton']['iconSize'] != null ){
          nextButtonIconSize = this.widget.euiTheme!['nextButton']['iconSize'];
        }
        
      }
    }

    print(
        "cta button disabled ${this.theme['buttonStyle']} ${this.theme['ctaButtonDisabledColor']}");
    luminanceValue = this.theme['ctaButtonColor'].computeLuminance();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (this.widget.showNext) ...[
          Opacity(
            opacity:
                this.widget.disabled != null && this.widget.disabled! == true
                    ? 0.4
                    : 1,
            child: ElevatedButton(
              onPressed: () async {
                if (onClickNext != null) {
                  onClickNext!();
                }
              },

              style: this.theme['buttonStyle'] == "filled"
                  ? ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: theme['ctaButtonColor'],
                      padding: EdgeInsets.all(10),
                      shape: StadiumBorder(),
                    )
                  : ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Color(0x00000000),
                      padding: EdgeInsets.all(10),
                      shape: StadiumBorder(),
                      side: BorderSide(color: theme['ctaButtonColor']),
                    ),
              child: Container(
                width: nextButtonWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      (this.showSubmit != null && this.showSubmit == true)
                          ? "SUBMIT"
                          : "NEXT",
                      style: TextStyle(
                        fontFamily: customFont,
                        decoration: TextDecoration.none,
                        fontSize: nextButtonFontSize,
                        fontWeight: FontWeight.bold,
                        color: this.theme['buttonStyle'] == "filled" ?
                            luminanceValue > 0.5 ? Colors.black : Colors.white : theme['ctaButtonColor'],
                      ),
                    ),
                    Icon(
                      (this.showSubmit != null && this.showSubmit == true)
                          ? Icons.check_rounded
                          : Icons.keyboard_arrow_right,
                      color: this.theme['buttonStyle'] == "filled" ?
                            luminanceValue > 0.5 ? Colors.black : Colors.white : theme['ctaButtonColor'],
                      size: nextButtonIconSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
        if (showSkip) ...[
          GestureDetector(
            onTap: () {
              if (onClickSkip != null) {
                onClickSkip!();
              }
            },
            child: Container(
              // width: double.infinity,
              child: Text(
                'SKIP',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: customFont,
                  decoration: TextDecoration.none,
                  fontSize: skipButtonFontSize,
                  fontWeight: FontWeight.bold,
                  color: theme['questionNumberColor'],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
