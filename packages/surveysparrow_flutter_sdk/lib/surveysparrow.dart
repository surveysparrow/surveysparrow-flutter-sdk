library surveysparrow;

export 'package:surveysparrow_flutter_sdk/models/customSurveyTheme.dart';
export 'package:surveysparrow_flutter_sdk/models/firstQuestionAnswer.dart';
export 'package:surveysparrow_flutter_sdk/models/answer.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:surveysparrow_flutter_sdk/components/common/bottomNavigation.dart';
import 'package:surveysparrow_flutter_sdk/components/common/footer.dart';
import 'package:surveysparrow_flutter_sdk/components/common/header.dart';
import 'package:surveysparrow_flutter_sdk/components/loadingScreen.dart';
import 'package:surveysparrow_flutter_sdk/components/thankyou.dart';
import 'package:surveysparrow_flutter_sdk/components/welcome.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
import 'package:surveysparrow_flutter_sdk/logics/displayLogic.dart';
import 'package:surveysparrow_flutter_sdk/logics/thankYou.dart';
import 'package:surveysparrow_flutter_sdk/models/answer.dart';
import 'package:surveysparrow_flutter_sdk/models/customSurveyTheme.dart';
import 'package:surveysparrow_flutter_sdk/models/firstQuestionAnswer.dart';
import 'package:surveysparrow_flutter_sdk/models/theme.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'helpers/answers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class SurveyModal extends StatelessWidget {
  final String token;
  final String domain;
  final Map<String, String>? variables;
  final FirstQuestionAnswer? firstQuestionAnswer;
  final CustomSurveyTheme? customSurveyTheme;
  final Function? onNext;
  final Function? onSubmit;
  final Map<dynamic, dynamic>? survey;
  final Function? onError;

  SurveyModal({
    Key? key,
    required this.token,
    required this.domain,
    this.variables,
    this.customSurveyTheme,
    this.firstQuestionAnswer,
    this.onNext,
    this.onSubmit,
    this.survey,
    this.onError,
  }) : super(key: key);

  late Future<Map<dynamic, dynamic>> testeru =
      fetchSurvey(this.token, this.domain);

  @override
  Widget build(BuildContext context) {
    if (this.survey != null) {
      return Container(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return QuestionsPage(
              token: this.token,
              domain: this.domain,
              Questions: this.survey!,
              customParams: variables ?? {},
              firstQuestionAnswer: firstQuestionAnswer,
              onNext: onNext,
              onSubmit: onSubmit,
              euiTheme: customSurveyTheme?.toMap() ?? {},
              onError: this.onError,
            );
          },
        ),
      );
    }

    return Container(
      child: FutureBuilder(
        future: testeru,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['sections'].length == 0) {
              if (onError != null) {
                onError!();
              }
              throw Exception('No question is added');
            } else if (snapshot.data['survey_type'] != null &&
                snapshot.data['survey_type'] != 'ClassicForm') {
              if (onError != null) {
                onError!();
              }
              throw Exception('unSupported Survey Type');
            } else {
              return Sizer(
                builder: (context, orientation, deviceType) {
                  return QuestionsPage(
                    token: this.token,
                    domain: this.domain,
                    Questions: snapshot.data,
                    customParams: variables ?? {},
                    firstQuestionAnswer: firstQuestionAnswer,
                    onNext: onNext,
                    onSubmit: onSubmit,
                    euiTheme: customSurveyTheme?.toMap() ?? {},
                    onError: this.onError,
                  );
                },
              );
            }
          }

          if (snapshot.hasError) {
            if (onError != null) {
              onError!();
            }
            throw Exception('Some Error Occurred while fetching survey Object');
          }
          return const LoadingScreen();
        },
      ),
    );
  }
}

class QuestionsPage extends StatefulWidget {
  final String token;
  final String domain;
  final Map<dynamic, dynamic> Questions;
  final Map<String, String> customParams;
  final FirstQuestionAnswer? firstQuestionAnswer;
  final Function? onNext;
  final Function? onSubmit;
  final Map<dynamic, dynamic>? euiTheme;
  final Function? onSubmitCloseModalFunction;
  final Function? onError;

  const QuestionsPage(
      {Key? key,
      required this.token,
      required this.domain,
      required this.Questions,
      required this.customParams,
      this.firstQuestionAnswer,
      this.onNext,
      this.onSubmit,
      this.onSubmitCloseModalFunction,
      this.euiTheme,
      this.onError})
      : super(key: key);

