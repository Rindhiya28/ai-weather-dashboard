// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Chrome/Web → localhost
  // Real Android device → http://192.168.1.35:8000
static const String _baseUrl = 'http://localhost:8000';
  static Future<List<double>> get7DayForecast() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/forecast'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['forecast_celsius']);
    } else {
      throw Exception('Forecast API failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getAnomalyStatus() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/anomaly'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Anomaly API failed: ${response.body}');
    }
  }
}