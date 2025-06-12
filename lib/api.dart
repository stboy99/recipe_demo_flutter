import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    // Map<String, dynamic>? body,
    // bool requiresAuth = true,
  }) async {
    final apiUrl = endpoint;
    // final headers = {
    //   'accept': 'application/json',
    //   'Content-Type': 'application/json',
    // };

    try {
      final uri = Uri.parse(apiUrl);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri);
          break;
        // case 'POST':
        //   response = await http.post(
        //     uri,
        //     headers: headers,
        //     body: jsonEncode(body),
        //   );
        //   break;
        // case 'PATCH':
        //   response = await http.patch(
        //     uri,
        //     headers: headers,
        //     body: jsonEncode(body),
        //   );
        //   break;
        // case 'DELETE':
        //   response = await http.delete(uri, headers: headers);
        //   break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
}

Future<List<Map<String, dynamic>>> fetchNearbyGroceryStores({
  required double lat,
  required double lng,
  required String apiKey,
}) async {
 final response =  await _makeRequest(method: 'GET', endpoint: 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    '?location=$lat,$lng'
    '&radius=3000'
    '&type=grocery_or_supermarket'
    '&key=$apiKey');


  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  } else {
    throw Exception('Failed to load places: ${response.body}');
  }
}


// Future<List<Map<String, dynamic>>> fetchDeepSeekRecipeSuggestions({
//   required String mealType,
// }) async {
//   final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
//   final prompt = '''
// You are a smart recipe assistant.
// Suggest 5 new $mealType recipes they might enjoy. Each recipe should include:
// - Name
// - One-line description
// - Tags like "Quick", "High Protein", "Vegan", etc.

// Return your response as valid JSON: a list of recipe objects.
// ''';

//   final response = await http.post(
//     Uri.parse("https://api.deepseek.com/v1/chat/completions"),
//     headers: {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $apiKey",
//     },
//     body: jsonEncode({
//       "model": "deepseek-chat",
//       "messages": [
//         {"role": "system", "content": "You are a helpful assistant."},
//         {"role": "user", "content": prompt}
//       ],
//       "temperature": 0.7
//     }),
//   );

//   if (response.statusCode == 200) {
//     final body = jsonDecode(response.body);
//     final content = body['choices'][0]['message']['content'];

//     // Assumes content is a JSON list of recipes
//     return List<Map<String, dynamic>>.from(jsonDecode(content));
//   } else {
//     throw Exception('DeepSeek API failed: ${response.statusCode} ${response.body}');
//   }
// }
