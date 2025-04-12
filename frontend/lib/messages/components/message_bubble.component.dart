import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String senderImageUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.senderImageUrl,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (message.isFromCurrentUser) {
      final messageContent = Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );

      final messageBubble = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2F9CCF),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: messageContent,
      );

      final timeStamp = Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      );

      return Padding(
        padding: const EdgeInsets.only(
            left: 60.0, right: 16.0, top: 8.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            messageBubble,
            const SizedBox(height: 4),
            timeStamp,
          ],
        ),
      );
    } else {
      final avatar = FutureBuilder<ImageProvider?>(
        future: _fetchImage(senderImageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingImage();
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person),
            );
          } else {
            return CircleAvatar(
              radius: 16,
              backgroundImage: snapshot.data!,
            );
          }
        },
      );

      final messageContent = Text(
        message.content,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      );

      final messageBubble = Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: messageContent,
      );

      final timeStamp = Text(
        _formatTime(message.timestamp),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      );

      final messageColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageBubble,
          const SizedBox(height: 4),
          timeStamp,
        ],
      );

      return Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 60.0, top: 8.0, bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            const SizedBox(width: 8),
            Expanded(child: messageColumn),
          ],
        ),
      );
    }
  }

  Future<ImageProvider?> _fetchImage(String url) async {
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return MemoryImage(response.data);
  }

  Widget buildImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return FutureBuilder<ImageProvider?>(
        future: _fetchImage(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingImage();
          } else if (snapshot.hasError) {
            debugPrint('Error fetching image: ${snapshot.error}');
            return buildErrorImage();
          } else if (!snapshot.hasData || snapshot.data == null) {
            return buildPlaceholderImage();
          } else {
            return CircleAvatar(
              backgroundImage: snapshot.data!,
            );
          }
        },
      );
    } else {
      return buildPlaceholderImage();
    }
  }

  Widget buildLoadingImage() {
    return const CircleAvatar(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorImage() {
    return const CircleAvatar(
      child: Icon(Icons.error),
    );
  }

  Widget buildPlaceholderImage() {
    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }
}
