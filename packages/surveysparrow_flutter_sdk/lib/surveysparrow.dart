library surveysparrow;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:surveysparrow_flutter_sdk/components/common/bottomNavigation.dart';
import 'package:surveysparrow_flutter_sdk/components/loadingScreen.dart';
import 'package:surveysparrow_flutter_sdk/components/thankyou.dart';
import 'package:surveysparrow_flutter_sdk/components/welcome.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
import 'package:surveysparrow_flutter_sdk/logics/displayLogic.dart';
import 'package:surveysparrow_flutter_sdk/logics/thankYou.dart';
import 'package:surveysparrow_flutter_sdk/models/theme.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'helpers/answers.dart';
import 'dart:async';

class SurveyModal extends StatelessWidget {
  final String token;
  final Map<String, String> customParams;
  final dynamic? firstQuestionAnswer;
  final Map<dynamic, dynamic>? euiTheme;
  final Function? currentlyCollectedAnswers;
  final Function? allCollectedAnswers;
  final Map<dynamic, dynamic>? surveyData;
  final Function? onSubmitCloseModalFunction;

  SurveyModal({
    Key? key,
    required this.token,
    required this.customParams,
    this.euiTheme,
    this.firstQuestionAnswer,
    this.currentlyCollectedAnswers,
    this.allCollectedAnswers,
    this.surveyData,
    this.onSubmitCloseModalFunction,
  }) : super(key: key);

  late Future<Map<dynamic, dynamic>> testeru = fetchAlbum(this.token);

  static testFunc(){
    print("ttryl");
  }

  @override
  Widget build(BuildContext context) {
    if (this.surveyData != null) {
      return Container(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return QuestionsPage(
              token: this.token,
              Questions: this.surveyData!,
              customParams: customParams,
              firstQuestionAnswer: firstQuestionAnswer,
              currentlyCollectedAnswers: currentlyCollectedAnswers,
              allCollectedAnswers: allCollectedAnswers,
              onSubmitCloseModalFunction: onSubmitCloseModalFunction,
              euiTheme: this.euiTheme,
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
            return Sizer(
              builder: (context, orientation, deviceType) {
                return QuestionsPage(
                  token: this.token,
                  Questions: snapshot.data,
                  customParams: customParams,
                  firstQuestionAnswer: firstQuestionAnswer,
                  currentlyCollectedAnswers: currentlyCollectedAnswers,
                  allCollectedAnswers: allCollectedAnswers,
                  onSubmitCloseModalFunction: onSubmitCloseModalFunction,
                  euiTheme: euiTheme,
                );
              },
            );
          }
          return const LoadingScreen();
        },
      ),
    );
  }
}

class QuestionsPage extends StatefulWidget {
  final String token;
  final Map<dynamic, dynamic> Questions;
  final Map<String, String> customParams;
  final dynamic? firstQuestionAnswer;
  final Function? currentlyCollectedAnswers;
  final Function? allCollectedAnswers;
  final Map<dynamic, dynamic>? euiTheme;
  final Function? onSubmitCloseModalFunction;

  const QuestionsPage({
    Key? key,
    required this.token,
    required this.Questions,
    required this.customParams,
    this.firstQuestionAnswer,
    this.currentlyCollectedAnswers,
    this.allCollectedAnswers,
    this.onSubmitCloseModalFunction,
    this.euiTheme,
  }) : super(key: key);

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
  final dynamic? firstQuestionAnswer;
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

  final allowedQuestionTypes = [
    'OpinionScale',
    'Rating',
    'TextInput',
    'MultiChoice',
    'PhoneNumber',
    'YesNo',
    'EmailInput',
  ];

