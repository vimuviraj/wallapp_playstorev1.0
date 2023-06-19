import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:natural_wallpaper_hd/category_page.dart';
import 'package:natural_wallpaper_hd/search_page.dart';
import 'package:natural_wallpaper_hd/wallpaper_Setitem.dart';
import 'navigationdrawer.dart';

class WallpaperApp extends StatefulWidget {
  const WallpaperApp({Key? key}) : super(key: key);

  @override
  _WallpaperAppState createState() => _WallpaperAppState();
}

class _WallpaperAppState extends State<WallpaperApp>
    with SingleTickerProviderStateMixin {
  List<String> categories = ['CATEGORIES', 'POPULAR', 'RANDOM', 'LATEST'];
  String currentCategory = 'POPULAR';
  Map<String, List<WallpaperModel>> categoryWallpapers = {};
  late TabController _tabController;
  Map<String, int> currentPageMap = {};
  Map<String, bool> isLoadingMap = {};

  Future<List<WallpaperModel>> fetchWallpapers(
      String category, int page) async {
    final response = await http.get(
      Uri.https(
        'api.unsplash.com',
        '/photos',
        {
          'client_id': 'GvhIKoKCG3rKEXvAIUJgvfql1AXfPwUu-e9Ded92a2Q',
          'order_by': category,
          'page': page.toString(),
          'orientation': 'portrait',
          'resolution': 'full',
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final wallpapers = responseData.map((data) {
        final id = data['id'].toString();
        final imageUrl = data['urls']['regular'].toString();
        final title = data['title'].toString();
        final author = data['author'].toString();

        return WallpaperModel(
            id: id,
            imageUrl: imageUrl,
            title: title,
            author: author,
            isFavorite: false);
      }).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to fetch wallpapers');
    }
  }

  Future<void> loadMoreWallpapers(String category) async {
    if (!isLoadingMap[category]!) {
      setState(() {
        isLoadingMap[category] = true;
      });

      final wallpapers =
          await fetchWallpapers(category, currentPageMap[category]! + 1);
      setState(() {
        categoryWallpapers[category]!.addAll(wallpapers);
        currentPageMap[category] = currentPageMap[category]! + 1;
        isLoadingMap[category] = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: categories.length,
      vsync: this,
      initialIndex: 0,
    );

    categoryWallpapers = {for (var category in categories) category: []};

    currentPageMap = {for (var category in categories) category: 1};

    isLoadingMap = {for (var category in categories) category: false};

    for (var category in categories) {
      if (category == 'CATEGORIES') {
        List<String> imageUrls = [
          'images/city & night.jpg',
          'images/animals.jpg',
          'images/places.jpg',
          'images/natural.jpg',
          'images/buildings.jpg',
          'images/waterfalls.jpg',
          'images/mountains.jpg',
          'images/abstract.jpg',
          'images/colorful.jpg',
          'images/butterflies.jpg',
          'images/flowers.jpg',
          'images/birds.jpg',
          'images/babies & kids.jpg',
          'images/Festivals.jpg',
          'images/sunshine.jpg',
          'images/ocean.jpg',
          'images/pink.jpg',
          'images/rain & water drop.jpg',
          'images/Yellow & orange.jpg',
          'images/spring.jpg',
          'images/winter & snow.jpg'
        ];

        List<String> titles = [
          'City & Night',
          'Animals',
          'Places',
          'Natural',
          'Buildings',
          'Waterfalls',
          'Mountains',
          'Abstract',
          'Colorful',
          'Butterflies',
          'Flowers',
          'Birds',
          'Babies & Kids',
          'Festivals',
          'Sunshine',
          'Ocean',
          'Pink',
          'Rain & Water Drop',
          'Yellow & Orange',
          'Spring',
          'Winter & Snow'
        ];

        List<WallpaperModel> wallpapers = List.generate(
          imageUrls.length,
          (index) => WallpaperModel(
              id: '',
              imageUrl: imageUrls[index],
              title: titles[index],
              author: '',
              isFavorite: false),
        );

        setState(() {
          categoryWallpapers[category] = wallpapers;
        });
      } else {
        fetchWallpapers(category, currentPageMap[category]!).then((wallpapers) {
          setState(() {
            categoryWallpapers[category] = wallpapers;
          });
        });
      }
    }
  }

  void changeCategory(String category) {
    setState(() {
      currentCategory = category;
    });

    if (categoryWallpapers[category]!.isEmpty) {
      fetchWallpapers(category, currentPageMap[category]!).then((wallpapers) {
        setState(() {
          categoryWallpapers[category]?.addAll(wallpapers);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer1(),
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Natural Wallpaper',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SearchPage())); // Handle search button click
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: categories
                .map((category) => Tab(
                      text: category,
                    ))
                .toList(),
            onTap: (index) {
              if (index == 0) {
                List<String> imageUrls = [
                  'images/city & night.jpg',
                  'images/animals.jpg',
                  'images/places.jpg',
                  'images/natural.jpg',
                  'images/buildings.jpg',
                  'images/waterfalls.jpg',
                  'images/mountains.jpg',
                  'images/abstract.jpg',
                  'images/colorful.jpg',
                  'images/butterflies.jpg',
                  'images/flowers.jpg',
                  'images/birds.jpg',
                  'images/babies & kids.jpg',
                  'images/Festivals.jpg',
                  'images/sunshine.jpg',
                  'images/ocean.jpg',
                  'images/pink.jpg',
                  'images/rain & water drop.jpg',
                  'images/Yellow & orange.jpg',
                  'images/spring.jpg',
                  'images/winter & snow.jpg'
                ];

                List<String> titles = [
                  'City & Night',
                  'Animals',
                  'Places',
                  'Natural',
                  'Buildings',
                  'Waterfalls',
                  'Mountains',
                  'Abstract',
                  'Colorful',
                  'Butterflies',
                  'Flowers',
                  'Birds',
                  'Babies & Kids',
                  'Festivals',
                  'Sunshine',
                  'Ocean',
                  'Pink',
                  'Rain & Water Drop',
                  'Yellow & Orange',
                  'Spring',
                  'Winter & Snow'
                ];

                List<WallpaperModel> wallpapers = List.generate(
                  imageUrls.length,
                  (index) => WallpaperModel(
                      id: '',
                      imageUrl: imageUrls[index],
                      title: titles[index],
                      author: '',
                      isFavorite: false),
                );

                setState(() {
                  categoryWallpapers[categories[index]] = wallpapers;
                });
              } else {
                changeCategory(categories[index]);
              }
            },
          ),
          Expanded(
            child: TabBarView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _tabController,
              children: categories.map((category) {
                final wallpapers = categoryWallpapers[category]!;
                final isLoading = isLoadingMap[category]!;
                if (category == categories[0]) {
                  if (wallpapers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No wallpapers available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: ListView.builder(
                          itemCount: wallpapers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final wallpaper = wallpapers[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Homescreen(
                                      title: wallpaper.title,
                                    ),
                                  ),
                                );
                                // Handle the onTap event for each wallpaper
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        wallpaper.imageUrl,
                                        fit: BoxFit.cover,
                                        height: 200,
                                        width: 500,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          wallpaper.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (!isLoading &&
                          notification.metrics.pixels ==
                              notification.metrics.maxScrollExtent) {
                        loadMoreWallpapers(category);
                      }
                      return false;
                    },
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: wallpapers.length,
                      itemBuilder: (BuildContext context, int index) {
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
                          ),
                        );
                      },
                    ),
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
