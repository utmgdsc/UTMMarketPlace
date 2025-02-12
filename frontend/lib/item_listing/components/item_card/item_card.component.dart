import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String? id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? category;

  const ItemCard({
    super.key,
    this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = imageUrl != null
      ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 175.0,
          errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.error);
          },
        )
      : SizedBox.shrink();

    final nameWidget = Text(
      name,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );

    final priceWidget = Text(
      price == 0.0 ? 'FREE' : '\$${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );

    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          Padding(
            padding: const EdgeInsets.all(10.0),
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
