import 'dart:async';
import 'package:flutter/material.dart';
import 'package:natural_wallpaper_hd/home.dart';
// Replace with your home screen file

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay for the splash screen
    Timer(const Duration(seconds: 10), () {
      // Navigate to the home screen after the splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const WallpaperApp()), // Replace with your home screen widget
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Set the background color to transparent
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/splash_screen.jpg'), // Replace with your asset image path
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Natural Wallpaper HD 4k',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ]),
            )));
  }
}
