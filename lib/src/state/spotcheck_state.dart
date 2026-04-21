import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Map<String, dynamic> _safeMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), v is Map ? _safeMap(v) : v),
    );
  }
  return {};
}

class SpotCheckStateData {
  List<dynamic> allSpotChecksInToken;
  List<dynamic> customEventsSpotChecks;
  List<dynamic> filteredSpotChecks;
  bool showSpotCheck;
  Map<String, dynamic> currentSpotcheck;
  Map<String, dynamic> params;
  Map<String, dynamic> spotCheckDetails;
  Map<String, dynamic> webViewDetails;

  SpotCheckStateData({
    List<dynamic>? allSpotChecksInToken,
    List<dynamic>? customEventsSpotChecks,
    List<dynamic>? filteredSpotChecks,
    bool? showSpotCheck,
    Map<String, dynamic>? currentSpotcheck,
    Map<String, dynamic>? params,
    Map<String, dynamic>? spotCheckDetails,
    Map<String, dynamic>? webViewDetails,
  })  : allSpotChecksInToken = allSpotChecksInToken ?? [],
        customEventsSpotChecks = customEventsSpotChecks ?? [],
        filteredSpotChecks = filteredSpotChecks ?? [],
        showSpotCheck = showSpotCheck ?? false,
        currentSpotcheck = currentSpotcheck ?? _defaultCurrentSpotcheck(),
        params = params ?? _defaultParams(),
        spotCheckDetails = spotCheckDetails ?? _defaultSpotCheckDetails(),
        webViewDetails = webViewDetails ?? _defaultWebViewDetails();

  static Map<String, dynamic> _defaultCurrentSpotcheck() => {
        'spotcheckURL': '',
        'spotcheckID': 0,
        'spotcheckContactID': 0,
        'triggerToken': '',
        'screenName': '',
        'afterDelay': 0,
        'isChat': false,
        'appearance': {},
      };

  static Map<String, dynamic> _getVisitorInfo() {
    final window = PlatformDispatcher.instance.views.first;
    final size = window.physicalSize / window.devicePixelRatio;
    return {
      'deviceType': 'MOBILE',
      'operatingSystem': Platform.isIOS ? 'iOS' : 'Android',
      'screenResolution': {
        'width': size.width.round(),
        'height': size.height.round(),
      },
      'currentDate': DateTime.now().toIso8601String(),
      'timezone': DateTime.now().timeZoneName,
    };
  }

  static Map<String, dynamic> _defaultParams() => {
        'targetToken': '',
        'domainName': '',
        'userDetails': {},
        'variables': {},
        'customProperties': {},
        'visitor': _getVisitorInfo(),
        'userAgent': '',
        'framework': "flutter",
        'traceId': '',
      };

  static Map<String, dynamic> _defaultSpotCheckDetails() => {
        'keyBoardHeight': 0,
        'textPosition': 0,
        'isMounted': false,
        'isVisible': false,
        'isExiting': false,
        'currentQuestionHeight': 0,
        'miniCardHeight': 0,
        'sideTabButtonWidth': 0,
        'isFullScreenMode': false,
        'spotCheckType': null,
        'position': 'bottom',
        'mode': '',
        'closeButton': {
          'isEnabled': false,
          'color': '#000000',
          'isMiniCard': false,
        },
        'isSpotCheckButton': false,
        'spotCheckButtonConfig': {},
        'showSurveyContent': true,
        'avatarEnabled': false,
        'avatarUrl': '',
      };

  static Map<String, dynamic> _defaultWebViewDetails() => {
        'isChatEnabled': false,
        'isClassicEnabled': false,
        'isClassicLoading': true,
        'isChatLoading': true,
        'chatUrl': null,
        'classicUrl': null,
        'isCurrentSpotcheckChat': null,
        'canShowClassic': false,
        'canShowChat': false,
        'webViewInjectionData': null,
        'scrollEnabled': true,
        'webViewConfig': {
          'javaScriptEnabled': true,
          'domStorageEnabled': true,
          'geolocationEnabled': true,
          'mediaPlaybackRequiresUserAction': false,
          'allowsInlineMediaPlayback': true,
        },
        'chatWebViewRef': null,
        'classicWebViewRef': null,
      };

  Map<String, dynamic> toJson() => {
        'SpotCheckState': {
          'allSpotChecksInToken': allSpotChecksInToken,
          'customEventsSpotChecks': customEventsSpotChecks,
          'filteredSpotChecks': filteredSpotChecks,
          'showSpotCheck': showSpotCheck,
          'currentSpotcheck': currentSpotcheck,
          'params': params,
          'spotCheckDetails': spotCheckDetails,
          'webViewDetails': webViewDetails,
        },
      };
}

class SpotcheckStore extends ChangeNotifier {
  SpotcheckStore() : wrapperListScrollController = ScrollController();

  SpotCheckStateData _state = SpotCheckStateData();

  final ScrollController wrapperListScrollController;

  SpotCheckStateData get state => _state;

  Map<String, dynamic> getState() => _state.toJson();

  void dispatch(dynamic rawUpdate) {
    _applyUpdate(rawUpdate);
    notifyListeners();
  }

  void batchDispatch(List<dynamic> updates) {
    for (final update in updates) {
      _applyUpdate(update);
    }
    notifyListeners();
  }

  void _applyUpdate(dynamic rawUpdate) {
    final update = _safeMap(rawUpdate);
    for (final key in update.keys) {
      final val = update[key];
      switch (key) {
        case 'allSpotChecksInToken':
          if (val is List)
            _state.allSpotChecksInToken = List<dynamic>.from(val);
          break;
        case 'customEventsSpotChecks':
          if (val is List)
            _state.customEventsSpotChecks = List<dynamic>.from(val);
          break;
        case 'filteredSpotChecks':
          if (val is List) _state.filteredSpotChecks = List<dynamic>.from(val);
          break;
        case 'showSpotCheck':
          if (val is bool) _state.showSpotCheck = val;
          break;
        case 'currentSpotcheck':
          if (val is Map) _mergeNested(_state.currentSpotcheck, _safeMap(val));
          break;
        case 'params':
          if (val is Map) _mergeNested(_state.params, _safeMap(val));
          break;
        case 'spotCheckDetails':
          if (val is Map) _mergeNested(_state.spotCheckDetails, _safeMap(val));
          break;
        case 'webViewDetails':
          if (val is Map) _mergeNested(_state.webViewDetails, _safeMap(val));
          break;
      }
    }
  }

  void _mergeNested(Map<String, dynamic> target, Map<String, dynamic> source) {
    for (final key in source.keys) {
      target[key] = source[key];
    }
  }

  void reset() {
    _state = SpotCheckStateData();
    notifyListeners();
  }

  @override
  void dispose() {
    wrapperListScrollController.dispose();
    super.dispose();
  }
}
