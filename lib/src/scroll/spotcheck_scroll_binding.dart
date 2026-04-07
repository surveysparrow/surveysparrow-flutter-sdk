import 'package:flutter/widgets.dart';

/// Lets schema [ListView] attach to the SDK-owned scroll controller without
/// threading [BuildContext] through [ComponentRegistry].
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
