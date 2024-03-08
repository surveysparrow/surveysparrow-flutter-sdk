import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';

class BottomNavigation extends StatefulWidget {
  final Function? onClickNext;
  final Function? onClickPrevious;
  final Map<dynamic, dynamic>? euiTheme;
  final Map<dynamic, dynamic>? theme;

  const BottomNavigation(
      {Key? key,
      this.onClickNext,
      this.onClickPrevious,
      this.euiTheme,
      required this.theme})
      : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState(
        onClickNext: onClickNext,
        onClickPrevious: onClickPrevious,
      );
}

class _BottomNavigationState extends State<BottomNavigation> {
  final Function? onClickNext;
  final Function? onClickPrevious;
  var isVertical = false;

  var showPadding = true;

  var navigationButtonSize = 42.0;
  var brandingLogoHeight = 30.0;
  var brandingLogoWidth = 155.0;

  var padding = -1.0;

  @override
  void initState() {
    super.initState();
    if (widget.euiTheme != null) {
      if (widget.euiTheme!['animationDirection'] != null) {
        if (widget.euiTheme!['animationDirection'] == "horizontal") {
          isVertical = true;
        }
      }
      if (widget.euiTheme!['bottomBar'] != null) {
        if (widget.euiTheme!['bottomBar']['padding'] != null) {
          padding = widget.euiTheme!['bottomBar']['padding'];
        }
        if (widget.euiTheme!['bottomBar']['navigationButtonSize'] != null) {
          navigationButtonSize =
              widget.euiTheme!['bottomBar']['navigationButtonSize'];
        }
      }
    }
  }

  _BottomNavigationState({this.onClickNext, this.onClickPrevious});
  @override
  Widget build(BuildContext context) {
    print(widget.theme!['questionString']);
    var bottomPadding = window.viewPadding.bottom;
    return Container(
      child: Container(
        width: double.infinity,
        child: Container(
          margin: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            bottom: padding == -1.0
                ? window.viewPadding.bottom > 1.0
                    ? 20.0
                    : 10.0
                : padding,
          ),
          child: Row(
            mainAxisAlignment: widget.theme!['showBranding']
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.theme!['showBranding']) ...[
                Container(
                  width: brandingLogoWidth,
                  height: brandingLogoHeight,
                  child: SvgPicture.string(
                    getFooterSvg(widget.theme!['questionString'] == "rgba(63, 63, 63,0.5)" ? "#76859A" : widget.theme!['questionString']),
                  ),
                ),
              ],
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (onClickPrevious != null) {
                          onClickPrevious!();
                        }
                      },
                      child: Container(
                          width: navigationButtonSize,
                          height: navigationButtonSize,
                          child: SvgPicture.string(isVertical
                              ? getLeftSvgArrow(widget.theme!['questionString'])
                              : getUpArrowSvg(
                                  widget.theme!['questionString']))),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onClickNext != null) {
                          onClickNext!();
                        }
                      },
                      child: Container(
                        width: navigationButtonSize,
                        height: navigationButtonSize,
                        child: SvgPicture.string(
                          isVertical
                              ? getRightSvgArrow(
                                  widget.theme!['questionString'])
                              : getDownArrowSvg(
                                  widget.theme!['questionString']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
