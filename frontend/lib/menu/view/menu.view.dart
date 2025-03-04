import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/menu/components/menu_item.component.dart';
import 'package:utm_marketplace/menu/view_models/menu.viewmodel.dart';
import 'package:utm_marketplace/menu/model/menu.model.dart';

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

  // Header widgets
  final appBarTitle = const Text(
    'Menu',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  );

  final searchField = TextField(
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
  );

  Widget _buildMenuList(MenuModel menu) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        searchField,
        const SizedBox(height: 20),
        ...menu.menuItems.map(
          (item) => MenuItemComponent(item: item),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: appBarTitle,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    return Scaffold(
      appBar: appBar,
      body: Consumer<MenuViewModel>(
        builder: (_, menuViewModel, __) {
          return _buildMenuList(menuViewModel.menu);
        },
      ),
    );
  }
}
