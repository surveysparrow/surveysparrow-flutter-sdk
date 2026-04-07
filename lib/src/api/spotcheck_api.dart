import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotcheckApi {
  final String domainName;
  final String targetToken;

  SpotcheckApi({required this.domainName, required this.targetToken});

  Future<Map<String, dynamic>?> getAllSpotcheckFunctions() async {
    try {
      final url = Uri.parse(
          'https://$domainName/api/internal/spotcheck/mobile/init?framework=flutter');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
