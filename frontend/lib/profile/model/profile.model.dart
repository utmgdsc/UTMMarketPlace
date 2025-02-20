class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final double rating;
  final List<Review> reviews;
  final List<ListingItem> listings;
  final List<ListingItem> savedItems;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviews = const [],
    this.listings = const [],
    this.savedItems = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      imageUrl: json['image_url'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as List?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],
      listings: (json['listings'] as List?)
              ?.map((listing) => ListingItem.fromJson(listing))
              .toList() ??
          [],
      savedItems: (json['saved_items'] as List?)
              ?.map((item) => ListingItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Review {
  final String reviewerId;
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewerId: json['reviewer_id'],
      reviewerName: json['reviewer_name'],
      reviewerImage: json['reviewer_image'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }
}

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
