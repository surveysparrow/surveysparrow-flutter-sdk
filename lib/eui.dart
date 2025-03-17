import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:surveysparrow_flutter_sdk/components/common/bottomNavigation.dart';
import 'package:surveysparrow_flutter_sdk/components/common/cxEmailForm.dart';
import 'package:surveysparrow_flutter_sdk/components/common/footer.dart';
import 'package:surveysparrow_flutter_sdk/components/common/header.dart';
import 'package:surveysparrow_flutter_sdk/components/loadingScreen.dart';
import 'package:surveysparrow_flutter_sdk/components/thankyou.dart';
import 'package:surveysparrow_flutter_sdk/components/welcome.dart';
import 'package:surveysparrow_flutter_sdk/constants/survey.dart';
import 'package:surveysparrow_flutter_sdk/helpers/cx.dart';
import 'package:surveysparrow_flutter_sdk/helpers/question.dart';
import 'package:surveysparrow_flutter_sdk/logics/displayLogic.dart';
import 'package:surveysparrow_flutter_sdk/logics/thankYou.dart';
import 'package:surveysparrow_flutter_sdk/models/customSurveyTheme.dart';
import 'package:surveysparrow_flutter_sdk/models/firstQuestionAnswer.dart';
import 'package:surveysparrow_flutter_sdk/models/theme.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:surveysparrow_flutter_sdk/providers/navigation_provider.dart';
import 'package:surveysparrow_flutter_sdk/providers/survey_provider.dart';
import 'helpers/answers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:surveysparrow_flutter_sdk/providers/answer_provider.dart';

class SurveyModal extends StatelessWidget {
  final String token;
  final String domain;
  final String? email;
  final Map<String, String>? variables;
  final FirstQuestionAnswer? firstQuestionAnswer;
  final CustomSurveyTheme? customSurveyTheme;
  final Function? onNext;
  final Function? onSubmit;
  final Map<dynamic, dynamic>? survey;
  final Function? onError;
  var lastQuestion = {};

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
    this.email,
  }) : super(key: key);

  late Future<Map<dynamic, dynamic>> testeru = fetchSurvey(token, domain);

  @override
  Widget build(BuildContext context) {
    if (survey != null) {
      return Sizer(
        builder: (context, orientation, deviceType) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WorkBench()),
              ChangeNotifierProvider(create: (_) => SurveyProvider()),
              ChangeNotifierProvider(create: (_) => NavigationState())
            ],
            child: QuestionsPage(
              token: token,
              domain: domain,
              Questions: survey!,
              customParams: variables ?? {},
              firstQuestionAnswer: firstQuestionAnswer,
              onNext: onNext,
              onSubmit: onSubmit,
              euiTheme: customSurveyTheme?.toMap() ?? {},
              onError: onError,
              email: email,
              lastQuestion: lastQuestion,
            ),
          );
        },
      );
    }

    checkValidSurveyType(type) {
      if (type == 'ClassicForm' ||
          type == 'NPS' ||
          type == 'CES' ||
          type == 'CSAT') {
        return true;
      }
      return false;
    }

    return Container(
      child: FutureBuilder(
        future: testeru,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['sections'].length == 0) {
              if (onError != null) {
                onError!("No questions added");
              }
              throw Exception('No question is added');
            } else if (snapshot.data['survey_type'] != null &&
                !checkValidSurveyType(snapshot.data['survey_type'])) {
              if (onError != null) {
                onError!(
                    'Un Supported Survey Type ${snapshot.data['survey_type']}');
              }
              throw Exception('Un Supported Survey Type');
            } else {
              if(snapshot.data['sections'].length > 0) {
                var lastSection = snapshot.data['sections'][snapshot.data['sections'].length - 1];
                if(lastSection['questions'].length > 0) {
                  lastQuestion = lastSection['questions'][lastSection['questions'].length - 1];
                }
              }
              try {
                var surveyWidgetToRender = Sizer(
                  builder: (context, orientation, deviceType) {
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => WorkBench()),
                        ChangeNotifierProvider(create: (_) => SurveyProvider()),
                        ChangeNotifierProvider(create: (_) => NavigationState())
                      ],
                      child: QuestionsPage(
                        token: token,
                        domain: domain,
                        Questions: snapshot.data,
                        customParams: variables ?? {},
                        firstQuestionAnswer: firstQuestionAnswer,
                        onNext: onNext,
                        onSubmit: onSubmit,
                        euiTheme: customSurveyTheme?.toMap() ?? {},
                        onError: onError,
                        email: email,
                        lastQuestion: lastQuestion,
                      ),
                    );
                    // return QuestionsPage(
                    //   token: this.token,
                    //   domain: this.domain,
                    //   Questions: snapshot.data,
                    //   customParams: variables ?? {},
                    //   firstQuestionAnswer: firstQuestionAnswer,
                    //   onNext: onNext,
                    //   onSubmit: onSubmit,
                    //   euiTheme: customSurveyTheme?.toMap() ?? {},
                    //   onError: this.onError,
                    // );
                  },
                );
                return surveyWidgetToRender;
              } catch (e) {
                print("some error has happened inside survey modal $e");
              }
            }
          }

          if (snapshot.hasError) {
            if (onError != null) {
              onError!("${snapshot.error}");
            }
            throw Exception(snapshot.error);
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
  final String? email;
  final Map<dynamic, dynamic> Questions;
  final Map<String, String> customParams;
  final FirstQuestionAnswer? firstQuestionAnswer;
  final Function? onNext;
  final Function? onSubmit;
  final Map<dynamic, dynamic>? euiTheme;
  final Function? onSubmitCloseModalFunction;
  final Function? onError;
  final Map<dynamic, dynamic>? lastQuestion;

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
      this.email,
      this.onError,
      this.lastQuestion})
      : super(key: key);

  @override
  State<QuestionsPage> createState() => _QuestionsPageState(
      token, Questions, customParams, firstQuestionAnswer, onError);
}

