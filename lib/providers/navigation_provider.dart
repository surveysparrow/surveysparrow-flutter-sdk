import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  bool? blockNavigationDown ;

  void toggleBlockNavigationDown(bool value) {
    blockNavigationDown = value;
    notifyListeners();
  }
}