# SurveySparrow-Flutter-SDK

[SurveySparrow's](https://surveysparrow.com) SDK lets you collect feedback at various touchpoints from your mobile app users. You can easily embed surveys in your mobile app with a few lines of code. This documentation walks you through the possibilities of the SDK before you begin integrating the mobile SDK with your app.

### How it works?

You can install the SDK on Xcode or Android Studio and configure when you want to invoke the survey. Based on those conditions, you will be able to call the survey when a particular condition is met. For instance, let’s say your app lets people book a cab (like Uber or Lyft). You may want to display feedback surveys after a trip is complete. You can easily do that with our SDK.

## Documentation

SurveySparrow’s Flutter package supports two integration modes. Use the row that matches your use case.

| Integration | Latest version | Package name | Documentation |
|-------------|----------------|--------------|---------------|
| **SpotChecks** | `1.2.8` | `surveysparrow_flutter_sdk` | [Flutter SpotChecks](https://developers.surveysparrow.com/spotchecks/mobile-spotchecks/flutter) |
| **SDK Share** (embed surveys) | `1.1.6` | `surveysparrow_flutter_sdk` | [Flutter SDK](https://developers.surveysparrow.com/sdk/flutter) |

### Install

| Integration | Command |
|-------------|---------|
| SpotChecks | `flutter pub add surveysparrow_flutter_sdk:^1.2.8` |
| SDK Share | `flutter pub add surveysparrow_flutter_sdk:^1.1.6` |

### pub.dev

| Integration | Version page |
|-------------|--------------|
| SpotChecks | https://pub.dev/packages/surveysparrow_flutter_sdk/versions/1.2.8 |
| SDK Share | https://pub.dev/packages/surveysparrow_flutter_sdk/versions/1.1.6 |

### `file_picker` compatibility

| SDK version | `file_picker` |
|-------------|---------------|
| `1.2.7+` | `>=11.0.0` |
| `1.2.6` and below | `>=8.1.0 <11.0.0` |

> Please submit bugs/issues through [GitHub issues](https://github.com/surveysparrow/surveysparrow-flutter-sdk/issues); we will try to fix them ASAP.
