import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchDeepSeekRecipeSuggestions({
  required String mealType,
}) async {
  final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
  final prompt = '''
You are a smart recipe assistant.
Suggest 5 new $mealType recipes they might enjoy. Each recipe should include:
- Name
- One-line description
- Tags like "Quick", "High Protein", "Vegan", etc.

Return your response as valid JSON: a list of recipe objects.
''';

  final response = await http.post(
    Uri.parse("https://api.deepseek.com/v1/chat/completions"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    },
    body: jsonEncode({
      "model": "deepseek-chat",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.7
    }),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final content = body['choices'][0]['message']['content'];

    // Assumes content is a JSON list of recipes
    return List<Map<String, dynamic>>.from(jsonDecode(content));
  } else {
    throw Exception('DeepSeek API failed: ${response.statusCode} ${response.body}');
  }
}
