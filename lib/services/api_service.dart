import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<ExpenseCategory>> getCategories() async {
    final response = await http
        .get(Uri.parse('$baseUrl/experiment/mobile/expenseCategories.json'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> &&
          decoded['expenseCategories'] is List) {
        return (decoded['expenseCategories'] as List)
            .map((e) => ExpenseCategory.fromJson(e))
            .toList();
      }

      throw Exception('Unexpected JSON structure: $decoded');
    } else {
      throw Exception(
          'Failed to load categories (status: ${response.statusCode})');
    }
  }
}