import 'package:Gapopa/service/pixbay_service.dart';
import 'package:flutter/material.dart';

class ImageProviderModel extends ChangeNotifier {
  final PixabayService _pixabayService = PixabayService();
  List<dynamic> _images = [];
  int _page = 1;
  bool _isLoading = false;
  String _query = 'nature';

  List<dynamic> get images => _images;
  bool get isLoading => _isLoading;

  void searchImages(String query) {
    _query = query;
    _page = 1;
    _images.clear();
    print('Fetching images for query: $_query'); // Debugging print statement
    fetchImages();
  }


  Future<void> fetchImages() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final newImages = await _pixabayService.fetchImages(_query, _page);
    if (newImages.isNotEmpty) {
      _images.addAll(newImages);
      _page++;
    }
    _isLoading = false;
    notifyListeners();
  }


  void loadMoreImages() {
    fetchImages();
  }
}
