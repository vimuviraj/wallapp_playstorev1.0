import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WallpaperApp1 extends StatefulWidget {
  const WallpaperApp1({super.key});

  @override
  _WallpaperAppState createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp1> {
  List<String> wallpaperUrls = [];

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    const apiKey = 'WTeUI0tcdc76tVayvNnT83opsSQqji3b6OGin7QspkccIMsKewt9joAA';
    const url =
        'https://api.pexels.com/v1/search?query=4k+wallpapers&per_page=10';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final photos = jsonData['photos'] as List<dynamic>;

      setState(() {
        wallpaperUrls =
            photos.map((photo) => photo['src']['original'] as String).toList();
      });

      wallpaperUrls.forEach((url) async {
        final imageResponse = await http.get(Uri.parse(url));

        if (imageResponse.statusCode == 200) {
          final imageBytes = imageResponse.bodyBytes;
          final imageSize =
              (imageBytes.lengthInBytes / 1024).toStringAsFixed(2);
          final imageQuality =
              (imageBytes.lengthInBytes / 1024 / 1024).toStringAsFixed(2);
          print('Image quality: $imageQuality MB, Size: $imageSize KB');
        } else {
          print(
              'Failed to fetch image. Status code: ${imageResponse.statusCode}');
        }
      });
    } else {
      print('Failed to fetch wallpapers. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Wallpaper App'),
        ),
        body: ListView.builder(
          itemCount: wallpaperUrls.length,
          itemBuilder: (context, index) {
            final wallpaperUrl = wallpaperUrls[index];
            return Image.network(wallpaperUrl);
          },
        ),
      ),
    );
  }
}
