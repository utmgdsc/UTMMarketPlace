class ListingItem {
  final String id;
  final String imageUrl;
  final String title;
  final double price;

  const ListingItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  factory ListingItem.fromJson(Map<String, dynamic> json) {
    return ListingItem(
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      price: json['price'].toDouble(),
    );
  }
}
