import 'package:flutter/material.dart';

class ListingLoadingComponent extends StatelessWidget {
  const ListingLoadingComponent({super.key});

  Widget _buildSearchBarSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingLabelSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 5.0, top: 5.0),
      child: Container(
        width: 120,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSearchBarSkeleton(),
        _buildTrendingLabelSkeleton(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSkeletonItem()),
                  Expanded(child: _buildSkeletonItem()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSkeletonItem()),
                  Expanded(child: _buildSkeletonItem()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSkeletonItem()),
                  Expanded(child: _buildSkeletonItem()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
