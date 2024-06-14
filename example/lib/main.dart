import 'dart:developer';
import 'package:example/SpotCheckScreen.dart';
import 'package:example/customSurvey.dart';
import 'package:example/preloadSurvey.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

final SpotCheck spotCheck = SpotCheck(
    email: "gk@ss.com",
    firstName: "gokulkrishna",
    lastName: "raju",
    phoneNumber: "6383846825", 
    targetToken: "tar-r7Rea4VeHExU37nbeDB9md",
    domainName: 'rgk.ap.ngrok.io',
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SurveyScreen(),
    );
  }
}

class SurveyScreen extends StatelessWidget {
  SurveyScreen({
    Key? key,
  }) : super(key: key);
  final domainController = TextEditingController();
  final tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SurveySparrow"),
      ),
      body: Builder(
        builder: ((context) => Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Domain"),
                  TextField(
                    controller: domainController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Token"),
                  TextField(
                    controller: tokenController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: SizedBox(
                                width: double.infinity,
                                height: 500,
                                child: SurveyModal(
                                  // token: tokenController.text,
                                  // domain: domainController.text,
                                  domain: "gokulkrishnaraju1183.surveysparrow.com",
                                  token: "ntt-k63yoeobRWmuT5eZ3uHfrX",
                                  // email:"newemail@ee.com",
                                  onNext: (val) {
                                    log(
                                        "Currently collected answer $val ");
                                  },
                                  onError: (err) {
                                    log("GLOBAL ERROR IS HAPPENED $err ");
                                    Fluttertoast.showToast(
                                        msg: err,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  onSubmit: (val) {
                                    log("All collected answer $val ");
                                    Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      } catch (e) {
                        log("Global catch is handled");
                      }
                    },
                    child: const Text("open survey modal"),
                  ),
                  ElevatedButton(
                    onPressed: (() {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: const SizedBox(
                                height: 510,
                                child: (Page3()),
                              ),
                            );
                          });
                    }),
                    child: const Text("Open Custom Survey"),
                  ),
                  ElevatedButton(
                    onPressed: (() {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Container(
                                color: Colors.red,
                                height: 510,
                                child: (const PreLoadedSurveyScreen()),
                              ),
                            );
                          });
                    }),
                    child: const Text("Open Preloaded Page"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SpotCheckScreen(),
                          ),
                        );
                      },
                      child: const Text("SpotCheck"))
                ],
              ),
            )),
      ),
    );
  }
}
