import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';

class ProfileActions extends StatelessWidget {
  final bool isOwnProfile;
  final VoidCallback onToggleView;
  final bool showListings;
  final ProfileViewModel viewmodel;

  const ProfileActions({
    super.key,
    required this.viewmodel,
    required this.isOwnProfile,
    required this.onToggleView,
    required this.showListings,
  });

  @override
  Widget build(BuildContext context) {
    final savedItemsButton = ElevatedButton(
      onPressed: () => context.push('/saved-items'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3765),
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

    final addReviewButton = ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController reviewController =
                TextEditingController();
            int selectedRating = 0;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Write Review'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                selectedRating > index
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        TextField(
                          controller: reviewController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Enter your review here',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedRating > 0) {
                        viewmodel
                            .submitReview(
                          reviewController.text,
                          selectedRating,
                        )
                            .then((_) {
                          if (context.mounted) {
                            if (viewmodel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewmodel.errorMessage!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Review submitted successfully'),
                                ),
                              );
                            }
                          }
                        });
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a rating'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3765),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3765),
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: const Text(
        'Add Review',
        style: TextStyle(color: Colors.white),
      ),
    );

    final addMessageButton = ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController messageController =
                TextEditingController();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Start a Conversation'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message here',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        MessageRepository()
                            .sendMessage(
                                viewmodel.profile!.id, messageController.text)
                            .then((_) {
                          if (context.mounted) {
                            if (viewmodel.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewmodel.errorMessage!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Review submitted successfully'),
                                ),
                              );
                            }
                          }
                        });
                        Navigator.of(context).pop();
                        context.push(
                          '/messages/${viewmodel.conversationId}',
                          extra: {
                            'username': viewmodel.profileName,
                            'userImageUrl': viewmodel.profileImageUrl,
                            'recipientId': viewmodel.profileId,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please type a message'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3765),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3765),
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: const Text(
        'Message User',
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
          color: showListings ? Colors.white : const Color(0xFF1E3765),
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
          color: !showListings ? Colors.white : const Color(0xFF1E3765),
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
        color: const Color(0xFF1E3765),
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
        if (!isOwnProfile) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: addMessageButton,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: addReviewButton,
          ),
        ],
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: toggleTabs,
        ),
      ],
    );
  }
}
