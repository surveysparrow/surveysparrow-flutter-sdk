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

  const WelcomePage(
      {Key? key,
      required this.setPageType,
      required this.theme,
      required this.welcomePageData,
      required this.welcomeDesc,
      required this.welcomeButtonDesc,
      required this.welcomeEntity,
      this.euiTheme,
      })
      : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double luminanceValue = 0.5;
  var imageSrc = null;
  var customFont = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.widget.euiTheme != null){
      if(this.widget.euiTheme!['font'] != null ){
        customFont = this.widget.euiTheme!['font'];
      }
    }

    if (this.widget.welcomeEntity != null &&
        this.widget.welcomeEntity['0'] != null &&
         this.widget.welcomeEntity['0']['type'] != null &&
        this.widget.welcomeEntity['0']['type'] == 'IMAGE') {
      imageSrc = this.widget.welcomeEntity['0']['data']['src'];
    }
    luminanceValue = this.widget.theme['ctaButtonColor'].computeLuminance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            this.widget.welcomePageData['blocks'][0]['text'],
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: this.widget.theme['questionColor'],
              fontFamily: customFont
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (imageSrc != null) ...[
            Container(
              height: 150.sp,
              width: 200.sp,
              child: Image(
                image: NetworkImage(
                    imageSrc),
              ),
            ),
          ],
          SizedBox(
            height: 10,
          ),
          Text(
            this.widget.welcomePageData['blocks'] != null &&
                    this.widget.welcomePageData['blocks'].length >= 2 &&
                    this.widget.welcomePageData['blocks'][2]['text'] != null
                ? this.widget.welcomePageData['blocks'][2]['text']
                : '',
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: this.widget.theme['questionColor'],
              fontFamily: customFont
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(this.widget.welcomeDesc,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: this.widget.theme['questionDescriptionColor'],
                fontFamily: customFont
              )),
          SizedBox(
            height: 10,
          ),
          Opacity(
            opacity: 1,
            child: ElevatedButton(
              onPressed: () async {
                this.widget.setPageType("questions");
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
                width: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      this.widget.welcomeButtonDesc == "builder.welcome_yes_proceed" ? "Sure,ask." : this.widget.welcomeButtonDesc,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
