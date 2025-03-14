import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/item_listing/components/item_card/item_card.component.dart';
import 'package:utm_marketplace/saved_items/components/saved_items_loading.component.dart';
import 'package:utm_marketplace/saved_items/view_models/saved_items.viewmodel.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';

class SavedItemsView extends StatefulWidget {
  const SavedItemsView({super.key});

  @override
  State<SavedItemsView> createState() => _SavedItemsViewState();
}

class _SavedItemsViewState extends State<SavedItemsView> {
  late SavedItemsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<SavedItemsViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Items',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SavedItemsViewModel>(
        builder: (context, savedItemsViewModel, _) {
          if (savedItemsViewModel.isLoading) {
            return const SavedItemsLoadingComponent();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: itemCardDelegate(),
            itemCount: savedItemsViewModel.items.length,
            itemBuilder: (context, index) {
              final item = savedItemsViewModel.items[index];
              return GestureDetector(
                onTap: () => context.push('/item/${item.id}'),
                child: ItemCard(
                  id: item.id,
                  name: item.title,
                  price: item.price,
                  imageUrl: item.imageUrl,
                ),
              );
            },
          );
        },
      ),
    );
  }
}