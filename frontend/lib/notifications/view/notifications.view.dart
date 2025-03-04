import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/notifications/view_models/notification.viewmodel.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late NotificationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<NotificationViewModel>(context, listen: false);
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
          'Notifications',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<NotificationViewModel>(
        builder: (_, notificationViewModel, __) {
          return const Center(
            child: Text('Notifications'),
          );
        },
      ),
    );
  }
}
