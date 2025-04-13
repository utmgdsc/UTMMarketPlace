import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/messages/components/message_bubble.component.dart';
import 'package:utm_marketplace/messages/view_models/message.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:utm_marketplace/shared/dio/dio.dart';

class ConversationDetailView extends StatefulWidget {
  final String conversationId;
  final String recipientId;
  final String username;
  final String userImageUrl;

  const ConversationDetailView({
    super.key,
    required this.username,
    required this.recipientId,
    required this.userImageUrl,
    required this.conversationId,
  });

  @override
  State<ConversationDetailView> createState() => _ConversationDetailViewState();
}

class _ConversationDetailViewState extends State<ConversationDetailView> {
  late MessageViewModel viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ImageProvider? _cachedImage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MessageViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchConversation(widget.conversationId, false);
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      debugPrint("Refreshing conversation data...");
      viewModel.fetchConversation(widget.conversationId, true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    viewModel.messageText = _messageController.text;
    debugPrint('Recipient ID: ${widget.recipientId}');
    final success = await viewModel.sendMessage(widget.recipientId);

    if (success) {
      _messageController.clear();
      await viewModel.fetchConversation(widget.conversationId, true);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          color: const Color(0xFF2F9CCF),
        ),
        title: Consumer<MessageViewModel>(
          builder: (_, messageViewModel, __) {
            final conversation = messageViewModel.currentConversation;
            if (conversation == null) return const Text('Loading...');

            return Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: buildImageWidget(widget.userImageUrl),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MessageViewModel>(
        builder: (_, messageViewModel, __) {
          if (messageViewModel.isLoading) {
            return const LoadingComponent();
          }

          final conversation = messageViewModel.currentConversation;
          if (conversation == null) {
            return const Center(
              child: Text('Conversation not found'),
            );
          }

          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: conversation.length,
                  itemBuilder: (context, index) {
                    final message = conversation[index];
                    return MessageBubble(
                      message: message,
                      senderImageUrl: widget.userImageUrl,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(51),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2F9CCF),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<ImageProvider?> _fetchImage(String url) async {
    if (_cachedImage != null) {
      return _cachedImage;
    }

    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    _cachedImage = MemoryImage(response.data);
    return _cachedImage;
  }

  Widget buildImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return FutureBuilder<ImageProvider?>(
        future: _fetchImage(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (_cachedImage != null) {
              return CircleAvatar(
                backgroundImage: _cachedImage,
              );
            } else {
              return buildLoadingImage();
            }
          } else if (snapshot.hasError) {
            debugPrint('Error fetching image: ${snapshot.error}');
            return buildPlaceholderImage();
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

  Widget buildPlaceholderImage() {
    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }
}
