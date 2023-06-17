import 'package:flutter/material.dart';
import 'package:natural_wallpaper_hd/category_page.dart';
import 'package:natural_wallpaper_hd/ex.dart';

import 'package:natural_wallpaper_hd/splash_screen.dart';
import 'package:provider/provider.dart';

import 'favourit.dart';

void main() {
  runApp(
    ChangeNotifierProvider<FavoriteImages>(
      create: (_) => const FavoriteImages(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const SplashScreen(),
      routes: {
        "/favorite": (context) => const FavoriteImages(),
      },
    );
  }
}
