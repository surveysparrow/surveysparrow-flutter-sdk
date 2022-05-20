import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';

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

  @override
  void initState() {
    super.initState();

    luminanceValue = this.widget.theme!['backgroundColor'].computeLuminance();

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['bottomSheet'] != null) {
        if (widget.euiTheme!['bottomSheet']['showPadding'] != null) {
          showPadding = widget.euiTheme!['bottomSheet']['showPadding'];
        }
        if (widget.euiTheme!['bottomSheet']['direction'] != null) {
          if (widget.euiTheme!['bottomSheet']['direction'] == "horizontal") {
            isVertical = true;
          }
        }
        if (widget.euiTheme!['bottomSheet']['navigationButtonSize'] != null) {
          navigationButtonSize =
              widget.euiTheme!['bottomSheet']['navigationButtonSize'];
        }
      }
    }
  }

  _HeaderSectionState({this.onClickNext, this.onClickPrevious});
  @override
  Widget build(BuildContext context) {
    var bottomPadding = window.viewPadding.bottom;
    var textWidget = Text(this.widget.theme!['headerText'],
        style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: luminanceValue > 0.5 ? Colors.black : Colors.white,
        )
        // fontFamily: customFont),
        );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 6,
              color: Color.fromRGBO(38, 38, 39, 0.12))
        ],
        color: this.widget.theme!['backgroundColor'],
      ),
      height: 60,
      width: double.maxFinite,
      child: Center(
        child: this.widget.theme!['headerLogoUrl'] == "none"
            ? textWidget
            : Container(
              height: 120,
              width: 120,
                margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Image.network(this.widget.theme!['headerLogoUrl'],fit: BoxFit.contain,),
              ),
      ),
    );
  }
}
