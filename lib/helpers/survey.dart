import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<dynamic, dynamic>> handleSurveyValidation(token, domain) async {
  try {
    var apiUrl = 'https://${domain}/sdk/validate-survey/${token}';
    Map<String, String> data = {};
    var response = await http.post(Uri.parse(apiUrl), body: data);
    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      return parsedJson;
    } else {
      print("Response failed");
      throw Exception('Some Error Happened When validating the Survey');
    }
  } catch (e) {
    print("Response failed");
    throw Exception('Some Error Happened When validating the Survey');
  }
}
