import 'package:http/http.dart' as http;
import 'dart:typed_data';

Future<Uint8List> fetchImageBytes(String imageUrl) async {
  int retries = 3; // Number of retry attempts
  while (retries > 0) {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.bodyBytes; // Successfully fetched image
      } else {
        retries--; // Retry if the request fails
      }
    } catch (e) {
      retries--; // Retry on error
    }
    await Future.delayed(Duration(seconds: 2)); // Delay before retrying
  }
  throw Exception('Failed to load image after retries'); // Error after retries fail
}