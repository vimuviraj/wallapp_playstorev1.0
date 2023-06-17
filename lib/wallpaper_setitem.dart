import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:share_plus/share_plus.dart';

enum WallpaperLocation {
  // ignore: constant_identifier_names
  HomeScreen,
  // ignore: constant_identifier_names
  LockScreen,
  // ignore: constant_identifier_names
  Both,
}

class WallpaperModel {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  bool isFavorite;

  WallpaperModel(
      {required this.id,
      required this.imageUrl,
      required this.title,
      required this.author,
      required this.isFavorite});
}

class WallpaperItem extends StatefulWidget {
  final WallpaperModel wallpaper;
  final List<WallpaperModel> wallpapers;
  final int initialIndex;

  const WallpaperItem({
    Key? key,
    required this.wallpaper,
    required this.wallpapers,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _WallpaperItemState createState() => _WallpaperItemState();
}

class _WallpaperItemState extends State<WallpaperItem> {
  late PageController _pageController;
  late int _currentIndex;
  WallpaperLocation _selectedLocation = WallpaperLocation.Both;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void showPreviousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void showNextImage() {
    if (_currentIndex < widget.wallpapers.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> setWallpaper() async {
    final wallpaper = widget.wallpapers[_currentIndex];
    final String imageUrl = wallpaper.imageUrl;

    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    final String filePath = file.path;
    // ignore: use_build_context_synchronously
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final screenAspectRatio = screenWidth / screenHeight;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(
        ratioX: screenAspectRatio,
        ratioY: 1.0, // Set ratioY to 1.0 for maintaining the same aspect ratio
      ),
      cropStyle:
          CropStyle.rectangle, // You can change this based on your preference
      compressQuality: 100, // Adjust the compression quality as needed
    );
    AndroidUiSettings(
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.blue,
      toolbarWidgetColor: Colors.blue,
      initAspectRatio: CropAspectRatioPreset.original,
      lockAspectRatio: false,
      hideBottomControls: true,
    );

    if (croppedFile != null) {
      // Compress the image to match the screen width
      // ignore: use_build_context_synchronously
      final screenWidth = MediaQuery.of(context).size.width.toInt();

      List<int>? compressedImage = await FlutterImageCompress.compressWithFile(
        croppedFile
            .path, // Use the cropped file path instead of the original file path
        minWidth: screenWidth,
        quality: 100,
      );

      if (compressedImage != null) {
        // Save the compressed image to a new file
        final compressedFilePath = croppedFile.path
            .replaceAll('.jpg', '_compressed.jpg'); // Update the file path
        await File(compressedFilePath).writeAsBytes(compressedImage);

        int location;

        switch (_selectedLocation) {
          case WallpaperLocation.HomeScreen:
            location = WallpaperManager.HOME_SCREEN;
            break;
          case WallpaperLocation.LockScreen:
            location = WallpaperManager.LOCK_SCREEN;
            break;
          case WallpaperLocation.Both:
          default:
            location = WallpaperManager.BOTH_SCREEN;
            break;
        }

        await WallpaperManager.setWallpaperFromFile(
          compressedFilePath,
          location,
        );

        // Verify the compression
        final originalFileSize = await file.length();
        final compressedFile = File(compressedFilePath);
        final compressedFileSize = await compressedFile.length();

        if (compressedFileSize < originalFileSize) {
          final savedPercentage =
              ((1 - compressedFileSize / originalFileSize) * 100)
                  .toStringAsFixed(2);
        } else {}
      }
    }
  }

  // Method to share an image URL

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
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Set Wallpaper Location'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Home Screen'),
                          leading: Radio<WallpaperLocation>(
                            value: WallpaperLocation.HomeScreen,
                            groupValue: _selectedLocation,
                            onChanged: (WallpaperLocation? value) {
                              setState(() {
                                _selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Lock Screen'),
                          leading: Radio<WallpaperLocation>(
                            value: WallpaperLocation.LockScreen,
                            groupValue: _selectedLocation,
                            onChanged: (WallpaperLocation? value) {
                              setState(() {
                                _selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Both'),
                          leading: Radio<WallpaperLocation>(
                            value: WallpaperLocation.Both,
                            groupValue: _selectedLocation,
                            onChanged: (WallpaperLocation? value) {
                              setState(() {
                                _selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          setWallpaper(); // Set the wallpaper when the wallpaper button is pressed
                          Navigator.pop(context);
                        },
                        child: const Text('Set Wallpaper'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: widget.wallpaper.isFavorite
                  ? Colors.red
                  : Colors.grey, // Change color based on isFavorite
            ),
            onPressed: () {
              setState(() {
                widget.wallpaper.isFavorite =
                    !widget.wallpaper.isFavorite; // Toggle isFavorite state
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share(widget.wallpaper.imageUrl);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
// Swiped right
            showPreviousImage();
          } else if (details.primaryVelocity! < 0) {
// Swiped left
            showNextImage();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.wallpapers.length,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                final wallpaper = widget.wallpapers[index];
                return Image.network(
                  wallpaper.imageUrl,
                  fit: BoxFit.cover,
                );
              },
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
