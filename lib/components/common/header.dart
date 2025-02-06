import 'package:flutter/material.dart';

class HeaderSection extends StatefulWidget {
  final Map<dynamic, dynamic>? euiTheme;
  final Map<dynamic, dynamic>? theme;

  const HeaderSection({Key? key, this.euiTheme, required this.theme})
      : super(key: key);

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final Function? onClickNext;
  final Function? onClickPrevious;
  var isVertical = false;

  var showPadding = true;

  var navigationButtonSize = 42.0;
  var brandingLogoHeight = 30.0;
  var brandingLogoWidth = 155.0;

  var luminanceValue = 0.5;

  var bannerHeight = 60.0;
  var fontSize = 14.0;
  var logoHeight = 120.0;
  var logoWidth = 120.0;

  dynamic customFont;

  @override
  void initState() {
    super.initState();

    luminanceValue = widget.theme!['backgroundColor'].computeLuminance();

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }
    }

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['logo'] != null) {
        if (widget.euiTheme!['logo']['bannerHeight'] != null) {
          bannerHeight = widget.euiTheme!['logo']['bannerHeight'];
        }

        if (widget.euiTheme!['logo']['fontSize'] != null) {
          fontSize = widget.euiTheme!['logo']['fontSize'];
        }

        if (widget.euiTheme!['logo']['logoHeight'] != null) {
          logoHeight = widget.euiTheme!['logo']['logoHeight'];
        }

        if (widget.euiTheme!['logo']['logoWidth'] != null) {
          logoWidth = widget.euiTheme!['logo']['logoWidth'];
        }
      }
    }
  }

  _HeaderSectionState({this.onClickNext, this.onClickPrevious});
  @override
  Widget build(BuildContext context) {
    var textWidget = Text(widget.theme!['headerText'],
        style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: luminanceValue > 0.5 ? Colors.black : Colors.white,
            fontFamily: customFont));

    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 6,
              color: Color.fromRGBO(38, 38, 39, 0.12))
        ],
        color: widget.theme!['backgroundColor'],
      ),
      height: bannerHeight,
      width: double.maxFinite,
      child: Center(
        child: widget.theme!['headerLogoUrl'] == "none"
            ? textWidget
            : Container(
                height: logoHeight,
                width: logoWidth,
                margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Image.network(
                  widget.theme!['headerLogoUrl'],
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
