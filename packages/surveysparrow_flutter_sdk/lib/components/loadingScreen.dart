import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:surveysparrow_flutter_sdk/helpers/svg.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SpinKitRing(
          color: Color.fromRGBO(63, 63, 63, 1),
          size: 50.0,
        ),
        SizedBox(height: 40,),
        SvgPicture.string(loaderSVG),
      ],
    );
  }
}
