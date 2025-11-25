import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;


class SpotCheckButtonConfig {
  final String type;
  final String? position;
  final String? buttonSize;
  final String? icon;
  final String? generatedIcon;
  final String? backgroundColor;
  final String? cornerRadius;
  final String? textColor;
  final String? buttonText;

  SpotCheckButtonConfig({
    required this.type,
    this.position,
    this.buttonSize = 'medium',
    this.icon,
    this.generatedIcon,
    this.backgroundColor = '#4A9CA6',
    this.cornerRadius = 'sharp',
    this.textColor = '#FFFFFF',
    this.buttonText,
  });

  factory SpotCheckButtonConfig.fromJson(Map<String, dynamic> json) {

    return SpotCheckButtonConfig(
      type: json['type'] ?? 'textButton',
      position: json['position'],
      buttonSize: json['buttonSize'] ?? 'medium',
      icon: json['icon'],
      generatedIcon: json['generatedIcon'],
      backgroundColor: json['backgroundColor'] ?? '#4A9CA6',
      cornerRadius: json['cornerRadius'] ?? 'sharp',
      textColor: json['textColor'] ?? '#FFFFFF',
      buttonText: json['buttonText'],
    );
  }
}


class SpotCheckButtonUtils {

  static Color hexToColor(String hex, {double opacity = 1.0}) {
    if (!RegExp(r'^#([A-Fa-f0-9]{3}){1,2}$').hasMatch(hex)) {
      return const Color(0xFF4A9CA6);
    }

    String hexCode = hex.substring(1);
    if (hexCode.length == 3) {
      hexCode = hexCode.split('').map((char) => char + char).join();
    }

    final int value = int.parse(hexCode, radix: 16);
    return Color.fromRGBO(
      (value >> 16) & 255,
      (value >> 8) & 255,
      value & 255,
      opacity,
    );
  }


  static const Map<String, double> sizeMap = {
    'small': 28,
    'medium': 32,
    'large': 40,
  };

  static const Map<String, double> sizeMapTextButton = {
    'small': 16,
    'medium': 20,
    'large': 24,
  };


  static const Map<String, Map<String, double>> borderRadiusMap = {
    'sharp': {'small': 4, 'medium': 6, 'large': 8},
    'soft': {'small': 8, 'medium': 12, 'large': 16},
    'smooth': {'small': 24, 'medium': 16, 'large': 24},
  };


  static double getSizeValue(String buttonSize) {
    return sizeMap[buttonSize] ?? sizeMap['medium']!;
  }


  static double getSizeValueTextButton(String buttonSize) {
    return sizeMapTextButton[buttonSize] ?? sizeMapTextButton['medium']!;
  }


  static double getBorderRadius(String? cornerRadius, String buttonSize) {
    final radiusType = cornerRadius ?? 'sharp';
    final size = buttonSize;
    return borderRadiusMap[radiusType]?[size] ?? 6;
  }


  static TextStyle getTextStyle(String buttonSize) {
    switch (buttonSize) {
      case 'small':
        return const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          height: 16 / 12,
        );
      case 'large':
        return const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          height: 24 / 16,
        );
      default:
        return const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 20 / 14,
        );
    }
  }
}


class SpotCheckIcon extends StatelessWidget {
  final String? icon;
  final double size;
  final String buttonType;