  @override
  State<QuestionsPage> createState() => _QuestionsPageState(
      this.token, this.Questions, this.customParams, this.firstQuestionAnswer);
}

class _QuestionsPageState extends State<QuestionsPage>
    with TickerProviderStateMixin {
  final String token;
  final Map<dynamic, dynamic> Survey;
  final Map<String, String> customParams;
  final Map<dynamic, dynamic> _questionPos = {};
  final Map<dynamic, dynamic> _surveyToMap = {};
  final FirstQuestionAnswer? firstQuestionAnswer;
  _QuestionsPageState(
      this.token, this.Survey, this.customParams, this.firstQuestionAnswer);
  List<Map<dynamic, dynamic>> _allQuestionList = [];
  List _allowedQuestionIds = [];
  Map<dynamic, dynamic> _workBench = {};
  Map<dynamic, dynamic> _themeData = {};
  Map<dynamic, dynamic> _lastQuestion = {};
  dynamic _hasThankYouLogicSkip = false;
  var _surveyThemeClass;
  int _currentQuestionNumber = 1;
  Map<dynamic, dynamic> _currentQuestionToRender = {};
  Map<dynamic, dynamic> _currentQuestionInView = {};
  List<Map<dynamic, dynamic>> _collectedAnswers = [];
  List<Map<dynamic, dynamic>> _answersToSync = [];
  Timer? _debounce;

  int _pageNumber = 0;
  double _progressMade = 0.0;
  int _answeredCount = 0;
  List<Widget> questionList = new List<Widget>.empty(growable: true);

  int _scrollCountTop = 0;
  int _scrollCountBottom = 0;

  // nxt-20
  bool blockNextButton = false;

  final allowedQuestionTypes = [
    'OpinionScale',
    'Rating',
    'TextInput',
    'MultiChoice',
    'PhoneNumber',
    'YesNo',
    'EmailInput',
  ];

  storePrefilledAnswers() {
    var _workBenchDatas = {};

    for (var i = 0; i < firstQuestionAnswer!.answers.length; i++) {
      if (firstQuestionAnswer!.answers[i].rating != null) {
        var key = firstQuestionAnswer!.answers[i].rating?.key;
        var data = firstQuestionAnswer!.answers[i].rating?.data;
        var skipped = firstQuestionAnswer!.answers[i].rating!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].rating?.timeTaken;
        _workBenchDatas[key] = data?.toDouble();

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].opnionScale != null) {
        var key = firstQuestionAnswer!.answers[i].opnionScale?.key;
        var data = firstQuestionAnswer!.answers[i].opnionScale?.data;
        var skipped = firstQuestionAnswer!.answers[i].opnionScale!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].opnionScale?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].yesOrNo != null) {
        var key = firstQuestionAnswer!.answers[i].yesOrNo?.key;
        var data = firstQuestionAnswer!.answers[i].yesOrNo?.data;
        var skipped = firstQuestionAnswer!.answers[i].yesOrNo!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].yesOrNo?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].phoneNumber != null) {
        var key = firstQuestionAnswer!.answers[i].phoneNumber?.key;
        var data =
            firstQuestionAnswer!.answers[i].phoneNumber?.data.split(" ")[1];
        var phoneData = firstQuestionAnswer!.answers[i].phoneNumber?.data;
        var skipped = firstQuestionAnswer!.answers[i].phoneNumber!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].phoneNumber?.timeTaken;

        _workBenchDatas[key] = data;
        _workBenchDatas['${key}_phone'] = phoneData;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          true,
          phoneData,
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].text != null) {
        var key = firstQuestionAnswer!.answers[i].text?.key;
        var data = firstQuestionAnswer!.answers[i].text?.data;
        var skipped = firstQuestionAnswer!.answers[i].text!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].text?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].email != null) {
        var key = firstQuestionAnswer!.answers[i].email?.key;
        var data = firstQuestionAnswer!.answers[i].email?.data;
        var skipped = firstQuestionAnswer!.answers[i].email!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].email?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }

      if (firstQuestionAnswer!.answers[i].multipleChoice != null) {
        var key = firstQuestionAnswer!.answers[i].multipleChoice?.key;
        var data = firstQuestionAnswer!.answers[i].multipleChoice?.data;
        var skipped = firstQuestionAnswer!.answers[i].multipleChoice!.skipped;
        var timeTaken = firstQuestionAnswer!.answers[i].multipleChoice?.timeTaken;
        _workBenchDatas[key] = data;

        createAnswerPayload(
          _collectedAnswers,
          key,
          skipped != null && skipped == true ? null : data,
          _surveyToMap,
          false,
          "",
          0,
          false,
          "",
          timeTaken,
        );
      }
    }

    var _cloneWorkBench = {..._workBench};
    setState(() {
      _workBench = _workBenchDatas;
    });
    widget.onNext!(_collectedAnswers);
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNextQuestion(
          customOffsetNumber: firstQuestionAnswer!.pageNumber,
          hasCustomOffset: true);
    });
  }

  storeAnswers(
    value,
    key, {
    bool otherInput = false,
    String otherInputText = "",
    int otherInputId = 0,
    bool isPhoneInput = false,
    String phoneValue = "",
    bool isLastQuestionHandle = false,
    bool changePage = true,
    bool handlePreFilledResponses = false,
  }) {
    createAnswerPayload(
      _collectedAnswers,
      key,
      value,
      _surveyToMap,
      otherInput,
      otherInputText,
      otherInputId,
      isPhoneInput,
      phoneValue,
      (_stopwatch.elapsedMilliseconds / 1000).round(),
    );

    var _cloneWorkBench = {..._workBench};

    var newWorkBench = getWorkBenchData(
      _cloneWorkBench,
      key,
      value,
      otherInputText,
      _answeredCount,
      otherInput,
      isPhoneInput,
      phoneValue,
    );

    setState(() {
      _workBench = {...newWorkBench};
    });

    widget.onNext!(_collectedAnswers);

    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNextQuestion(changePage: changePage);
    });
  }

  submitData() async {
    if (hasThankYouPage) {
      setState(() {
        _pageType = 'thankYou';
      });
    } else {
      widget.onSubmit!(_collectedAnswers);
    }

    var data = await submitAnswer(
        _collectedAnswers,
        (_stopwatch.elapsedMilliseconds / 1000).round(),
        customParams,
        this.token,
        this.widget.domain);
  }

  _scrollListener() {
    if (_scrollControler.offset >= _scrollControler.position.maxScrollExtent &&
        !_scrollControler.position.outOfRange) {
      _scrollCountBottom += 1;
      _scrollCountTop = 0;
      if (_scrollCountBottom == 2) {
        _handleNextQuestion();
        _scrollCountTop = 0;
        _scrollCountBottom = 0;
      }
    }

    if (_scrollControler.offset <= _scrollControler.position.minScrollExtent &&
        !_scrollControler.position.outOfRange) {
      _scrollCountTop += 1;
      _scrollCountBottom = 0;
      if (_scrollCountTop == 2) {
        _handlePreviousQuestion();
        _scrollCountTop = 0;
        _scrollCountBottom = 0;
      }
    }

    if (_scrollControler.offset < _scrollControler.position.maxScrollExtent &&
        _scrollControler.offset > _scrollControler.position.minScrollExtent &&
        !_scrollControler.position.outOfRange) {
      _scrollCountTop = 0;
      _scrollCountBottom = 0;
    }
  }

  late Stopwatch _stopwatch;
  late ScrollController _scrollControler;

  var hasWelcomePage = false;
  Map<dynamic, dynamic> welcomePageDetails = {};
  var welcomeDesc = "";
  var welcomeButtonDesc = "";
  Map<dynamic, dynamic> welcomeEntity = {};

  var isVertical = false;

  // thank you json
  var hasThankYouPage = false;
  var thankYouPageJson = {};

  incrementCount(token, domain) async {
    var url =
        Uri.parse('http://${domain}/api/internal/sdk/increment-count/${token}');
    final response = await http.get(url);
  }

  @override
  initState() {
    super.initState();
    incrementCount(token, this.widget.domain);

    if (widget.euiTheme!['animationDirection'] != null) {
      if (widget.euiTheme!['animationDirection'] == "horizontal") {
        isVertical = true;
      }
    }

    if (this.Survey['welcome_rtxt'] != null) {
      hasWelcomePage = true;
      welcomePageDetails = this.Survey['welcome_rtxt'];
      welcomeButtonDesc = this.Survey['welcomeScreenYesButtonText'];
      welcomeDesc = this.Survey['welcomeDescription'];
      welcomeEntity = this.Survey['welcome_rtxt']['entityMap'] ?? {};
    }

    //scroll controller
    _scrollControler = ScrollController();
    _scrollControler.addListener(_scrollListener);

    // starting the timer for stopwatch
    _stopwatch = Stopwatch();
    _stopwatch.start();

    if (this.Survey['surveyTheme'] != null) {
      _surveyThemeClass =
          SurveyThemeData.fromJson(json: this.Survey['surveyTheme']);
    } else {
      _surveyThemeClass = SurveyThemeData.fromJson();
    }

    setTheme(_themeData, _surveyThemeClass);

    var _index = 0;
    for (var section in this.Survey['sections']) {
      for (var question in section['questions']) {
        if (allowedQuestionTypes.contains(question['type'])) {
          _questionPos[question['id']] = _index;
          _surveyToMap[question['id']] = question;
          _allQuestionList.add(question);
          _allowedQuestionIds.add(question['id']);
          _index = _index + 1;
        }
      }
    }

    if (this.Survey['welcome_rtxt'] == null) {
      if (firstQuestionAnswer != null) {
        storePrefilledAnswers();
      }

      setState(() {
        questionList = convertQuestionListToWidget(
            _allQuestionList,
            _currentQuestionToRender,
            storeAnswers,
            _workBench,
            _themeData,
            customParams,
            _currentQuestionNumber,
            submitData,
            _lastQuestion,
            _scrollControler,
            this.widget.euiTheme,
            toggleNextButtonBlock);
        _currentQuestionToRender = _allQuestionList[_pageNumber];
      });
    }

    if (this.Survey['thankyou_json'].length > 0) {
      hasThankYouPage = true;
      thankYouPageJson = checkThankYouLogics(
          this.Survey['thankyou_json'], _workBench, _hasThankYouLogicSkip);
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _debounce?.cancel();
    super.dispose();
  }

  generateQuestionList(
    hadleNextSelect, {
    bool handleFinalNext = false,
    int curLastQuestionId = 0,
    bool changePage = true,
    bool hasCustomOffset = false,
    int customOffsetNumber = 0,
  }) {
    List<Map<dynamic, dynamic>> _questionsToConvert = [];
    var _questionArrayToConvert = [];
    var _currentQuestionIndex = _allQuestionList[0]['id'];

    do {
      _questionArrayToConvert.add(_currentQuestionIndex);
      var evaluatedLogics = handleDisplayLogic(_currentQuestionIndex,
          _allQuestionList, _allowedQuestionIds, _workBench, _questionPos);
      _currentQuestionIndex = evaluatedLogics[0];

      if (evaluatedLogics[1] is String && evaluatedLogics[1] != false) {
        _hasThankYouLogicSkip = evaluatedLogics[1];
      }
    } while (_currentQuestionIndex != null);

    for (var question in _questionArrayToConvert) {
      _questionsToConvert.add(_surveyToMap[question]);
    }

    setState(() {
      _lastQuestion = _questionsToConvert.last;
      _currentQuestionInView = _questionsToConvert[_pageNumber];
    });

    if (changePage) {
      if (hadleNextSelect == true) {
        if (hasCustomOffset) {
          if (_pageNumber + customOffsetNumber < _questionsToConvert.length) {
            _currentQuestionNumber =
                _currentQuestionNumber + customOffsetNumber;
            setState(() {
              _currentQuestionToRender =
                  _questionsToConvert[_pageNumber + customOffsetNumber];
            });
          }
        } else {
          if (_pageNumber + 1 < _questionsToConvert.length) {
            _currentQuestionNumber = _currentQuestionNumber + 1;
            setState(() {
              _currentQuestionToRender = _questionsToConvert[_pageNumber + 1];
            });
          }
        }
      }

      if (hadleNextSelect == false) {
        if (_pageNumber > 0) {
          var updatedQuestionNumber = _currentQuestionNumber - 1;
          _currentQuestionNumber = _currentQuestionNumber - 1;
          setState(() {
            _currentQuestionToRender = _questionsToConvert[_pageNumber - 1];
          });
        }
      }
    }

    setState(() {
      questionList = convertQuestionListToWidget(
          _questionsToConvert,
          _currentQuestionToRender,
          storeAnswers,
          _workBench,
          _themeData,
          customParams,
          _currentQuestionNumber,
          submitData,
          _lastQuestion,
          _scrollControler,
          this.widget.euiTheme,
          toggleNextButtonBlock);
      _progressMade =
          (_collectedAnswers.length / _questionsToConvert.length).toDouble();
    });
  }

  toggleNextButtonBlock(val) {
    blockNextButton = val;
  }

  // nxt-20
  _handleNextQuestion({
    int time = 400,
    bool handleFinalNext = false,
    int lastQuestionId = 0,
    bool changePage = true,
    bool hasCustomOffset = false,
    int customOffsetNumber = 0,
  }) {
    if (blockNextButton) return;
    var canUpdateQuestions = true;

    if (this._currentQuestionToRender['required'] != null &&
        this._currentQuestionToRender['required'] == true) {
      if (_workBench[_currentQuestionToRender['id']] == null) {
        canUpdateQuestions = false;
      } else {
        canUpdateQuestions = true;
      }
    } else {
      canUpdateQuestions = true;
    }

    if (canUpdateQuestions) {
      generateQuestionList(
        true,
        handleFinalNext: handleFinalNext,
        curLastQuestionId: lastQuestionId,
        changePage: changePage,
        customOffsetNumber: customOffsetNumber,
        hasCustomOffset: hasCustomOffset,
      );

      if (changePage) {
        if (hasCustomOffset) {
          if (_pageNumber + customOffsetNumber < questionList.length) {
            var updatedPageNumber = _pageNumber + customOffsetNumber;
            setState(() {
              _pageNumber = updatedPageNumber;
            });

            controller.animateToPage(updatedPageNumber,
                duration: Duration(milliseconds: time), curve: Curves.easeIn);
          }
        } else {
          if (_pageNumber + 1 < questionList.length) {
            var updatedPageNumber = _pageNumber + 1;
            setState(() {
              _pageNumber = updatedPageNumber;
            });

            controller.animateToPage(updatedPageNumber,
                duration: Duration(milliseconds: time), curve: Curves.easeIn);
          }
        }
      }
    }
  }

  _handlePreviousQuestion() {
    toggleNextButtonBlock(false);
    generateQuestionList(false);
    if (_pageNumber != 0) {
      var updatedPageNumber = _pageNumber - 1;
      setState(() {
        _pageNumber = updatedPageNumber;
      });
      controller.animateToPage(updatedPageNumber,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }
  }

  final PageController controller = PageController(initialPage: 0);

  var _pageType = "welcome";
  var _showWelcome = true;

  setPageType(val) {
    setState(() {
      _showWelcome = false;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _pageType = val;
      });
      if (firstQuestionAnswer != null) {
        storePrefilledAnswers();
      }
      setState(() {
        questionList = convertQuestionListToWidget(
            _allQuestionList,
            _currentQuestionToRender,
            storeAnswers,
            _workBench,
            _themeData,
            customParams,
            _currentQuestionNumber,
            submitData,
            _lastQuestion,
            _scrollControler,
            this.widget.euiTheme,
            toggleNextButtonBlock);
        _currentQuestionToRender = _allQuestionList[_pageNumber];
      });
    });
  }

  Future<void> _launchInBrowser(url) async {
    Uri myUri = Uri.parse(url);
    if (!await launchUrl(
      myUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $myUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;
    final bool isSmallerPhone = shortestSide < 350;

    if (hasWelcomePage && _pageType == "welcome") {
      return Container(
        decoration: BoxDecoration(
          color: _surveyThemeClass.backgroundImage != 'noImage'
              ? _surveyThemeClass.backgroundImageColor
              : _surveyThemeClass.backgroundColor,
          gradient: _themeData['hasGradient']
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment(0.8, 0.0),
                  colors: _themeData['gradientColors'])
              : null,
          image: _surveyThemeClass.backgroundImage != 'noImage' &&
                  !_themeData['hasGradient']
              ? DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                          _surveyThemeClass.backgroundImageColorOpacity),
                      BlendMode.dstATop),
                  // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                  image: NetworkImage(_surveyThemeClass.backgroundImage),
                  fit: BoxFit.cover)
              : null,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: WelcomePage(
              setPageType: setPageType,
              theme: _themeData,
              welcomePageData: this.welcomePageDetails,
              welcomeButtonDesc: this.welcomeButtonDesc,
              welcomeDesc: this.welcomeDesc,
              welcomeEntity: this.welcomeEntity,
              euiTheme: this.widget.euiTheme,
            ),
          ),
        ),
      );
    }

    if (hasThankYouPage && _pageType == "thankYou") {
      if (_hasThankYouLogicSkip is String &&
          _hasThankYouLogicSkip.contains("http")) {
        widget.onSubmit!(_collectedAnswers);
        _launchInBrowser(_hasThankYouLogicSkip);
        return SizedBox.shrink();
      }
      if (this.Survey['thankyou_json'].length > 0) {
        hasThankYouPage = true;
        thankYouPageJson = checkThankYouLogics(
            this.Survey['thankyou_json'], _workBench, _hasThankYouLogicSkip);
      }

      thankYouCloseFunction() {
        widget.onSubmit!(_collectedAnswers);
      }

      return Container(
        decoration: BoxDecoration(
          color: _surveyThemeClass.backgroundImage != 'noImage'
              ? _surveyThemeClass.backgroundImageColor
              : _surveyThemeClass.backgroundColor,
          gradient: _themeData['hasGradient']
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment(0.8, 0.0),
                  colors: _themeData['gradientColors'])
              : null,
          image: _surveyThemeClass.backgroundImage != 'noImage' &&
                  !_themeData['hasGradient']
              ? DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                          _surveyThemeClass.backgroundImageColorOpacity),
                      BlendMode.dstATop),
                  image: NetworkImage(_surveyThemeClass.backgroundImage),
                  fit: BoxFit.cover)
              : null,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ThankYouPage(
              setPageType: setPageType,
              theme: _themeData,
              thankYouPageData: this.welcomePageDetails,
              welcomeButtonDesc: this.welcomeButtonDesc,
              welcomeDesc: this.welcomeDesc,
              welcomeEntity: this.welcomeEntity,
              thankYouPageJson: thankYouPageJson,
              closeModalFunction: thankYouCloseFunction,
              euiTheme: this.widget.euiTheme,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onVerticalDragEnd: (dragEndDetails) {
        if (!isVertical) {
          if (dragEndDetails.primaryVelocity! < 0) {
            _handleNextQuestion();
          }
          if (dragEndDetails.primaryVelocity! > 0) {
            _handlePreviousQuestion();
          }
        }
      },
      onHorizontalDragEnd: (dragEndDetails) {
        if (isVertical) {
          if (dragEndDetails.primaryVelocity! < 0) {
            _handleNextQuestion();
          }
          if (dragEndDetails.primaryVelocity! > 0) {
            _handlePreviousQuestion();
          }
        }
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: _surveyThemeClass.backgroundImage != 'noImage'
              ? _surveyThemeClass.backgroundImageColor
              : _surveyThemeClass.backgroundColor,
          gradient: _themeData['hasGradient']
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment(0.8, 0.0),
                  colors: _themeData['gradientColors'])
              : null,
          image: _surveyThemeClass.backgroundImage != 'noImage' &&
                  !_themeData['hasGradient']
              ? DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                          _surveyThemeClass.backgroundImageColorOpacity),
                      BlendMode.dstATop),
                  // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                  image: NetworkImage(_surveyThemeClass.backgroundImage),
                  fit: BoxFit.cover)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_themeData['showProgressBar']) ...[
              LinearProgressIndicator(
                value: _progressMade,
                semanticsLabel: 'Linear progress indicator',
                backgroundColor: _themeData['hasHeader']
                    ? _surveyThemeClass.backgroundColor
                    : Colors.transparent,
                color: _surveyThemeClass.answerColor,
              ),
              if (!_themeData['hasHeader']) ...[
                SizedBox(
                  height: 10,
                ),
              ]
            ],
            if (_themeData['hasHeader']) ...[
              HeaderSection(
                theme: _themeData,
                euiTheme: this.widget.euiTheme,
              ),
              SizedBox(
                height: 10,
              ),
            ],
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(
                    bottom: 10.0,
                    left: useMobileLayout ? 24.0 : 10.w,
                    right: useMobileLayout ? 24.0 : 10.w),
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: isVertical ? Axis.horizontal : Axis.vertical,
                  controller: controller,
                  children: <Widget>[
                    ...questionList,
                  ],
                ),
              ),
            ),
            BottomNavigation(
              onClickNext: () {
                _handleNextQuestion();
              },
              onClickPrevious: () {
                _handlePreviousQuestion();
              },
              euiTheme: this.widget.euiTheme,
              theme: _themeData,
            ),
            if (_themeData['hasFooter']) ...[
              FooterSection(
                theme: _themeData,
                euiTheme: this.widget.euiTheme,
              )
            ],
          ],
        ),
      ),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchSurvey(token, domain) async {
  var url1 = 'http://${domain}/api/internal/sdk/get-survey/${token}';
  var url2 = 'https://${domain}/api/internal/sdk/get-survey/${token}';

  final response = await http.get(Uri.parse(url2));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsedJson = jsonDecode(response.body);
    return parsedJson;
  } else {
    print("response failed");
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
