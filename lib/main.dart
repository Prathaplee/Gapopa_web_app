import 'package:Gapopa/screens/image_gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/imageprovidermodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageProviderModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ImageGalleryScreen(),
      ),
    );
  }
}