  const SpotCheckIcon({
    Key? key,
    required this.icon,
    required this.size,
    this.buttonType = 'textButton',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon == null || icon!.isEmpty) return const SizedBox.shrink();

    final isImage = icon!.startsWith('http');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: icon!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return SvgPicture.string(
      icon!,
      width: size,
      height: size,
      placeholderBuilder: (context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }
}

class SpotCheckFloatingButton extends StatelessWidget {
  final SpotCheckButtonConfig config;
  final VoidCallback onPressed;

  const SpotCheckFloatingButton({
    Key? key,
    required this.config,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = SpotCheckButtonUtils.getSizeValue(config.buttonSize!);
    const innerBorderWidth = 4.0;
    const outerBorderWidth = 4.0;
    final bgColor = SpotCheckButtonUtils.hexToColor(config.backgroundColor!);
    final containerSize = size + innerBorderWidth * 2 + outerBorderWidth * 2;

    final button = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(containerSize / 2),
        color: SpotCheckButtonUtils.hexToColor(config.backgroundColor!,
            opacity: 0.25),
      ),
      padding: const EdgeInsets.all(outerBorderWidth),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular((containerSize - outerBorderWidth * 2) / 2),
          color: SpotCheckButtonUtils.hexToColor(config.backgroundColor!,
              opacity: 0.5),
        ),
        padding: const EdgeInsets.all(innerBorderWidth),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(size / 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: Center(
                child: SpotCheckIcon(
                  icon: config.generatedIcon!='' ? config.generatedIcon : config.icon,
                  size: size * 0.6,
                  buttonType: 'floatingButton',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return button;

  }
}

class SpotCheckSideTabButton extends StatefulWidget {
  final SpotCheckButtonConfig config;
  final VoidCallback onPressed;

  const SpotCheckSideTabButton({
    Key? key,
    required this.config,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<SpotCheckSideTabButton> createState() => _SpotCheckSideTabButtonState();
}

class _SpotCheckSideTabButtonState extends State<SpotCheckSideTabButton> {
  double buttonWidth = 0;
  double buttonHeight = 0;
  bool sizeMeasured = false;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getButtonSize());
  }

  void _getButtonSize() {
    final RenderBox? renderBox =
    _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        buttonWidth = renderBox.size.width;
        buttonHeight = renderBox.size.height;
        sizeMeasured = true;
      });
    }
  }

  EdgeInsets _getSizeStyle(String buttonSize) {
    switch (buttonSize) {
      case 'small':
        return const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
      case 'large':
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 16);
      default:
        return const EdgeInsets.symmetric(vertical: 6, horizontal: 12);
    }
  }

  /// Swift equivalent of translationX(horizontal:)
  double _translationX(String horizontal) {
    if (buttonWidth == 0 || buttonHeight == 0) return 0;
    final diff = (buttonWidth - buttonHeight) / 2;
    if (horizontal == 'left') return -diff;
    if (horizontal == 'right') return diff;
    return 0;
  }

  /// Swift equivalent of translationY(vertical:horizontal:)
  double _translationY(String vertical, String horizontal) {
    if (!(horizontal == 'left' || horizontal == 'right')) return 0;
    if (vertical == 'top') return buttonWidth / 2;
    if (vertical == 'bottom') return -buttonWidth / 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pos = widget.config.position ?? "bottom_right";

    final textStyle =
    SpotCheckButtonUtils.getTextStyle(widget.config.buttonSize!);
    final borderRadiusValue = SpotCheckButtonUtils.getBorderRadius(
      widget.config.cornerRadius,
      widget.config.buttonSize!,
    );
    final sizeStyle = _getSizeStyle(widget.config.buttonSize!);
    final bgColor =
    SpotCheckButtonUtils.hexToColor(widget.config.backgroundColor!);
    final textColor = SpotCheckButtonUtils.hexToColor(widget.config.textColor!);

    Widget button = Material(
      key: _buttonKey,
      color: bgColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadiusValue),
        topRight: Radius.circular(borderRadiusValue),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusValue),
          topRight: Radius.circular(borderRadiusValue),
        ),
        onTap: widget.onPressed,
        child: Container(
          padding: sizeStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.config.generatedIcon != null ||
                  widget.config.icon != null) ...[
                SpotCheckIcon(
                  icon: widget.config.generatedIcon != ''
                      ? widget.config.generatedIcon
                      : widget.config.icon,
                  size: SpotCheckButtonUtils.getSizeValueTextButton(
                      widget.config.buttonSize!),
                ),
                if (widget.config.buttonText?.isNotEmpty == true)
                  const SizedBox(width: 6),
              ],
              if (widget.config.buttonText?.isNotEmpty == true)
                Text(widget.config.buttonText!,
                    style: textStyle.copyWith(color: textColor)),
            ],
          ),
        ),
      ),
    );

    if (!sizeMeasured) {
      return Opacity(opacity: 0.0, child: button);
    }

    // Split into vertical/horizontal from position name
    final parts = pos.split('_');
    final vertical = parts.first;
    final horizontal = parts.length > 1 ? parts.last : 'right';

    double? top, bottom, left, right;
    double rotationAngle = 0;

    switch (pos) {
      case "top_left":
        top = mediaQuery.padding.top + 16;
        left = 0;
        rotationAngle = math.pi / 2;
        break;
      case "center_left":
        top = (mediaQuery.size.height -
            mediaQuery.padding.top -
            mediaQuery.padding.bottom -
            buttonWidth) /
            2;
        left = 0;
        rotationAngle = math.pi / 2;
        break;
      case "bottom_left":
        bottom = mediaQuery.padding.bottom + 16;
        left = 0;
        rotationAngle = math.pi / 2;
        break;
      case "top_right":
        top = mediaQuery.padding.top + 16;
        right = 0;
        rotationAngle = -math.pi / 2;
        break;
      case "center_right":
        top = (mediaQuery.size.height -
            mediaQuery.padding.top -
            mediaQuery.padding.bottom -
            buttonWidth) /
            2;
        right = 0;
        rotationAngle = -math.pi / 2;
        break;
      case "bottom_right":
      default:
        bottom = mediaQuery.padding.bottom + 16;
        right = 0;
        rotationAngle = -math.pi / 2;
        break;
    }

    return Stack(
      children: [
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: Transform.translate(
            offset: Offset(
              _translationX(horizontal),
              _translationY(vertical, horizontal),
            ),
            child: Transform.rotate(
              angle: rotationAngle,
              alignment: Alignment.center,
              child: button,
            ),
          ),
        ),
      ],
    );
  }
}


