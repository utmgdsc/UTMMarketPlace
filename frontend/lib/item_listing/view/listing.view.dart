import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/item_listing/components/item_card/item_card.component.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';

class ListingView extends StatefulWidget {
  const ListingView({super.key});

  @override
  State<ListingView> createState() => _ListingViewState();
}

class _ListingViewState extends State<ListingView> {
  late ListingViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ListingViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Listing'),
      ),
      body: SafeArea(
        child: Consumer<ListingViewModel>(
          builder: (_, listingViewModel, child) {
            if (listingViewModel.isLoading) {
              return const Center(child: LoadingComponent());
            }

            if (listingViewModel.items.isEmpty) {
              return const Center(child: Text('No items available.'));
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 250,
                ),
                itemCount: listingViewModel.items.length,
                itemBuilder: (context, index) {
                  final item = listingViewModel.items[index];
                  return ItemCard(
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    category: item.category,
                    imageUrl: item.imageUrl ?? '',
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