  storeAnswers(value, key,
      {bool otherInput = false,
      String otherInputText = "",
      int otherInputId = 0,
      bool isPhoneInput = false,
      String phoneValue = ""}) {
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

    widget.currentlyCollectedAnswers!(_collectedAnswers);

    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNextQuestion();
    });

    if (_lastQuestion['id'] == key) {
      widget.allCollectedAnswers!(_collectedAnswers);
    }
  }

  submitData() async {

    print("last question is lq12 ${this._lastQuestion}");

    if (hasThankYouPage) {
      setState(() {
        _pageType = 'thankYou';
      });
    } else {
      this.widget.onSubmitCloseModalFunction!();
    }

    var data = await submitAnswer(
        _collectedAnswers,
        (_stopwatch.elapsedMilliseconds / 1000).round(),
        customParams,
        this.token);

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

  @override
  initState() {
    super.initState();
    if (widget.euiTheme!['bottomSheet'] != null) {
      if (widget.euiTheme!['bottomSheet']['direction'] != null) {
        if (widget.euiTheme!['bottomSheet']['direction'] == "horizontal") {
          isVertical = true;
        }
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
        this.storeAnswers(firstQuestionAnswer, _allowedQuestionIds[0]);
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
        );
        _currentQuestionToRender = _allQuestionList[_pageNumber];
      });
    }

    if (this.Survey['thankyou_json'].length > 0) {
      hasThankYouPage = true;
      thankYouPageJson =
          checkThankYouLogics(this.Survey['thankyou_json'], _workBench,_hasThankYouLogicSkip);
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _debounce?.cancel();
    super.dispose();
  }

  generateQuestionList(hadleNextSelect) {
    List<Map<dynamic, dynamic>> _questionsToConvert = [];
    var _questionArrayToConvert = [];
    var _currentQuestionIndex = _allQuestionList[0]['id'];

    do {
      _questionArrayToConvert.add(_currentQuestionIndex);
      var evaluatedLogics = handleDisplayLogic(_currentQuestionIndex,
          _allQuestionList, _allowedQuestionIds, _workBench, _questionPos);
      _currentQuestionIndex = evaluatedLogics[0];
      // _hasThankYouLogicSkip
      if(evaluatedLogics[1] is String && evaluatedLogics[1] != false){
        _hasThankYouLogicSkip = evaluatedLogics[1];
      }
      print("evaluated logics is ${evaluatedLogics}");
    } while (_currentQuestionIndex != null);

    for (var question in _questionArrayToConvert) {
      _questionsToConvert.add(_surveyToMap[question]);
    }

    setState(() {
      _lastQuestion = _questionsToConvert.last;
      _currentQuestionInView = _questionsToConvert[_pageNumber];
    });

    if (hadleNextSelect == true) {
      if (_pageNumber + 1 < _questionsToConvert.length) {
        var updatedQuestionNumber = _currentQuestionNumber + 1;
        _currentQuestionNumber = _currentQuestionNumber + 1;
        setState(() {
          _currentQuestionToRender = _questionsToConvert[_pageNumber + 1];
        });
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
      );
      _progressMade =
          (_collectedAnswers.length / _questionsToConvert.length).toDouble();
    });
  }

  _handleNextQuestion({int time = 400}) {
    var canUpdateQuestions = true;

    if (this._currentQuestionToRender['required']) {
      if (_workBench[_currentQuestionToRender['id']] == null) {
        canUpdateQuestions = false;
      } else {
        canUpdateQuestions = true;
      }
    }

    if (canUpdateQuestions) {
      generateQuestionList(true);
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

  _handlePreviousQuestion() {
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
        this.storeAnswers(firstQuestionAnswer, _allowedQuestionIds[0]);
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
        );
        _currentQuestionToRender = _allQuestionList[_pageNumber];
      });
    });
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
      if (this.Survey['thankyou_json'].length > 0) {
        hasThankYouPage = true;
        thankYouPageJson =
            checkThankYouLogics(this.Survey['thankyou_json'], _workBench,_hasThankYouLogicSkip);
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
              closeModalFunction: widget.onSubmitCloseModalFunction,
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
                backgroundColor: Colors.transparent,
                color: _surveyThemeClass.answerColor,
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
                theme: _themeData),
          ],
        ),
      ),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchAlbum(token) async {
  var url1 =
      'http://sample.surveysparrow.test/api/internal/offline-app/v3/get-sdk-data/${token}';
  var url2 =
      'https://madbee.surveysparrow.com/api/internal/offline-app/v3/get-sdk-data/${token}';

  final response = await http.get(Uri.parse(url2));
  print('inital load called');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsedJson = jsonDecode(response.body);
    print('loaded parsed json ${parsedJson}');
    return parsedJson;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}