
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PixabayService {
  final Dio _dio = Dio();
  final String _apiKey = '45946242-6d987e76f7e1486af8b10848a';

  Future<List<dynamic>> fetchImages(String query, int page) async {
    const int perPage = kIsWeb ? 65 : 20; // Fetch more images on web

    try {
      final response = await _dio.get('https://pixabay.com/api/', queryParameters: {
        'key': _apiKey,
        'q': query,
        'image_type': 'photo',
        'per_page': perPage,
        'page': page,
      });
      return response.data['hits'];
    } catch (e) {
      print('Error fetching images: $e');
      if (e is DioException) {
        print('Dio error: ${e.response?.data}');
      }
      return [];
    }

  }
}
