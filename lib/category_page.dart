import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:natural_wallpaper_hd/wallpaper_Setitem.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<WallpaperModel> wallpapers = [];
  late String currentCategory;
  int page = 1;

  Future<List<WallpaperModel>> fetchWallpapers(
      String category, int page) async {
    if (category == 'animals' ||
        category == 'places' ||
        category == 'buildings' ||
        category == 'backgrounds') {
      return fetchPixabayWallpapers(category, page);
    } else {
      return fetchPexelsWallpapers(category, page);
    }
  }

  Future<List<WallpaperModel>> fetchPixabayWallpapers(
      String category, int page) async {
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=37019221-c658bd28d15f87345edd3c1b6&category=$category&orientation=vertical&per_page=20&q=nature&image_type=photo&min_width=1920&min_height=1080&page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> images = responseData['hits'];

      return images.map((data) {
        final id = data['id'].toString();
        final imageUrl = data['largeImageURL'].toString();
        final author = data['user'].toString();
        final title = data['title'].toString();

        return WallpaperModel(
            id: id,
            imageUrl: imageUrl,
            author: author,
            title: title,
            isFavorite: false);
      }).toList();
    } else {
      throw Exception('Failed to fetch wallpapers');
    }
  }

  Future<List<WallpaperModel>> fetchPexelsWallpapers(
      String category, int page) async {
    final response = await http.get(
      Uri.parse(
        'https://api.pexels.com/v1/search?query=$category&per_page=20&page=$page&size=medium',
      ),
      headers: {
        'Authorization':
            'WTeUI0tcdc76tVayvNnT83opsSQqji3b6OGin7QspkccIMsKewt9joAA', // Replace with your Pexels API key
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> photos = responseData['photos'];

      return photos.map((data) {
        final id = data['id'].toString();
        final imageUrl = data['src']['large'].toString();
        final author = data['photographer'].toString();
        final title = data['url'].toString();

        return WallpaperModel(
            id: id,
            imageUrl: imageUrl,
            author: author,
            title: title,
            isFavorite: false);
      }).toList();
    } else {
      throw Exception('Failed to fetch wallpapers');
    }
  }

  Future<void> loadMoreWallpapers() async {
    final List<WallpaperModel> newWallpapers =
        await fetchWallpapers(currentCategory, page);
    setState(() {
      wallpapers.addAll(newWallpapers);
      page++;
    });
  }

  @override
  void initState() {
    super.initState();
    currentCategory = widget.title;
    fetchWallpapers(currentCategory, page).then((wallpapers) {
      setState(() {
        this.wallpapers = wallpapers;
        page++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {
                  loadMoreWallpapers();
                }
                return false;
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount:
                    wallpapers.length + 1, // Add 1 for the additional item
                itemBuilder: (BuildContext context, int index) {
                  if (index < wallpapers.length) {
                    final wallpaper = wallpapers[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WallpaperItem(
                                wallpaper: wallpaper,
                                wallpapers: wallpapers,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            wallpaper.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ));
                  } else {
                    // Show a loading indicator while loading more wallpapers
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
