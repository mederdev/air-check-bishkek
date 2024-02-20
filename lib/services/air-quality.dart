import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAirQualityService {
  final String apiKey;

  GoogleAirQualityService._({required this.apiKey});

  static final GoogleAirQualityService _instance = GoogleAirQualityService._(
      apiKey: 'API_KEY');

  factory GoogleAirQualityService() => _instance;

  Future<Map<String, dynamic>?> getAirQualityData(
      double latitude, double longitude) async {
    final apiUrl =
        'https://airquality.googleapis.com/v1/history:lookup?key=$apiKey';

    try {
      http.Response response = await http.post(Uri.parse(apiUrl),
          body: json.encode({
            "hours": 4,
            "location": {"latitude": latitude, "longitude": longitude}
          }));

      if (response.statusCode != 200) {
        print('Failed to load air quality data: ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error fetching air quality data: $e');
      return null;
    }
  }
}
