import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/messages/components/conversation_list_item.component.dart';
import 'package:utm_marketplace/messages/view_models/message.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late MessageViewModel viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MessageViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey[600],
        ),
      ),
      onChanged: (value) {
        debugPrint('Search value: $value');
      },
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const Divider(
        height: 14,
        indent: 85,
      ),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationListItem(
          conversation: conversation,
          onTap: () {
            context.push('/messages/${conversation.id}');
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No messages yet',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'Messages',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    final searchFieldSection = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _buildSearchField(),
    );

    final conversationsSection = Expanded(
      child: Consumer<MessageViewModel>(
        builder: (_, messageViewModel, __) {
          if (messageViewModel.isLoading) {
            return const LoadingComponent();
          }

          final sortedConversations = messageViewModel.sortedConversations;

          if (sortedConversations.isEmpty) {
            return _buildEmptyState();
          }

          return _buildConversationsList(sortedConversations);
        },
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          searchFieldSection,
          conversationsSection,
        ],
      ),
    );
  }
}
