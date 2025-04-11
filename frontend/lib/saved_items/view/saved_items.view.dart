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
  
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 179),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load saved items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 179),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                viewModel.fetchData();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              viewModel.fetchData();
            },
          ),
        ],
      ),
      body: Consumer<SavedItemsViewModel>(
        builder: (context, savedItemsViewModel, _) {
          if (savedItemsViewModel.isLoading) {
            return const SavedItemsLoadingComponent();
          }
          
          if (savedItemsViewModel.errorMessage.isNotEmpty) {
            return _buildErrorState(savedItemsViewModel.errorMessage);
          }

          if (savedItemsViewModel.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved items',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 179),
                    ),
                  ),
                ],
              ),
            );
          }

          if (savedItemsViewModel.errorMessage.isNotEmpty) {
            return _buildErrorState(savedItemsViewModel.errorMessage);
          }

          if (savedItemsViewModel.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved items',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 179),
                    ),
                  ),
                ],
              ),
            );
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
                  imageUrls: [item.imageUrl],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
