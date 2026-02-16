import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Groq LLM Service — sends chat completions via the Groq API.
///
/// Uses the OpenAI-compatible endpoint with llama-3.3-70b-versatile.
/// The API key is stored in SharedPreferences so users can change it
/// at runtime without rebuilding the app.
class GroqService {
  static const String _prefKey = 'groq_api_key';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  // ── API key management ──────────────────────────────────
  /// Save a new API key to local storage.
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key.trim());
  }

  /// Get the currently stored API key, or null if none.
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_prefKey);
    return (key != null && key.trim().isNotEmpty) ? key.trim() : null;
  }

  /// Remove the stored API key.
  static Future<void> removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Returns true if an API key is configured.
  static Future<bool> hasApiKey() async {
    return (await getApiKey()) != null;
  }

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
      final apiKey = await getApiKey();
      if (apiKey == null) return null; // No key configured

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
              'Authorization': 'Bearer $apiKey',
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
