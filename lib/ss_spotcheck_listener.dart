
abstract class SsSpotcheckListener {
  Future<void> onSurveyLoaded(Map<String, dynamic> response) async {}

  Future<void> onSurveyResponse(Map<String, dynamic> response) async {}

  Future<void> onPartialSubmission(Map<String, dynamic> response) async {}

  Future<void> onCloseButtonTap() async {}
}
