import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotCheckInternalWidget extends StatelessWidget {
  SpotCheckInternalWidget({Key? key, required this.spotCheckId, this.close})
      : super(key: key);
  final String spotCheckId;
  final close;



  @override
  Widget build(BuildContext context) {

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://53b4-183-82-247-142.ngrok-free.app/n/spotcheck/$spotCheckId'));
    
      
      log('https://53b4-183-82-247-142.ngrok-free.app/n/spotcheck/$spotCheckId');
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.black12,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  WebViewWidget(
                    controller: controller,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: close,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
