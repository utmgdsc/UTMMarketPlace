import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/menu/view_models/menu.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  late MenuViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<MenuViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Menu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MenuViewModel>(
        builder: (_, menuViewModel, __) {
          if (menuViewModel.isLoading) {
            return const Center(child: LoadingComponent());
          }
          return const Center(
            child: Text('Menu'),
          );
        },
      ),
    );
  }
}