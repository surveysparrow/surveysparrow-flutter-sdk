import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';
import 'package:url_launcher/link.dart';
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
    // TODO: implement initState
    super.initState();
    try{
          if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['thankYouPage'] != null) {
        if (this.widget.euiTheme!['thankYouPage']['headerFontSize'] != null) {
          headerFontSize =
              this.widget.euiTheme!['thankYouPage']['headerFontSize'];
        }
        if (this.widget.euiTheme!['thankYouPage']['imageDescriptionFontSize'] !=
            null) {
          imageDescriptionFontSize =
              this.widget.euiTheme!['thankYouPage']['imageDescriptionFontSize'];
        }
        if (this.widget.euiTheme!['thankYouPage']['descriptionFontSize'] !=
            null) {
          descriptionFontSize =
              this.widget.euiTheme!['thankYouPage']['descriptionFontSize'];
        }
        if (this.widget.euiTheme!['thankYouPage']['imageHeight'] != null) {
          imageHeight = this.widget.euiTheme!['thankYouPage']['imageHeight'];
        }
        if (this.widget.euiTheme!['thankYouPage']['imageWidth'] != null) {
          imageWidth = this.widget.euiTheme!['thankYouPage']['imageWidth'];
        }
        if (this.widget.euiTheme!['thankYouPage']['buttonFontSize'] != null) {
          buttonFontSize =
              this.widget.euiTheme!['thankYouPage']['buttonFontSize'];
        }
        if (this.widget.euiTheme!['thankYouPage']['buttonWidth'] != null) {
          buttonWidth = this.widget.euiTheme!['thankYouPage']['buttonWidth'];
        }
        if (this.widget.euiTheme!['thankYouPage']['buttonIconSize'] != null) {
          buttonIconSize =
              this.widget.euiTheme!['thankYouPage']['buttonIconSize'];
        }
        if (this.widget.euiTheme!['thankYouPage']['visibilityTime'] != null) {
          visibilityTime =
              this.widget.euiTheme!['thankYouPage']['visibilityTime'];
        }
      }
    }

    if (this.widget.euiTheme != null) {
      if (this.widget.euiTheme!['font'] != null) {
        customFont = this.widget.euiTheme!['font'];
      }
    }

    if (this.widget.thankYouPageJson['redirectBoolean'] != null) {
      hasRedirection = this.widget.thankYouPageJson['redirectBoolean'];
      redirectUrl = this.widget.thankYouPageJson['redirect'];
    }

    if (this.widget.thankYouPageJson['branding'] != null) {
      showBranding = this.widget.thankYouPageJson['branding'];
    }

    if (this.widget.thankYouPageJson['button'] != null) {
      if (this.widget.thankYouPageJson['button']['enabled'] == true) {
        hasThankYouButton = true;
        if (this.widget.thankYouPageJson['button']['url'] != null) {
          thankYouButtonUrl = this.widget.thankYouPageJson['button']['url'];
        }
        if (this.widget.thankYouPageJson['button']['buttonInfo'] != null) {
          thankYouButtonText =
              this.widget.thankYouPageJson['button']['buttonInfo'];
        }
      }
    }

    if (this.widget.thankYouPageJson['message'] != null &&
        this.widget.thankYouPageJson['message']['blocks'] != null &&
        this.widget.thankYouPageJson['message']['blocks'].length > 0) {
      thankYouPageheading =
          this.widget.thankYouPageJson['message']['blocks'][0]['text'];
      if (this.widget.thankYouPageJson['message']['blocks'].length >= 2) {
        thankYouPageDescritpion =
            this.widget.thankYouPageJson['message']['blocks'][2]['text'];
      }
    }

    if (this.widget.thankYouPageJson['description'] != null &&
        this.widget.thankYouPageJson['description']['blocks'] != null &&
        this.widget.thankYouPageJson['description']['blocks'].length > 0) {
      thanYouPageBottomDescritpion =
          this.widget.thankYouPageJson['description']['blocks'][0]['text'];
    }

    if (this.widget.thankYouPageJson['message'] != null &&
        this.widget.thankYouPageJson['message']['entityMap'] != null &&
        this.widget.thankYouPageJson['message']['entityMap']['0'] != null &&
        this.widget.thankYouPageJson['message']['entityMap']['0']['data'] !=
            null &&
        this.widget.thankYouPageJson['message']['entityMap']['0']['data']
                ['src'] !=
            null) {
      hasImage = true;
      imageSrc = this.widget.thankYouPageJson['message']['entityMap']['0']
          ['data']['src'];
    }

    luminanceValue = this.widget.theme['ctaButtonColor'].computeLuminance();

    if (hasRedirection) {
      this.widget.closeModalFunction!();
      _launchInBrowser(redirectUrl);
    } else {
      Future.delayed(Duration(milliseconds: visibilityTime), () {
        widget.closeModalFunction!();
      });
    }
    }catch(e){
      this.widget.onError!(e);
      throw Exception("Thank Page Data not configured properly ${e}");
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
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              thankYouPageheading,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: headerFontSize,
                fontWeight: FontWeight.w400,
                color: this.widget.theme['questionColor'],
                fontFamily: customFont,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (hasImage) ...[
            Container(
              height: imageHeight,
              width: imageWidth,
              child: Image(
                fit: BoxFit.contain,
                image: NetworkImage(imageSrc),
              ),
            ),
          ],
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              thankYouPageDescritpion,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: imageDescriptionFontSize,
                fontWeight: FontWeight.w500,
                color: this.widget.theme['questionColor'],
                fontFamily: customFont,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(thanYouPageBottomDescritpion,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: descriptionFontSize,
                  fontWeight: FontWeight.w400,
                  color: this.widget.theme['questionDescriptionColor'],
                  fontFamily: customFont,
                )),
          ),

          if (hasThankYouButton) ...[
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                this.widget.setPageType("questions");
                final Uri url = Uri.parse(thankYouButtonUrl);
                _launchInBrowser(thankYouButtonUrl);
                // this.widget.closeModalFunction!();
              },
              style: this.widget.theme['buttonStyle'] == "filled"
                  ? ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: this.widget.theme['ctaButtonColor'],
                      padding: EdgeInsets.all(10),
                      shape: StadiumBorder(),
                    )
                  : ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Color(0x00000000),
                      padding: EdgeInsets.all(10),
                      shape: StadiumBorder(),
                      side: BorderSide(
                          color: this.widget.theme['ctaButtonColor']),
                    ),
              child: Container(
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
                        color: this.widget.theme['buttonStyle'] == "filled"
                            ? luminanceValue > 0.5
                                ? Colors.black
                                : Colors.white
                            : this.widget.theme['ctaButtonColor'],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: this.widget.theme['buttonStyle'] == "filled"
                          ? luminanceValue > 0.5
                              ? Colors.black
                              : Colors.white
                          : this.widget.theme['ctaButtonColor'],
                      size: buttonIconSize,
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(
            height: 10,
          ),
          if (showBranding) ...[
            Container(
              width: 120,
              height: 65,
              child: SvgPicture.string(
                    getFooterSvg(this.widget.theme['questionString'] == "rgba(63, 63, 63,0.5)" ? '#4A9CA6' : this.widget.theme['questionString']),
              ),
            ),
          ],
          // Container(
          //     width: 120, height: 65, child: SvgPicture.string(footerSVG)),
        ],
      ),
    );
  }
}
