import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotcheckApi {
  final String domainName;
  final String targetToken;

  SpotcheckApi({required this.domainName, required this.targetToken});

  /// Throws on failure so the caller reports it.
  Future<Map<String, dynamic>> getAllSpotcheckFunctions() async {
    final url = Uri.parse(
        'https://$domainName/api/internal/spotcheck/mobile/init?framework=flutter');
    // Bounded so a stalled request fails and the next track call can retry init.
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('mobile/init failed with status ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
