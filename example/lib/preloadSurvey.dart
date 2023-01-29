import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:surveysparrow_flutter_sdk/surveysparrow.dart';
 
Future<Map<dynamic, dynamic>> fetchSurvey() async {
 var domain = "sachin.pagesparrow.com"; // use your domain
 var token = "tt-o4dy7Qh8MSJjhASW8ccWXU"; // use your mobile sdk share token
 
 var url = 'https://${domain}/api/internal/sdk/get-survey/${token}';
 
 final response = await http.get(Uri.parse(url));
 if (response.statusCode == 200) {
   // If the server did return a 200 OK response,
   // then parse the JSON.
   final parsedJson = jsonDecode(response.body);
   return parsedJson;
 } else {
   // If the server did not return a 200 OK response,
   // then throw an exception.
   throw Exception('Failed to load survey');
 }
}
 
class PreLoadedSurveyScreen extends StatelessWidget {
 const PreLoadedSurveyScreen({
   Key? key,
 }) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("SurveySparrow"),
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: () => Navigator.of(context).pop(),
       ),
     ),
     body: FutureBuilder(
       future: fetchSurvey(),
       builder: (BuildContext context, AsyncSnapshot snapshot) {
         if (snapshot.hasData) {
           return Container(
             width: double.infinity,
             height: double.infinity,
             child: SurveyModal(
               token: 'tt-o4dy7Qh8MSJjhASW8ccWXU',
               domain: 'sachin.pagesparrow.com',
               variables: const {
                 "custom_name": "surveysparrow",
                 "custom_number": "2"
               },
               survey: snapshot.data,
               onNext: (val) {
                 print("Currently collected answer ${val} ");
               },
               onError: () {
                 Navigator.pop(context);
               },
               onSubmit: (val) {
                 print("All collected answer ${val} ");
                 Future.delayed(const Duration(milliseconds: 500), () {
                   Navigator.pop(context);
                 });
               },
             ),
           );
         } else {
           return Container(
             child: const Text("Loading"),
           );
         }
       },
     ),
   );
 }
}