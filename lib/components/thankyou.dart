import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ThankYouPage extends StatefulWidget {
  final Function setPageType;
  final Function? closeModalFunction;
  final Function? onError;
  final Map<dynamic, dynamic> theme;
  final Map<dynamic, dynamic> thankYouPageData;
  final dynamic welcomeDesc;
  final dynamic welcomeButtonDesc;
  final Map<dynamic, dynamic> welcomeEntity;
  final Map<dynamic, dynamic> thankYouPageJson;
  final Map<dynamic, dynamic>? euiTheme;

  const ThankYouPage({
    Key? key,
    required this.setPageType,
    required this.theme,
    required this.thankYouPageData,
    required this.welcomeDesc,
    required this.welcomeButtonDesc,
    required this.welcomeEntity,
    required this.thankYouPageJson,
    this.closeModalFunction,
    this.onError,
    this.euiTheme,
  }) : super(key: key);

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  double luminanceValue = 0.5;

  var thankYouPageheading = "";
  var thankYouPageDescritpion = "";
  var thanYouPageBottomDescritpion = "";

  var hasImage = false;
  var imageSrc = "";

  var hasThankYouButton = false;
  var thankYouButtonUrl = "https://surveysparrow.com/";
  var thankYouButtonText = "thank you";

  var showBranding = true;

  var hasRedirection = false;
  var redirectUrl = "";

  var customFont = null;

  var headerFontSize = 28.0;
  var imageDescriptionFontSize = 20.0;
  var descriptionFontSize = 14.0;
  var imageHeight = 150.sp;
  var imageWidth = 200.sp;
  var buttonFontSize = 14.0;
  var buttonWidth = 110.0;
  var buttonIconSize = 22.0;
  var visibilityTime = 2000;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.euiTheme != null) {
        if (widget.euiTheme!['thankYouPage'] != null) {
          if (widget.euiTheme!['thankYouPage']['headerFontSize'] != null) {
            headerFontSize = widget.euiTheme!['thankYouPage']['headerFontSize'];
          }
          if (widget.euiTheme!['thankYouPage']['imageDescriptionFontSize'] !=
              null) {
            imageDescriptionFontSize =
                widget.euiTheme!['thankYouPage']['imageDescriptionFontSize'];
          }
          if (widget.euiTheme!['thankYouPage']['descriptionFontSize'] != null) {
            descriptionFontSize =
                widget.euiTheme!['thankYouPage']['descriptionFontSize'];
          }
          if (widget.euiTheme!['thankYouPage']['imageHeight'] != null) {
            imageHeight = widget.euiTheme!['thankYouPage']['imageHeight'];
          }
          if (widget.euiTheme!['thankYouPage']['imageWidth'] != null) {
            imageWidth = widget.euiTheme!['thankYouPage']['imageWidth'];
          }
          if (widget.euiTheme!['thankYouPage']['buttonFontSize'] != null) {
            buttonFontSize = widget.euiTheme!['thankYouPage']['buttonFontSize'];
          }
          if (widget.euiTheme!['thankYouPage']['buttonWidth'] != null) {
            buttonWidth = widget.euiTheme!['thankYouPage']['buttonWidth'];
          }
          if (widget.euiTheme!['thankYouPage']['buttonIconSize'] != null) {
            buttonIconSize = widget.euiTheme!['thankYouPage']['buttonIconSize'];
          }
          if (widget.euiTheme!['thankYouPage']['visibilityTime'] != null) {
            visibilityTime = widget.euiTheme!['thankYouPage']['visibilityTime'];
          }
        }
      }

      if (widget.euiTheme != null) {
        if (widget.euiTheme!['font'] != null) {
          customFont = widget.euiTheme!['font'];
        }
      }

      if (widget.thankYouPageJson['redirectBoolean'] != null) {
        hasRedirection = widget.thankYouPageJson['redirectBoolean'];
        redirectUrl = widget.thankYouPageJson['redirect'];
      }

      if (widget.thankYouPageJson['branding'] != null) {
        showBranding = widget.thankYouPageJson['branding'];
      }

      if (widget.thankYouPageJson['button'] != null) {
        if (widget.thankYouPageJson['button']['enabled'] == true) {
          hasThankYouButton = true;
          if (widget.thankYouPageJson['button']['url'] != null) {
            thankYouButtonUrl = widget.thankYouPageJson['button']['url'];
          }
          if (widget.thankYouPageJson['button']['buttonInfo'] != null) {
            thankYouButtonText =
                widget.thankYouPageJson['button']['buttonInfo'];
          }
        }
      }

      if (widget.thankYouPageJson['message'] != null &&
          widget.thankYouPageJson['message']['blocks'] != null &&
          widget.thankYouPageJson['message']['blocks'].length > 0) {
        thankYouPageheading =
            widget.thankYouPageJson['message']['blocks'][0]['text'];
        if (widget.thankYouPageJson['message']['blocks'].length >= 2) {
          thankYouPageDescritpion =
              widget.thankYouPageJson['message']['blocks'][2]['text'];
        }
      }

      if (widget.thankYouPageJson['description'] != null &&
          widget.thankYouPageJson['description']['blocks'] != null &&
          widget.thankYouPageJson['description']['blocks'].length > 0) {
        thanYouPageBottomDescritpion =
            widget.thankYouPageJson['description']['blocks'][0]['text'];
      }

      if (widget.thankYouPageJson['message'] != null &&
          widget.thankYouPageJson['message']['entityMap'] != null &&
          widget.thankYouPageJson['message']['entityMap']['0'] != null &&
          widget.thankYouPageJson['message']['entityMap']['0']['data'] !=
              null &&
          widget.thankYouPageJson['message']['entityMap']['0']['data']['src'] !=
              null) {
        hasImage = true;
        imageSrc =
            widget.thankYouPageJson['message']['entityMap']['0']['data']['src'];
      }

      luminanceValue = widget.theme['ctaButtonColor'].computeLuminance();

      if (hasRedirection) {
        widget.closeModalFunction!();
        _launchInBrowser(redirectUrl);
      } else {
        Future.delayed(Duration(milliseconds: visibilityTime), () {
          widget.closeModalFunction!();
        });
      }
    } catch (e) {
      widget.onError!(e);
      throw Exception("Thank Page Data not configured properly $e");
    }
  }

  Future<void> _launchInBrowser(url) async {
    Uri myUri = Uri.parse(url);
    if (!await launchUrl(
      myUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $myUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            thankYouPageheading,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: headerFontSize,
              fontWeight: FontWeight.w400,
              color: widget.theme['questionColor'],
              fontFamily: customFont,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (hasImage) ...[
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
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            thankYouPageDescritpion,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: imageDescriptionFontSize,
              fontWeight: FontWeight.w500,
              color: widget.theme['questionColor'],
              fontFamily: customFont,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(thanYouPageBottomDescritpion,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: descriptionFontSize,
                fontWeight: FontWeight.w400,
                color: widget.theme['questionDescriptionColor'],
                fontFamily: customFont,
              )),
        ),

        if (hasThankYouButton) ...[
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              widget.setPageType("questions");
              _launchInBrowser(thankYouButtonUrl);
              // this.widget.closeModalFunction!();
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
                    thankYouButtonText,
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
        ],

        const SizedBox(
          height: 10,
        ),
        if (showBranding) ...[
          SizedBox(
            width: 120,
            height: 65,
            child: SvgPicture.string(
              getFooterSvg(
                  widget.theme['questionString'] == "rgba(63, 63, 63,0.5)"
                      ? '#4A9CA6'
                      : widget.theme['questionString']),
            ),
          ),
        ],
        // Container(
        //     width: 120, height: 65, child: SvgPicture.string(footerSVG)),
      ],
    );
  }
}
