import 'package:flutter/material.dart';

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
        showNext: showNext,
        showSkip: showSkip,
        onClickNext: onClickNext,
        onClickSkip: onClickSkip,
        theme: theme,
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

  dynamic customFont;

  var skipButtonFontSize = 12.0;

  var nextButtonFontSize = 14.0;
  var nextButtonWidth = 100.0;
  var nextButtonIconSize = 22.0;
  @override
  void initState() {
    super.initState();

    if (widget.euiTheme != null) {
      if (widget.euiTheme!['font'] != null) {
        customFont = widget.euiTheme!['font'];
      }

      if (widget.euiTheme!['skipButton'] != null) {
        if (widget.euiTheme!['skipButton']['fontSize'] != null) {
          skipButtonFontSize = widget.euiTheme!['skipButton']['fontSize'];
        }
      }

      if (widget.euiTheme!['nextButton'] != null) {
        if (widget.euiTheme!['nextButton']['fontSize'] != null) {
          nextButtonFontSize = widget.euiTheme!['nextButton']['fontSize'];
        }

        if (widget.euiTheme!['nextButton']['width'] != null) {
          nextButtonWidth = widget.euiTheme!['nextButton']['width'];
        }

        if (widget.euiTheme!['nextButton']['iconSize'] != null) {
          nextButtonIconSize = widget.euiTheme!['nextButton']['iconSize'];
        }
      }
    }
    luminanceValue = theme['ctaButtonColor'].computeLuminance();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.showNext) ...[
          Opacity(
            opacity:
                widget.disabled != null && widget.disabled! == true ? 0.4 : 1,
            child: ElevatedButton(
              onPressed: () async {
                if (onClickNext != null) {
                  onClickNext!();
                }
              },
              style: theme['buttonStyle'] == "filled"
                  ? ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme['ctaButtonColor'],
                      padding: const EdgeInsets.all(10),
                      shape: const StadiumBorder(),
                    )
                  : ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0x00000000),
                      padding: const EdgeInsets.all(10),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: theme['ctaButtonColor']),
                    ),
              child: SizedBox(
                width: nextButtonWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      (showSubmit != null && showSubmit == true)
                          ? "SUBMIT"
                          : "NEXT",
                      style: TextStyle(
                        fontFamily: customFont,
                        decoration: TextDecoration.none,
                        fontSize: nextButtonFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme['buttonStyle'] == "filled"
                            ? luminanceValue > 0.5
                                ? Colors.black
                                : Colors.white
                            : theme['ctaButtonColor'],
                      ),
                    ),
                    Icon(
                      (showSubmit != null && showSubmit == true)
                          ? Icons.check_rounded
                          : Icons.keyboard_arrow_right,
                      color: theme['buttonStyle'] == "filled"
                          ? luminanceValue > 0.5
                              ? Colors.black
                              : Colors.white
                          : theme['ctaButtonColor'],
                      size: nextButtonIconSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
        if (showSkip) ...[
          GestureDetector(
            onTap: () {
              if (onClickSkip != null) {
                onClickSkip!();
              }
            },
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
        ],
      ],
    );
  }
}
