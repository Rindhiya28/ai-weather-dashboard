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
    }
    throw Exception('Forecast API failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> getAnomalyStatus() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/anomaly'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Anomaly API failed: ${response.body}');
  }

  // ── NEW: GenAI chat endpoint ──────────────────────────────────────────────
  static Future<String> sendChatMessage(String message) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] as String;
    }
    throw Exception('Chat API failed: ${response.body}');
  }
}