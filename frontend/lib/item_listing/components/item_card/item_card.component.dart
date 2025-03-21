import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final imageWidgets = imageUrls != null && imageUrls!.isNotEmpty
        ? Container(
            height: 250.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Image.network(
              imageUrls!.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://placehold.co/400/png',
                  fit: BoxFit.cover,
                );
              },
            ),
          )
        : SizedBox.shrink();

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
          imageWidgets,
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
