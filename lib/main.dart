import 'package:flutter/material.dart';
import 'package:gallery_view/gallery_view.dart';

void main() {
  runApp(GalleryGridScreen());
}

class GalleryGridScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<GalleryGridScreen> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
        ),
        body: GalleryView(crossAxisCount: 2, imageUrlList: [
          "https://upload.wikimedia.org/wikipedia/en/b/b9/Rich_Dad_Poor_Dad.jpg",
          "https://upload.wikimedia.org/wikipedia/commons/5/59/DualShock_4.jpg",
          "https://upload.wikimedia.org/wikipedia/en/a/a5/Grand_Theft_Auto_V.png"
        ]),
      ),
    );
  }
}
