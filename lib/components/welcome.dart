import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WelcomePage extends StatefulWidget {
  final Function setPageType;
  final Map<dynamic, dynamic> theme;
  final Map<dynamic, dynamic> welcomePageData;
  final dynamic welcomeDesc;
  final dynamic welcomeButtonDesc;
  final Map<dynamic, dynamic> welcomeEntity;
  final Map<dynamic, dynamic>? euiTheme;

  const WelcomePage({
    Key? key,
    required this.setPageType,
    required this.theme,
    required this.welcomePageData,
    required this.welcomeDesc,
    required this.welcomeButtonDesc,
    required this.welcomeEntity,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double luminanceValue = 0.5;
  var imageSrc;
  var customFont;

  var headerFontSize = 20.0;
  var imageDescriptionFontSize = 20.0;
  var descriptionFontSize = 14.0;
  var imageHeight = 150.sp;
  var imageWidth = 200.sp;
  var buttonFontSize = 14.0;
  var buttonWidth = 110.0;
  var buttonIconSize = 22.0;

  @override
  void initState() {
    super.initState();
    if (widget.euiTheme != null) {
      if (widget.euiTheme!['welcome'] != null) {
        if (widget.euiTheme!['welcome']['headerFontSize'] != null) {
          headerFontSize = widget.euiTheme!['welcome']['headerFontSize'];
        }
        if (widget.euiTheme!['welcome']['imageDescriptionFontSize'] != null) {
          imageDescriptionFontSize =
              widget.euiTheme!['welcome']['imageDescriptionFontSize'];
        }
        if (widget.euiTheme!['welcome']['descriptionFontSize'] != null) {
          descriptionFontSize =
              widget.euiTheme!['welcome']['descriptionFontSize'];
        }
        if (widget.euiTheme!['welcome']['imageHeight'] != null) {
          imageHeight = widget.euiTheme!['welcome']['imageHeight'];
        }
        if (widget.euiTheme!['welcome']['imageWidth'] != null) {
          imageWidth = widget.euiTheme!['welcome']['imageWidth'];
        }
        if (widget.euiTheme!['welcome']['buttonFontSize'] != null) {
          buttonFontSize = widget.euiTheme!['welcome']['buttonFontSize'];
        }
        if (widget.euiTheme!['welcome']['buttonWidth'] != null) {
          buttonWidth = widget.euiTheme!['welcome']['buttonWidth'];
        }
        if (widget.euiTheme!['welcome']['buttonIconSize'] != null) {
          buttonIconSize = widget.euiTheme!['welcome']['buttonIconSize'];
        }
      }
    }

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }
    }

    if (widget.welcomeEntity['0'] != null &&
        widget.welcomeEntity['0']['type'] != null &&
        widget.welcomeEntity['0']['type'] == 'IMAGE') {
      imageSrc = widget.welcomeEntity['0']['data']['src'];
    }
    luminanceValue = widget.theme['ctaButtonColor'].computeLuminance();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.welcomePageData['blocks'][0]['text'],
          style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: widget.theme['questionColor'],
              fontFamily: customFont),
        ),
        const SizedBox(
          height: 10,
        ),
        if (imageSrc != null) ...[
          SizedBox(
            height: imageHeight,
            width: imageWidth,
            child: Image(
              fit: BoxFit.contain,
              image: NetworkImage(imageSrc),
            ),
          ),
        ],
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            widget.welcomePageData['blocks'] != null &&
                    widget.welcomePageData['blocks'].length >= 2 &&
                    widget.welcomePageData['blocks'][2]['text'] != null
                ? widget.welcomePageData['blocks'][2]['text']
                : '',
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: imageDescriptionFontSize,
                fontWeight: FontWeight.bold,
                color: widget.theme['questionColor'],
                fontFamily: customFont),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(widget.welcomeDesc,
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: descriptionFontSize,
                  fontWeight: FontWeight.w400,
                  color: widget.theme['questionDescriptionColor'],
                  fontFamily: customFont)),
        ),
        const SizedBox(
          height: 10,
        ),
        Opacity(
          opacity: 1,
          child: ElevatedButton(
            onPressed: () async {
              widget.setPageType("questions");
            },
            style: widget.theme['buttonStyle'] == "filled"
                ? ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: widget.theme['ctaButtonColor'],
                    padding: const EdgeInsets.all(10),
                    shape: const StadiumBorder(),
                  )
                : ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0x00000000),
                    padding: const EdgeInsets.all(10),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: widget.theme['ctaButtonColor']),
                  ),
            child: SizedBox(
              width: buttonWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.welcomeButtonDesc == "builder.welcome_yes_proceed"
                        ? "Sure,ask."
                        : widget.welcomeButtonDesc,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: customFont,
                      color: widget.theme['buttonStyle'] == "filled"
                          ? luminanceValue > 0.5
                              ? Colors.black
                              : Colors.white
                          : widget.theme['ctaButtonColor'],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: widget.theme['buttonStyle'] == "filled"
                        ? luminanceValue > 0.5
                            ? Colors.black
                            : Colors.white
                        : widget.theme['ctaButtonColor'],
                    size: buttonIconSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
