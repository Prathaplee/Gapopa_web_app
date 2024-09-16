import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PixabayService {
  // Dio instance to handle HTTP requests
  final Dio _dio = Dio();

  // API key for authenticating requests
  final String _apiKey = '45946242-6d987e76f7e1486af8b10848a';

  // Method to fetch images from the Pixabay API
  Future<List<dynamic>> fetchImages(String query, int page) async {
    // Number of images to fetch per page, different for web and mobile
    const int perPage = kIsWeb ? 65 : 20; // Fetch more images on web

    try {
      // Making a GET request to the Pixabay API
      final response = await _dio.get(
        'https://pixabay.com/api/', // API endpoint
        queryParameters: {
          'key': _apiKey, // API key for authentication
          'q': query, // Search query
          'image_type': 'photo', // Type of media to fetch
          'per_page': perPage, // Number of images per page
          'page': page, // Page number for pagination
        },
      );

      // Return the list of image hits from the response data
      return response.data['hits'];
    } catch (e) {
      // Print error message to the console
      print('Error fetching images: $e');

      // Additional error handling for DioException
      if (e is DioException) {
        print('Dio error: ${e.response?.data}');
      }

      // Return an empty list in case of an error
      return [];
    }
  }
}
