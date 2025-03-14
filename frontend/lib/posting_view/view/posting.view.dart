import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/posting_view/view_models/posting.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';

class PostingView extends StatefulWidget {
  final String itemId;

  const PostingView({super.key, required this.itemId});

  @override
  State<PostingView> createState() => _PostingViewState();
}

class _PostingViewState extends State<PostingView> {
  late PostingViewModel viewModel;

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
    final loadingIndicator = const Center(child: LoadingComponent());

    final itemUnavailable = const Center(child: Text('Item data unavailable.'));

    return Scaffold(
      body: SafeArea(
        child: Consumer<PostingViewModel>(
          builder: (_, postingViewModel, child) {
            if (postingViewModel.isLoading) {
              return loadingIndicator;
            }
            if (postingViewModel.item == null) {
              return itemUnavailable;
            }

            final item = postingViewModel.item;
            if (item == null || item.id != widget.itemId) {
              return itemUnavailable;
            }

            final itemImage = item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container();

            final itemTitle = Text(
              item.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            );

            final itemDetails = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                const Text(
                  'Aubery Drake',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'XX/XX/XXXX',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            );

            final itemPrice = Text(
              item.price == 0.0 ? 'FREE' : '\$${item.price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );

            final itemDescription = Text(
              item.description ?? 'No description available.',
              style: const TextStyle(
                fontSize: 16,
              ),
            );

            final titleRow = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: itemTitle),
                IconButton(
                  icon: Icon(
                    postingViewModel.isSavedItem(item.id!)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: postingViewModel.isSavedItem(item.id!)
                        ? Colors.red
                        : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () => postingViewModel.toggleSaved(item.id!),
                ),
              ],
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemImage,
                  const SizedBox(height: 16.0),
                  titleRow,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 4, child: itemDetails),
                      Expanded(flex: 3, child: itemPrice),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  itemDescription,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
