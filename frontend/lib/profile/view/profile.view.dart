import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/profile/components/profile_header.component.dart';
import 'package:utm_marketplace/profile/components/profile_actions.component.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/item_listing/components/item_card/item_card.component.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';

class Profile extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const Profile({
    super.key,
    required this.userId,
    required this.isOwnProfile,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late ProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, _) {
        if (profileViewModel.isLoading) {
          return const LoadingComponent();
        }

        final profile = profileViewModel.profile;
        if (profile == null) {
          return const Center(child: Text('Error loading profile'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                name: profile.name,
                email: profile.email,
                imageUrl: profile.imageUrl,
                rating: profile.rating,
                isOwnProfile: widget.isOwnProfile,
              ),
              const SizedBox(height: 16),
              ProfileActions(
                isOwnProfile: widget.isOwnProfile,
                onToggleView: profileViewModel.toggleView,
                showListings: profileViewModel.showListings,
              ),
              const SizedBox(height: 16),
              if (profileViewModel.showListings)
                _buildListingsGrid(profile.listings)
              else
                _buildReviewsList(profile.reviews),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingsGrid(List<ListingItem> listings) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: itemCardDelegate(),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          return ItemCard(
            id: item.id,
            name: item.title,
            price: item.price,
            imageUrl: item.imageUrl,
          );
        },
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    final reviewDivider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Divider(
        color: Colors.grey[300],
        height: 1,
      ),
    );

    Widget buildReviewTile(Review review) {
      final reviewerInfo = Row(
        children: [
          Text(
            review.reviewerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (index) {
            return Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              color: Colors.black,
              size: 18,
            );
          }),
        ],
      );

      final timeAgoText = Text(
        _getTimeAgo(review.date),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      );

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(review.reviewerImage),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: reviewerInfo),
            timeAgoText,
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            review.comment,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reviews.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => reviewDivider,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: buildReviewTile(reviews[index]),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
