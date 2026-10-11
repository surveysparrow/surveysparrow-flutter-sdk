import 'package:flutter/widgets.dart';

class SpotcheckScrollBinding {
  static ScrollController? _wrapperList;

  static void bindWrapperList(ScrollController controller) {
    _wrapperList = controller;
  }

  static ScrollController? get wrapperList => _wrapperList;

  static void clear() {
    _wrapperList = null;
  }
}
