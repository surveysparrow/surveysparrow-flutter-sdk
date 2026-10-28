# SurveySparrow-Flutter-SDK

[SurveySparrow's](https://surveysparrow.com) SDK lets you collect feedback at various touchpoints from your mobile app users. You can easily embed surveys in your mobile app with a few lines of code. This documentation walks you through the possibilities of the SDK before you begin integrating the mobile SDK with your app.

### How it works?

You can install the SDK on Xcode or Android Studio and configure when you want to invoke the survey. Based on those conditions, you will be able to call the survey when a particular condition is met. For instance, let’s say your app lets people book a cab (like Uber or Lyft). You may want to display feedback surveys after a trip is complete. You can easily do that with our SDK.

## Documentation

SurveySparrow’s Flutter package supports two integration modes. Use the row that matches your use case.

| Integration | Latest version | Package name | Documentation |
|-------------|----------------|--------------|---------------|
| **SpotChecks** | `1.2.9` | `surveysparrow_flutter_sdk` | [Flutter SpotChecks](https://developers.surveysparrow.com/spotchecks/mobile-spotchecks/flutter) |
| **SDK Share** (embed surveys) | `1.1.6` | `surveysparrow_flutter_sdk` | [Flutter SDK](https://developers.surveysparrow.com/sdk/flutter) |

### Install

| Integration | Command |
|-------------|---------|
| SpotChecks | `flutter pub add surveysparrow_flutter_sdk:^1.2.9` |
| SDK Share | `flutter pub add surveysparrow_flutter_sdk:^1.1.6` |

### pub.dev

| Integration | Version page |
|-------------|--------------|
| SpotChecks | https://pub.dev/packages/surveysparrow_flutter_sdk/versions/1.2.9 |
| SDK Share | https://pub.dev/packages/surveysparrow_flutter_sdk/versions/1.1.6 |

### Requirements and compatibility

| SDK version | Flutter / Dart | `file_picker` | `webview_flutter` |
|-------------|----------------|---------------|-------------------|
| `1.2.9` | Flutter `>=3.27.0`, Dart `>=3.6.0` | `>=11.0.0 <12.0.0` | `>=4.10.0 <5.0.0` |
| `1.2.7` – `1.2.8` | Flutter `>=3.13.0`, Dart `>=3.1.0` | `>=11.0.0` | `>=4.10.0` |
| `1.2.6` and below | Flutter `>=3.13.0`, Dart `>=3.1.0` | `>=8.1.0` (use below 11.0.0) | `>=4.10.0` |

Android: `minSdk` 24 or higher and System WebView 80 or newer. iOS: 15.0 or newer. Camera, microphone and photo permissions are only needed for surveys that use them; see the docs for the exact manifest and `Info.plist` keys.

> Please submit bugs/issues through [GitHub issues](https://github.com/surveysparrow/surveysparrow-flutter-sdk/issues); we will try to fix them ASAP.
