import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SpinKitRing(
          color: Color.fromRGBO(63, 63, 63, 1),
          size: 50.0,
        ),
        SizedBox(
          height: 40,
        ),
        // SvgPicture.string(loaderSVG),
      ],
    );
  }
}
