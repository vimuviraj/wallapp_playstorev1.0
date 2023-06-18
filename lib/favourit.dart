import 'dart:convert';

import 'package:natural_wallpaper_hd/wallpaper_Setitem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:natural_wallpaper_hd/category.dart';

class FavoriteProvider extends ChangeNotifier {
  List<WallpaperModel> favoriteImages = [];

  Future<void> init() async {
    await retrieveFavorites();
    notifyListeners();
  }

  Future<void> addToFavorites(WallpaperModel wallpaper) async {
    final isDuplicate = favoriteImages.any((item) => item.id == wallpaper.id);
    if (!isDuplicate) {
      favoriteImages.add(wallpaper);
      await saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(WallpaperModel wallpaper) async {
    favoriteImages.remove(wallpaper);
    await saveFavorites();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteImagesJson = json
        .encode(favoriteImages.map((wallpaper) => wallpaper.toJson()).toList());
    await prefs.setString('favoriteImages', favoriteImagesJson);
  }

  Future<void> retrieveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteImagesJson = prefs.getString('favoriteImages');
    print('favoriteImagesJson: $favoriteImagesJson');

    if (favoriteImagesJson != null) {
      try {
        final List<dynamic> favoriteImagesData =
            json.decode(favoriteImagesJson);
        favoriteImages = favoriteImagesData
            .map((data) => WallpaperModel(
                  id: data['id'],
                  imageUrl: data['imageUrl'],
                  title: data['title'],
                  author: data['author'],
                  isFavorite: data['isFavorite'],
                ))
            .toList();
      } catch (e) {
        // Handle parsing error
        print('Error parsing favoriteImagesJson: $e');
      }
    }
  }
}

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    // Initialize FavoriteProvider
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    favoriteProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Images'),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final List<WallpaperModel> favoriteImages =
              favoriteProvider.favoriteImages;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: favoriteImages.length,
            itemBuilder: (context, index) {
              final wallpaper = favoriteImages[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallpaperItem(
                        wallpaper: wallpaper,
                        wallpapers: favoriteImages,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: GridTile(
                  child: Image.network(
                    wallpaper.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
