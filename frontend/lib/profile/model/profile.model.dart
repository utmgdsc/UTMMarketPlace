class ProfileModel {
  final String id;
  final String displayName;
  final String email;
  final String? profilePicture;
  final double rating;
  final int ratingCount;
  final String? location;
  final List<String>? savedPosts;
  final List<Review> reviews;
  final List<ListingItem> listings;

  ProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.profilePicture,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.location,
    this.savedPosts,
    this.reviews = const [],
    this.listings = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['user_id'],
      displayName: json['display_name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      rating: json['rating']?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      location: json['location'],
      savedPosts: (json['saved_posts'] as List?)?.cast<String>(),
      reviews: [], // Reviews are not part of the current API response
      listings: [], // Listings are not part of the current API response
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
