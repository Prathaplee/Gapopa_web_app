import 'dart:async';
import 'package:Gapopa/model/imageprovidermodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final imageProvider =
      Provider.of<ImageProviderModel>(context, listen: false);
      // Fetch initial images when the widget is first built
      imageProvider.fetchImages();

      // Add listener to detect scroll position for lazy loading
      _scrollController.addListener(() {
        if (_scrollController.position.extentAfter < 100) { // Trigger when close to the bottom
          print('Loading more images...');
          imageProvider.loadMoreImages();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the search controller
    _scrollController.dispose(); // Clean up the scroll controller
    _debounce?.cancel(); // Cancel any pending debounce timers
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce the search input to avoid excessive API calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('Search Query: $query'); // Debug log for search query
      Provider.of<ImageProviderModel>(context, listen: false).searchImages(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageProviderModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text('Gapopa'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search Images...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: imageProvider.isLoading && imageProvider.images.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 150).floor(),
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: imageProvider.images.length +
                  (imageProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show a loading indicator if we are fetching more images
                if (index == imageProvider.images.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final image = imageProvider.images[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(image: image),
                    ),
                  ),
                  child: GridTile(
                    footer: Container(
                      color: Colors.black45, // Background color for footer
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Add padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space items evenly
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.thumb_up, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text('${image['likes']}', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.visibility, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text('${image['views']}', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image['webformatURL'],
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final dynamic image;

  const FullScreenImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the full screen view when tapped
        },
        child: Center(
          child: Hero(
            tag: image['id'], // Use the image id for the hero animation
            child: CachedNetworkImage(
              imageUrl: image['largeImageURL'],
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
