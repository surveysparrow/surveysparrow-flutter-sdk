import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> payload) async {
  final Uri url = Uri.parse(
      'https://53b4-183-82-247-142.ngrok-free.app/api/internal/spotcheck/widget/tar-1/properties');

  try {
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic>? json = jsonDecode(response.body);
      log(json.toString());
      final bool? checkPassed = json?['checkPassed'] as bool?;
      final bool? show = json?['show'] as bool?;
      final int? spotCheckId = json?['spotCheckId'] as int?;
      if (show != null) {
        return {"valid": show, "spotCheckId": spotCheckId.toString()};
      } else if (checkPassed != null) {
        return {"valid": checkPassed, "spotCheckId": spotCheckId.toString()};
      } else {
        log('Error: Invalid Response Format');
        return {"valid": false};
      }
    } else {
      log('Error: ${response.statusCode}');
      return {"valid": false};
    }
  } catch (error) {
    log('Error: $error');
    return {"valid": false};
  }
}

String getCurrentDate() {
  return DateTime.now().toIso8601String();
}

Future<String?> fetchIPAddress() async {
  try {
    final response =
        await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['ip'];
    } else {
      print('Failed to fetch IP address: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching IP address: $e');
    return null;
  }
}

Future<double> getLatitude() async {
  try {
    final Position position = await _determinePosition();
    return position.latitude;
  } catch (e) {
    print('Error getting latitude: $e');
    return 0.0;
  }
}

Future<double> getLongitude() async {
  try {
    final Position position = await _determinePosition();
    return position.longitude;
  } catch (e) {
    print('Error getting longitude: $e');
    return 0.0;
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled.';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
  }
  return await Geolocator.getCurrentPosition();
}
