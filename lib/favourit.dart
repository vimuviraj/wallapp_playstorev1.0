import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFavorite with ChangeNotifier {
  final List<String> _myFavorites = [];

  List<String> get myFavorites => _myFavorites;

  void addImageUrl(String imageUrl) {
    _myFavorites.add(imageUrl);
    notifyListeners();
  }
}

class FavoriteImages extends StatelessWidget {
  const FavoriteImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyFavorite>(
      builder: (context, myFavorite, _) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: myFavorite.myFavorites.length,
          itemBuilder: (context, index) {
            String imageUrl = myFavorite.myFavorites[index];
            return Image.network(
                imageUrl); // Replace with appropriate widget for your image source
          },
        );
      },
    );
  }
}