class _QuestionsPageState extends State<QuestionsPage>
    with TickerProviderStateMixin {
  final String token;
  final Map<dynamic, dynamic> Survey;
  final Map<String, String> customParams;
  final Function? onError;
  final Map<dynamic, dynamic> _questionPos = {};
  final Map<dynamic, dynamic> _surveyToMap = {};
  final FirstQuestionAnswer? firstQuestionAnswer;
  _QuestionsPageState(this.token, this.Survey, this.customParams,
      this.firstQuestionAnswer, this.onError);
  final List<Map<dynamic, dynamic>> _allQuestionList = [];
  final List _allowedQuestionIds = [];
  Map<dynamic, dynamic> _workBench = {};
  final Map<dynamic, dynamic> _themeData = {};
  Map<dynamic, dynamic> _lastQuestion = {};
  dynamic _hasThankYouLogicSkip = false;
  var _surveyThemeClass;
  int _currentQuestionNumber = 1;
  Map<dynamic, dynamic> _currentQuestionToRender = {};
  final List<Map<dynamic, dynamic>> _collectedAnswers = [];
  Timer? _debounce;

  int _pageNumber = 0;
  double _progressMade = 0.0;
  final int _answeredCount = 0;
  List<Widget> questionList = List<Widget>.empty(growable: true);

  int _scrollCountTop = 0;
  int _scrollCountBottom = 0;

  // nxt-20
  bool blockNextButton = false;

  final allowedQuestionTypes = allowedQuestions;

  storePrefilledAnswers() {
    var workBenchDatas = getPrefilledAnswers(firstQuestionAnswer,
        createAnswerPayload, _collectedAnswers, _surveyToMap, onError);

    if (mounted) {
      setState(() {
        _workBench = workBenchDatas;
      });
    }
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
    bool isLastQuestionSubmission = true,
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

    var cloneWorkBench = {..._workBench};

    var newWorkBench = getWorkBenchData(
      cloneWorkBench,
      key,
      value,
      otherInputText,
      _answeredCount,
      otherInput,
      isPhoneInput,
      phoneValue,
    );

    context.read<WorkBench>().setWorkBenchData(newWorkBench);

    if (mounted) {
      setState(() {
        _workBench = {...newWorkBench};
      });
    }
    widget.onNext!(_collectedAnswers);
    if (isLastQuestionSubmission == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNextQuestion(changePage: changePage);
      });
    }
  }

  submitData() async {
    if (hasThankYouPage) {
      if (mounted) {
        setState(() {
          _pageType = 'thankYou';
        });
      }
    } else {
      widget.onSubmit!(_collectedAnswers);
    }

    var email = context.read<SurveyProvider>().getEmail;

    if (widget.email != null) {
      email = widget.email!;
    }
    var data = await submitAnswer(
        _collectedAnswers,
        (_stopwatch.elapsedMilliseconds / 1000).round(),
        customParams,
        token,
        widget.domain,
        email,
        Survey["isSubmissionQueued"]);
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
        Uri.parse('https://$domain/api/internal/sdk/increment-count/$token');
    final response = await http.get(url);
  }

  @override
  initState() {
    super.initState();
    incrementCount(token, widget.domain);

    context.read<SurveyProvider>().setSurvey(Survey);

    if (widget.euiTheme!['animationDirection'] != null) {
      if (widget.euiTheme!['animationDirection'] == "horizontal") {
        isVertical = true;
      }
    }

    if (Survey['welcome_rtxt'] != null) {
      hasWelcomePage = true;
      welcomePageDetails = Survey['welcome_rtxt'];
      welcomeButtonDesc = Survey['welcomeScreenYesButtonText'];
      welcomeDesc = Survey['welcomeDescription'];
      welcomeEntity = Survey['welcome_rtxt']['entityMap'] ?? {};
    }

    //scroll controller
    _scrollControler = ScrollController();
    _scrollControler.addListener(_scrollListener);

    // starting the timer for stopwatch
    _stopwatch = Stopwatch();
    _stopwatch.start();

    if (Survey['surveyTheme'] != null) {
      _surveyThemeClass = SurveyThemeData.fromJson(json: Survey['surveyTheme']);
    } else {
      _surveyThemeClass = SurveyThemeData.fromJson();
    }

    setTheme(_themeData, _surveyThemeClass);

    var index = 0;
    for (var section in Survey['sections']) {
      for (var question in section['questions']) {
        if (allowedQuestionTypes.contains(question['type'])) {
          _questionPos[question['id']] = index;
          _surveyToMap[question['id']] = question;
          var listSubQuestions = [];
          if (question['subQuestions'] != null) {
            listSubQuestions = (question['subQuestions'] as List)
                .map((e) => e as Map<dynamic, dynamic>)
                .toList();
          }
          if (listSubQuestions.isNotEmpty) {
            var subQuestion = listSubQuestions[0];
            _surveyToMap[subQuestion['id']] = subQuestion;
          }
          _allQuestionList.add(question);
          _allowedQuestionIds.add(question['id']);
          index = index + 1;
        }
      }
    }
    if (index == 0) {
      onError!('No supported question is added');
      throw Exception('No supported question is added');
    }

    if (Survey['welcome_rtxt'] == null) {
      if (firstQuestionAnswer != null) {
        storePrefilledAnswers();
      }

      if (mounted) {
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
              widget.euiTheme,
              toggleNextButtonBlock);
          _currentQuestionToRender = _allQuestionList[_pageNumber];
        });
      }
    }

    if (Survey['thankyou_json'].length > 0) {
      hasThankYouPage = true;
      thankYouPageJson = checkThankYouLogics(
          Survey['thankyou_json'], _workBench, _hasThankYouLogicSkip);
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
    List<Map<dynamic, dynamic>> questionsToConvert = [];
    var questionArrayToConvert = [];
    var currentQuestionIndex = _allQuestionList[0]['id'];

    do {
      questionArrayToConvert.add(currentQuestionIndex);
      var evaluatedLogics = handleDisplayLogic(currentQuestionIndex,
          _allQuestionList, _allowedQuestionIds, _workBench, _questionPos);
      currentQuestionIndex = evaluatedLogics[0];

      if (evaluatedLogics[1] is String && evaluatedLogics[1] != false) {
        _hasThankYouLogicSkip = evaluatedLogics[1];
      }
    } while (currentQuestionIndex != null);

    for (var question in questionArrayToConvert) {
      questionsToConvert.add(_surveyToMap[question]);
    }

    if (mounted) {
      setState(() {
        _lastQuestion = questionsToConvert.last;
      });
    }

    if (changePage) {
      if (hadleNextSelect == true) {
        if (hasCustomOffset) {
          if (_pageNumber + customOffsetNumber < questionsToConvert.length) {
            _currentQuestionNumber =
                _currentQuestionNumber + customOffsetNumber;
            if (mounted) {
              setState(() {
                _currentQuestionToRender =
                    questionsToConvert[_pageNumber + customOffsetNumber];
              });
            }
          }
        } else {
          if (_pageNumber + 1 < questionsToConvert.length) {
            _currentQuestionNumber = _currentQuestionNumber + 1;
            if (mounted) {
              setState(() {
                _currentQuestionToRender = questionsToConvert[_pageNumber + 1];
              });
            }
          }
        }
      }

      if (hadleNextSelect == false) {
        if (_pageNumber > 0) {
          _currentQuestionNumber = _currentQuestionNumber - 1;
          if (mounted) {
            setState(() {
              _currentQuestionToRender = questionsToConvert[_pageNumber - 1];
            });
          }
        }
      }
    }

    if(! _workBench.containsKey(_currentQuestionToRender['id']) ) {
      if( _currentQuestionToRender['required'] == true ) {
        context.read<NavigationState>().toggleBlockNavigationDown(true);
      } else {
        context.read<NavigationState>().toggleBlockNavigationDown(false);
      }
    } else {
      if( _currentQuestionToRender['required'] == false ) {
        context.read<NavigationState>().toggleBlockNavigationDown(false);
      }
    }

    if( _currentQuestionToRender['type'] == 'PhoneNumber' &&  _currentQuestionToRender['required'] == true ) {
      if( _workBench.containsKey( _currentQuestionToRender['id'] ) ) { 
        context.read<NavigationState>().toggleBlockNavigationDown(false);
      } else {
        context.read<NavigationState>().toggleBlockNavigationDown(true);
      }
    }

    if(widget.lastQuestion != null) {
      if(widget.lastQuestion?['id'] == _currentQuestionToRender['id']) {
        context.read<NavigationState>().toggleBlockNavigationDown(true);
      }
    }

    if (mounted) {
      setState(() {
        questionList = convertQuestionListToWidget(
            questionsToConvert,
            _currentQuestionToRender,
            storeAnswers,
            _workBench,
            _themeData,
            customParams,
            _currentQuestionNumber,
            submitData,
            _lastQuestion,
            _scrollControler,
            widget.euiTheme,
            toggleNextButtonBlock);
        _progressMade =
            (_collectedAnswers.length / questionsToConvert.length).toDouble();
      });
    }
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

    if (_currentQuestionToRender['required'] != null &&
        _currentQuestionToRender['required'] == true) {
      var hasFeedBackQuestion =
          checkIfTheQuestionHasAFeedBack(_currentQuestionToRender);
      if (hasFeedBackQuestion) {
        var feedBackQuestion = getFeedBackQuestion(_currentQuestionToRender);
        var feedBackQuestionId = feedBackQuestion['id'];
        var conditionToCheck = _workBench[feedBackQuestionId] == null ||
            _workBench[_currentQuestionToRender['id']] == null;
        var isFeedBackQuestionRequired = feedBackQuestion['required'];
        if (!isFeedBackQuestionRequired) {
          conditionToCheck = _workBench[_currentQuestionToRender['id']] == null;
        }
        if (conditionToCheck) {
          canUpdateQuestions = false;
        } else {
          canUpdateQuestions = true;
        }
      } else {
        if (_workBench[_currentQuestionToRender['id']] == null) {
          canUpdateQuestions = false;
        } else {
          canUpdateQuestions = true;
        }
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
            if (mounted) {
              setState(() {
                _pageNumber = updatedPageNumber;
              });
            }
            controller.animateToPage(updatedPageNumber,
                duration: Duration(milliseconds: time), curve: Curves.easeIn);
          }
        } else {
          if (_pageNumber + 1 < questionList.length) {
            var updatedPageNumber = _pageNumber + 1;
            if (mounted) {
              setState(() {
                _pageNumber = updatedPageNumber;
              });
            }
            controller.animateToPage(updatedPageNumber,
                duration: Duration(milliseconds: time), curve: Curves.easeIn);
          }
        }
      }
    }
  }

  _handlePreviousQuestion() {
    generateQuestionList(false);
    if (_pageNumber != 0) {
      var updatedPageNumber = _pageNumber - 1;
      if (mounted) {
        setState(() {
          _pageNumber = updatedPageNumber;
        });
      }
      controller.animateToPage(updatedPageNumber,
          duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
    }
  }

  final PageController controller = PageController(initialPage: 0);

  var _pageType = "welcome";

  setPageType(val) {
    if (mounted) {
      setState(() {});
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _pageType = val;
        });
      }
      if (firstQuestionAnswer != null) {
        storePrefilledAnswers();
      }
      if (mounted) {
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
              widget.euiTheme,
              toggleNextButtonBlock);
          _currentQuestionToRender = _allQuestionList[_pageNumber];
        });

        if( _currentQuestionToRender['id'] == _allQuestionList[0]['id'] ) {
          if( _currentQuestionToRender['required'] == true ) {
            context.read<NavigationState>().toggleBlockNavigationDown(true);
          } else {
            context.read<NavigationState>().toggleBlockNavigationDown(false);
          }
        }
      }
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

    var showEmailPage = Survey['survey_type'] == 'NPS' ||
        Survey['survey_type'] == 'CSAT' ||
        Survey['survey_type'] == 'CES';
    var email = context.watch<SurveyProvider>().getEmail;
    if (widget.email != null) {
      email = widget.email!;
    }

    if (showEmailPage && email == '') {
      return const CXEmailForm();
    }

    if (hasWelcomePage && _pageType == "welcome") {
      return Container(
        decoration: BoxDecoration(
          color: _surveyThemeClass.backgroundImage != 'noImage'
              ? _surveyThemeClass.backgroundImageColor
              : _surveyThemeClass.backgroundColor,
          gradient: _themeData['hasGradient']
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: const Alignment(0.8, 0.0),
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
              welcomePageData: welcomePageDetails,
              welcomeButtonDesc: welcomeButtonDesc,
              welcomeDesc: welcomeDesc,
              welcomeEntity: welcomeEntity,
              euiTheme: widget.euiTheme,
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
        return const SizedBox.shrink();
      }
      if (Survey['thankyou_json'].length > 0) {
        hasThankYouPage = true;
        thankYouPageJson = checkThankYouLogics(
            Survey['thankyou_json'], _workBench, _hasThankYouLogicSkip);
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
                  end: const Alignment(0.8, 0.0),
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
              thankYouPageData: welcomePageDetails,
              welcomeButtonDesc: welcomeButtonDesc,
              welcomeDesc: welcomeDesc,
              welcomeEntity: welcomeEntity,
              thankYouPageJson: thankYouPageJson,
              closeModalFunction: thankYouCloseFunction,
              euiTheme: widget.euiTheme,
              onError: widget.onError,
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
                  end: const Alignment(0.8, 0.0),
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
                const SizedBox(
                  height: 10,
                ),
              ]
            ],
            if (_themeData['hasHeader']) ...[
              HeaderSection(
                theme: _themeData,
                euiTheme: widget.euiTheme,
              ),
              const SizedBox(
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
                  physics: const NeverScrollableScrollPhysics(),
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
              euiTheme: widget.euiTheme,
              theme: _themeData,
            ),
            if (_themeData['hasFooter']) ...[
              FooterSection(
                theme: _themeData,
                euiTheme: widget.euiTheme,
              )
            ],
          ],
        ),
      ),
    );
  }
}

Future<Map<dynamic, dynamic>> fetchSurvey(token, domain) async {
  // if(token.startsWith('ntt') || token.startsWith('NTT')){
  //   throw Exception('Un Supported Survey Type');
  // }

  // check url before prod
  var url = 'https://$domain/api/internal/sdk/get-survey/$token';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final parsedJson = jsonDecode(response.body);
    return parsedJson;
  } else {
    print("response failed");
    throw Exception('Some Error Happened When Loading the Survey');
  }
}
// ntt-ppZdzAVc6rjmVjnqzFN67X