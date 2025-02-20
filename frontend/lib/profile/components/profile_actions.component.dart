import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final bool isOwnProfile;
  final VoidCallback onToggleView;
  final bool showListings;

  const ProfileActions({
    super.key,
    required this.isOwnProfile,
    required this.onToggleView,
    required this.showListings,
  });

  @override
  Widget build(BuildContext context) {
    final savedItemsButton = ElevatedButton(
      onPressed: () {
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF11384A),
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: const Text(
        'Saved Items',
        style: TextStyle(color: Colors.white),
      ),
    );

    final listingsTab = GestureDetector(
      onTap: () {
        if (!showListings) onToggleView();
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: showListings ? Colors.white : const Color(0xFF11384A),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            'Listings',
            style: TextStyle(
              color: showListings ? const Color(0xFF2F9CCF) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    final reviewsTab = GestureDetector(
      onTap: () {
        if (showListings) onToggleView();
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: !showListings ? Colors.white : const Color(0xFF11384A),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            'Reviews',
            style: TextStyle(
              color: !showListings ? const Color(0xFF2F9CCF) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    final toggleTabs = Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF11384A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(child: listingsTab),
          Expanded(child: reviewsTab),
        ],
      ),
    );

    return Column(
      children: [
        if (isOwnProfile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: savedItemsButton,
          ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: toggleTabs,
        ),
      ],
    );
  }
}
