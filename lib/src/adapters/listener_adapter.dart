import 'package:surveysparrow_flutter_sdk/ss_spotcheck_listener.dart';

class ListenerAdapter {
  SsSpotcheckListener? _listener;

  void setListener(SsSpotcheckListener? listener) {
    _listener = listener;
  }

  Future<void> onSurveyLoaded(Map<String, dynamic> response) async {
    await _listener?.onSurveyLoaded(response);
  }

  Future<void> onSurveyResponse(Map<String, dynamic> response) async {
    await _listener?.onSurveyResponse(response);
  }

  Future<void> onPartialSubmission(Map<String, dynamic> response) async {
    await _listener?.onPartialSubmission(response);
  }

  Future<void> onCloseButtonTap() async {
    await _listener?.onCloseButtonTap();
  }

  Map<String, dynamic> toJson() => {
        'onSurveyLoaded': _listener != null,
        'onSurveyResponse': _listener != null,
        'onPartialSubmission': _listener != null,
        'onCloseButtonTap': _listener != null,
      };
}