class SpotCheckTextButton extends StatelessWidget {
  final SpotCheckButtonConfig config;
  final VoidCallback onPressed;

  const SpotCheckTextButton({
    Key? key,
    required this.config,
    required this.onPressed,
  }) : super(key: key);

  EdgeInsets _getSizeStyle(String buttonSize) {
    switch (buttonSize) {
      case 'small':
        return const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
      case 'large':
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 16);
      default:
        return const EdgeInsets.symmetric(vertical: 6, horizontal: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = SpotCheckButtonUtils.getTextStyle(config.buttonSize!);
    final borderRadiusValue = SpotCheckButtonUtils.getBorderRadius(
      config.cornerRadius,
      config.buttonSize!,
    );
    final sizeStyle = _getSizeStyle(config.buttonSize!);
    final bgColor = SpotCheckButtonUtils.hexToColor(config.backgroundColor!);
    final textColor = SpotCheckButtonUtils.hexToColor(config.textColor!);

    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        onTap: onPressed,
        child: Container(
          padding: sizeStyle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (config.generatedIcon != null || config.icon != null) ...[
                SpotCheckIcon(
                  icon: config.generatedIcon!='' ? config.generatedIcon : config.icon,
                  size: SpotCheckButtonUtils.getSizeValueTextButton(
                      config.buttonSize!),
                ),
                if (config.buttonText?.isNotEmpty == true)
                  const SizedBox(width: 6),
              ],
              if (config.buttonText?.isNotEmpty == true)
                Text(
                  config.buttonText!,
                  style: textStyle.copyWith(color: textColor),
                ),
            ],
          ),
        ),
      ),
    );

    return button;

  }
}


class SpotCheckButton extends StatelessWidget {
  final SpotCheckButtonConfig config;
  final VoidCallback onPressed;

  const SpotCheckButton({
    Key? key,
    required this.config,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (config.type) {
      case 'floatingButton':
        return SpotCheckFloatingButton(
          config: config,
          onPressed: onPressed,
        );
      case 'sideTab':
        return SpotCheckSideTabButton(
          config: config,
          onPressed: onPressed,
        );
      case 'textButton':
        return SpotCheckTextButton(
          config: config,
          onPressed: onPressed,
        );
      default:
        return Container(
            decoration: BoxDecoration(color: Colors.green),
            child: const SizedBox(width: 0,height: 0,));
    }
  }
}
