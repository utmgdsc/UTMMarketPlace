import 'package:flutter/material.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final profilePicture = Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(conversation.userImageUrl),
        ),
        if (conversation.isUnread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );

    final userName = Text(
      conversation.userName,
      style: TextStyle(
        fontWeight: conversation.isUnread ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    );

    final timeAgo = Text(
      _getTimeAgo(conversation.lastMessageTime),
      style: TextStyle(
        color: conversation.isUnread ? Colors.blue : Colors.grey[600],
        fontWeight: conversation.isUnread ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );

    final messagePreview = Text(
      conversation.lastMessagePreview,
      style: TextStyle(
        color: conversation.isUnread ? Colors.black : Colors.grey[700],
        fontWeight: conversation.isUnread ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final headerRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [userName, timeAgo],
    );

    final contentColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        const SizedBox(height: 4),
        messagePreview,
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicture,
            const SizedBox(width: 12),
            Expanded(child: contentColumn),
          ],
        ),
      ),
    );
  }
}
