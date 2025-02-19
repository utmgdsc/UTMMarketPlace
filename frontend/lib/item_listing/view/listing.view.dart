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
  final double hPad = 16.0; // Horizontal padding

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
    final appBar = AppBar(
      centerTitle: true,
      title: const Text(
        'Marketplace',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    final searchBar = Padding(
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: hPad, vertical: 12.0),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                debugPrint('Filter button pressed');
              },
            ),
          ),
        ],
      ),
    );

    final trendingLabel = Padding(
      padding: EdgeInsets.only(left: hPad, bottom: 5.0, top: 5.0),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Trending',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
    );

    final emptyState = const Center(child: Text('No items available.'));

    final loadingState = const Center(child: LoadingComponent());

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer<ListingViewModel>(
                builder: (_, listingViewModel, child) {
                  if (listingViewModel.isLoading) {
                    return loadingState;
                  }
                  if (listingViewModel.items.isEmpty) {
                    return emptyState;
                  }
                  return ListView(
                    children: [
                      searchBar,
                      trendingLabel,
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            hPad, 8.0, hPad, 8.0),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 1,
                                mainAxisExtent: 310,
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
                          ],
                        ),
                      ),
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
