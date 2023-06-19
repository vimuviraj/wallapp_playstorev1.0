import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:natural_wallpaper_hd/wallpaper_Setitem.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<WallpaperModel> _searchResults = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _performSearch(_searchController.text, resetResults: true);
              },
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search wallpapers',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  _performSearch(query, resetResults: true);
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchResults.clear();
                  });
                },
              ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (_currentPage < _totalPages) {
              _performSearch(_searchController.text);
            }
          }
          return false;
        },
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final wallpaper = _searchResults[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => WallpaperItem(
                            wallpaper: wallpaper,
                            wallpapers: _searchResults,
                            initialIndex: index))));
              },
              child: GridTile(
                child: Image.network(
                  wallpaper.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _performSearch(String query, {bool resetResults = false}) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    if (resetResults) {
      _currentPage = 1;
      _searchResults.clear();
    }

    const String apiKey = 'GvhIKoKCG3rKEXvAIUJgvfql1AXfPwUu-e9Ded92a2Q';
    const String baseUrl = 'https://api.unsplash.com';
    const String path = '/search/photos';
    final String url =
        '$baseUrl$path?query=$query&client_id=$apiKey&page=$_currentPage';

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];

      _totalPages = jsonData['total_pages'];

      setState(() {
        _searchResults.addAll(results.map((data) => WallpaperModel(
              id: data['id'],
              imageUrl: data['urls']['regular'],
              title: data['description'] ?? '',
              author: data['user']['name'],
              isFavorite: false,
            )));
      });

      _currentPage++;
    } else {
      setState(() {
        _searchResults = [];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}
