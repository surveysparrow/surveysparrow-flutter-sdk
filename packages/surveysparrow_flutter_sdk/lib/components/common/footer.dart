import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';
import 'package:readmore/readmore.dart';
import 'package:expandable_text/expandable_text.dart';

class FooterSection extends StatefulWidget {
  final Map<dynamic, dynamic>? euiTheme;
  final Map<dynamic, dynamic>? theme;

  const FooterSection({Key? key, this.euiTheme, required this.theme})
      : super(key: key);

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
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

  _FooterSectionState({this.onClickNext, this.onClickPrevious});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 20),
      constraints: BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 6,
              color: Color.fromRGBO(38, 38, 39, 0.12))
        ],
        color: this.widget.theme!['backgroundColor'],
      ),
      width: double.maxFinite,
      child: Center(
        child: ExpandableText(
          this.widget.theme!['footerText'],
          expandText: 'show more',
          collapseText: 'show less',
          animation: true,
          collapseOnTextTap: true,
          maxLines: 1,
          linkColor: this.widget.theme!['questionNumberColor'],
          linkStyle: TextStyle(decoration: TextDecoration.underline),
          linkEllipsis: false,
          style: TextStyle(color: this.widget.theme!['questionNumberColor'],fontSize: 14),
        ),
      ),
    );
  }
}
