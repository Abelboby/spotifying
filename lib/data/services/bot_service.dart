import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bot_status.dart';
import '../../core/constants/app_constants.dart';

class BotService {
  final String baseUrl;
  final http.Client _client;

  BotService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.botApiBaseUrl;

  Future<BotStatus> getStatus() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/status'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return BotStatus.fromJson(json);
      }
      return BotStatus.initial().copyWith(state: BotState.error);
    } catch (e) {
      return BotStatus.initial().copyWith(state: BotState.error);
    }
  }

  Future<bool> reinitialize() async {
    try {
      final response = await _client.post(Uri.parse('$baseUrl/reinitialize'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> testBot() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': AppConstants.botTestMessage,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
