## 1.0.0-beta.1

* beta release with advanced customizations with basic question types.

## 1.0.0-beta.2

* updated readme.

## 1.0.0-beta.3

* updated readme.

## 1.0.0-beta.4

* updated readme.

## 1.0.0-beta.5

* updated readme.

## 1.0.0-beta.6

* updated dependency packages.

## 1.0.0-beta.7

* updating dependency packages.

## 1.1.0

* Initial release.

## 1.1.1

* Bug Fixes.

## 1.1.2

* Adding CX Surveys Support.
* Bug Fixes.
  
## 1.1.3

* Submission Queue Support

## 1.2.0-beta.1

* SpotChecks

## 1.2.0-beta.2

* Http UserAgent Fix, Example Revamp, Code Clean Up, Android Fix
  
## 1.2.0-beta.3

* Anonymous Submission Support

## 1.2.0-beta.4

* SSE-30549 Fix

## 1.2.0-beta.5

* SSE-30547 Fix

## 1.2.0-beta.6

* SSE-30285, SSE-31037, SSE-30611 Fix
  
## 1.2.0-beta.7

* SpotChecks

## 1.2.0-beta.8

* SSE-30634 Fix
  
## 1.2.0-beta.9

* UI Fix

## 1.2.0-beta.10

* Logic Fix
  
## 1.2.0-beta.11

* SPOTCHECKS
  
## 1.2.0

* SPOTCHECKS
  
## 1.2.1

* MacOS Support on Spotchecks  
  
## 1.2.2

* Media Question Support for Android OS on Spotchecks

## 1.2.3

* SpotChecks enhancements and Mini Cards

## 1.2.9

* Backend-driven SpotChecks revamp: layout and logic now come from the SurveySparrow backend.
* A failed SpotChecks init (e.g. offline at launch) is retried on the next track call; the init request times out after 15s.
* Minimum Flutter 3.24 / Dart 3.5 (already required by `webview_flutter` 4.10).
* Removed the internal `spot_check_state.dart` and `spot_check_button.dart` files; import `package:surveysparrow_flutter_sdk/surveysparrow.dart` instead. The documented API is unchanged.
* Sends the host app's version and build number with SpotChecks requests, so SurveySparrow tracks the SDK version in your newest release. Adds the `package_info_plus` (8.x–10.x) dependency; it is installed automatically with `flutter pub get`.
* Compatibility:
  * Supported dependency ranges: `file_picker` 11.x, `device_info_plus` 11.x, `cached_network_image` 3.x, `sentry` 8.x. Apps already on newer major versions of these get a version conflict until a later release widens support.
  * Android Gradle Plugin 9 (projects created with the newest Flutter template): the Android build fails inside the `flutter_js` dependency ("Inconsistent JVM Target Compatibility"). Workaround: add `kotlin.jvm.target.validation.mode=warning` to `android/gradle.properties`. AGP 8 projects are not affected.
