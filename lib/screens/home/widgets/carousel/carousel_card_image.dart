import 'package:flutter/material.dart';

class CarouselCardImage {
  static Widget build(String? imageUrl, {required bool isLarge}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.restaurant,
              size: isLarge ? 48 : 24,
              color: Colors.grey,
            ),
          );
        },
      );
    }
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.restaurant,
        size: isLarge ? 48 : 24,
        color: Colors.grey,
      ),
    );
  }
}
