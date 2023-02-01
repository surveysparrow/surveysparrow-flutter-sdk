import 'package:example/customSurvey.dart';
import 'package:example/customSurveyTheme.dart';
import 'package:example/preloadSurvey.dart';
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        title: Text("SurveySparrow"),
      ),
      body: Builder(
        builder: ((context) => Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Domain"),
                    TextField(
                      controller: domainController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Token"),
                    TextField(
                      controller: tokenController,
                    ),
                    SizedBox(
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
                                child: Container(
                                  width: double.infinity,
                                  height: 500,
                                  child: SurveyModal(
                                    token: tokenController
                                        .text, 
                                    domain: domainController
                                        .text,
                                    // token: "ntt-j26MfnfgMWxiSkmmzReUgp",
                                    // domain: "sachin.pagesparrow.com",
                                    // email:"newemail@ee.com",
                                    onNext: (val) {
                                      print(
                                          "Currently collected answer ${val} ");
                                    },
                                    onError: (err) {
                                      print("GLOBAL ERROR IS HAPPENED ${err} ");
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
                                      print("All collected answer ${val} ");
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
                          print("Global catch is handled");
                        }
                      },
                      child: Text("open survey modal"),
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
                                  height: 510,
                                  child: (Page3()),
                                ),
                              );
                            });
                      }),
                      child: Text("Open Custom Survey"),
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
                                  height: 510,
                                  child: (PreLoadedSurveyScreen()),
                                ),
                              );
                            });
                      }),
                      child: Text("Open Preloaded Page"),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
