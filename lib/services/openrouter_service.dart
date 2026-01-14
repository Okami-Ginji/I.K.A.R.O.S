import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  final String apiKey;
  final String model;

  OpenRouterService({
    required this.apiKey,
    this.model = 'openai/gpt-oss-120b:free',
  });

  Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String systemPrompt,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']?['message'] ?? 'OpenRouter error');
    }

    return data['choices'][0]['message']['content'];
  }
}
