import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/messages/components/message_bubble.component.dart';
import 'package:utm_marketplace/messages/view_models/message.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:go_router/go_router.dart';


class ConversationDetailView extends StatefulWidget {
  final String conversationId;

  const ConversationDetailView({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationDetailView> createState() => _ConversationDetailViewState();
}

class _ConversationDetailViewState extends State<ConversationDetailView> {
  late MessageViewModel viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MessageViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    final success = await viewModel.sendMessage();
    
    if (success) {
      _messageController.clear();
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
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(conversation.userImageUrl),
                ),
                const SizedBox(width: 8),
                Text(
                  conversation.userName,
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

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: conversation.messages.length,
                  itemBuilder: (context, index) {
                    final message = conversation.messages[index];
                    return MessageBubble(
                      message: message,
                      senderImageUrl: conversation.userImageUrl,
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
}