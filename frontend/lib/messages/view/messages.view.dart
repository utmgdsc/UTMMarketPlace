import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/messages/view_models/message.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late MessageViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MessageViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Consumer<MessageViewModel>(
        builder: (_, messageViewModel, __) {
          if (messageViewModel.isLoading) {
            return const Center(child: LoadingComponent());
          }
          return const Center(
            child: Text('Messages'),
          );
        },
      ),
    );
  }
}
