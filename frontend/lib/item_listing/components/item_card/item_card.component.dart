import 'package:flutter/material.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:dio/dio.dart';

class ItemCard extends StatelessWidget {
  final String? id;
  final String name;
  final double price;
  final List<String>? imageUrls;
  final String? category;

  const ItemCard({
    super.key,
    this.id,
    required this.name,
    required this.price,
    this.imageUrls,
    this.category,
  });

  Future<ImageProvider?> _fetchImage(String url) async {
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return MemoryImage(response.data);
  }

  Widget buildLoadingImage() {
    return Container(
      height: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildErrorImage() {
    return Container(
      height: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildPlaceholderImage() {
    return Container(
      height: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget buildLoadedImage(ImageProvider image) {
    return Container(
      height: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildImageWidget() {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return FutureBuilder<ImageProvider?>(
        future: _fetchImage(imageUrls!.first),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingImage();
          } else if (snapshot.hasError || !snapshot.hasData) {
            return buildErrorImage();
          } else {
            return buildLoadedImage(snapshot.data!);
          }
        },
      );
    } else {
      return buildPlaceholderImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = buildImageWidget();

    final nameWidget = Text(
      name,
      style: TextStyle(
        fontSize: 17,
        fontFamily: 'Sans-serif',
      ),
      overflow: TextOverflow.ellipsis,
    );

    final priceWidget = Text(
      price == 0.0 ? 'FREE' : '\$${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                priceWidget,
                nameWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
