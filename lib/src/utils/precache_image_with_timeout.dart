import 'package:flutter/material.dart';

Future<void> precacheImageWithRetry(String imageUrl, BuildContext context) async {
  int retries = 3; // Maximum number of retries
  while (retries > 0) {
    try {
      final imageProvider = NetworkImage(imageUrl);
      await precacheImage(imageProvider, context);
      print("Successfully preloaded image: $imageUrl");
      return; // Exit if successful
    } catch (e) {
      retries--;
      if (retries == 0) {
        print("Failed to preload image after multiple attempts: $imageUrl");
      } else {
        print("Retrying image preload ($retries attempts left): $imageUrl");
      }
    }
  }
}

