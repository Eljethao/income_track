import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:income_track/config/config.dart';

class ApiService {
  // Create Outcome
  static Future<void> createOutcome({
    required double amount,
    required String description,
    required String categoryImage,
    String? categoryName,
    required String user,
  }) async {
    final url = Uri.parse('$ENDPOINT_URL/v1/api/outcomes');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "user": user
      },
      body: jsonEncode({
        'amount': amount,
        'description': description,
        'categoryImage': categoryImage,
        'categoryName': categoryName,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create outcome: ${response.body}');
    }
  }

  static Future<void> updateOutcome(
    String id, {
    required double amount,
    required String description,
    required String categoryImage,
    String? categoryName,
    required String user,
  }) async {
    final url = Uri.parse('$ENDPOINT_URL/v1/api/outcomes/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'user': user,
      },
      body: jsonEncode({
        'amount': amount,
        'description': description,
        'categoryImage': categoryImage,
        'categoryName': categoryName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update outcome: ${response.body}');
    }
  }

}
