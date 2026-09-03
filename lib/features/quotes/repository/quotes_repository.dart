import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/quote.dart';

/// Wraps the Quotable REST API. Kept isolated so swapping providers later
/// (or adding caching) only touches this one file.
class QuotesRepository {
  static const _baseUrl = 'https://api.quotable.io';

  Future<Quote> fetchRandomQuote() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/random?tags=motivational|education'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch quote (status ${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Quote.fromJson(json);
  }
}