import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

/// Groq LLM Service — sends chat completions via the Groq API.
///
/// Uses the OpenAI-compatible endpoint with llama-3.3-70b-versatile.
/// Falls back gracefully when the device is offline.
class GroqService {
  static const String _apiKey = ApiKeys.groqApiKey;
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Check whether the device currently has internet access.
  static Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  /// Send a chat completion request to Groq.
  ///
  /// [systemPrompt] — the knowledge-base / persona instructions.
  /// [conversationHistory] — previous messages in OpenAI format
  ///   `[{"role":"user","content":"..."}, {"role":"assistant","content":"..."}]`
  /// [userMessage] — the latest user query.
  ///
  /// Returns the assistant reply text, or `null` on failure.
  static Future<String?> chat({
    required String systemPrompt,
    required List<Map<String, String>> conversationHistory,
    required String userMessage,
  }) async {
    try {
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 1024,
              'top_p': 0.9,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content'] as String?;
        }
      }
      // Non-200 or malformed response — caller falls back to rule-based.
      return null;
    } catch (_) {
      // Network timeout, DNS failure, etc.
      return null;
    }
  }
}
