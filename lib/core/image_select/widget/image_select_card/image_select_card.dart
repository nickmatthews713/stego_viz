import 'package:flutter/material.dart';
import 'dart:convert';

class ImageSelectCard extends StatelessWidget {
  const ImageSelectCard({
    super.key,
    this.title,
    this.image,
    this.subtitle,
  });

  final String? title;
  // image in base64 byte string
  final String? image;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Convert base64 byte string to image
    final imgBytes = base64Decode(image!);
    final img = Image.memory(imgBytes);

    return Card(
      child: ListTile(
        // leading is an image with rounded corners
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: img,
        ),
        title: Text(title!),
        subtitle: Text(subtitle!),
      ),
    );
  }
}