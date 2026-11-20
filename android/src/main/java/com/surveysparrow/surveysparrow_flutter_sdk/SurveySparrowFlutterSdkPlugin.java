package com.surveysparrow.surveysparrow_flutter_sdk;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** No native API; exists so the package's Gradle fix for flutter_js is applied. */
public class SurveySparrowFlutterSdkPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
