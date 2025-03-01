import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/posting_view/view_models/posting.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:utm_marketplace/shared/themes/theme.dart';

class PostingView extends StatefulWidget {
  final String itemId;

  const PostingView({super.key, required this.itemId});

  @override
  State<PostingView> createState() => _PostingViewState();
}

class _PostingViewState extends State<PostingView> {
  late PostingViewModel viewModel;
  final double hPad = 16.0; // Horizontal padding

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<PostingViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchData(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      automaticallyImplyLeading: false,
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
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8.0),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: hPad, vertical: 12.0),
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
              child: Consumer<PostingViewModel>(
                builder: (_, postingViewModel, child) {
                  if (postingViewModel.isLoading) {
                    return loadingState;
                  }
                  if (postingViewModel.items.isEmpty) {
                    return emptyState;
                  }
                  return ListView(
                    children: [
                      searchBar,
                      trendingLabel,
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
