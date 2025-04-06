import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/item_listing/components/item_card/item_card.component.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/item_listing/components/listing_loading.component.dart';

class ListingView extends StatefulWidget {
  const ListingView({super.key});

  @override
  State<ListingView> createState() => _ListingViewState();
}

class _ListingViewState extends State<ListingView> {
  late ListingViewModel viewModel;
  final double hPad = 16.0; // Horizontal padding

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ListingViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData();
    });
  }

  Widget _buildItemGrid(ListingViewModel listingViewModel) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8.0, hPad, 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: itemCardDelegate(),
        itemCount: listingViewModel.items.length,
        itemBuilder: (context, index) {
          final item = listingViewModel.items[index];
          return GestureDetector(
            onTap: () {
              context.push('/item/${item.id}');
            },
            child: ItemCard(
              id: item.id,
              name: item.name,
              price: item.price,
              category: item.condition,
              imageUrl: item.imageUrl ?? '',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search criteria',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'Marketplace',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    final searchBar = Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Colors.grey[600],
              ),
              onPressed: () => viewModel.showFilterBottomSheet(context),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBar,
            Expanded(
              child: Consumer<ListingViewModel>(
                builder: (_, listingViewModel, child) {
                  if (listingViewModel.isLoading) {
                    return const ListingLoadingComponent();
                  }

                  if (listingViewModel.items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 5.0, top: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Trending',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      _buildItemGrid(listingViewModel),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
