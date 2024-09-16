import 'package:Gapopa/service/pixbay_service.dart';
import 'package:flutter/material.dart';

class ImageProviderModel extends ChangeNotifier {
  // Service instance to handle API requests
  final PixabayService _pixabayService = PixabayService();

  // List to hold the images fetched from the API
  List<dynamic> _images = [];

  // Page number for pagination
  int _page = 1;

  // Flag to indicate if images are currently being loaded
  bool _isLoading = false;

  // Current search query
  String _query = 'nature';

  // Public getter for the list of images
  List<dynamic> get images => _images;

  // Public getter for the loading status
  bool get isLoading => _isLoading;

  // Method to search for images with a new query
  void searchImages(String query) {
    _query = query; // Update the query
    _page = 1; // Reset the page number
    _images.clear(); // Clear the existing images
    print('Fetching images for query: $_query'); // Debugging print statement
    fetchImages(); // Fetch images based on the new query
  }

  // Method to fetch images from the API
  Future<void> fetchImages() async {
    // If already loading, return early to prevent duplicate requests
    if (_isLoading) return;

    _isLoading = true; // Set loading flag
    notifyListeners(); // Notify listeners to update UI

    // Fetch new images from the service
    final newImages = await _pixabayService.fetchImages(_query, _page);

    // Check if any images were returned
    if (newImages.isNotEmpty) {
      _images.addAll(newImages); // Add new images to the list
      _page++; // Increment the page number for the next request
    }

    _isLoading = false; // Reset loading flag
    notifyListeners(); // Notify listeners to update UI
  }

  // Method to load more images (e.g., for pagination)
  void loadMoreImages() {
    fetchImages(); // Fetch more images
  }
}
