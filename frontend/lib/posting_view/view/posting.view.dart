import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/posting_view/view_models/posting.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

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

  Future<ImageProvider?> _fetchImage(String url) async {
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return MemoryImage(response.data);
  }

  Widget buildImageWidget(String url) {
    return FutureBuilder<ImageProvider?>(
      future: _fetchImage(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          );
        } else {
          return Container(
            height: 250.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              image: DecorationImage(
                image: snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildImageCarousel(dynamic item) {
    if (item.pictures != null && item.pictures!.isNotEmpty) {
      return SizedBox(
        height: 250.0,
        child: PageView.builder(
          itemCount: item.pictures!.length,
          itemBuilder: (context, index) {
            final pictureUrl = item.pictures![index];
            if (pictureUrl.isEmpty) {
              return Container(
                height: 250.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.grey[200],
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return buildImageWidget(pictureUrl);
          },
        ),
      );
    } else {
      return Container(
        height: 250.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }
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

            final itemImage = buildImageCarousel(item);

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
                Text(
                  'Seller: ${item.sellerName}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Category: ${item.category ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Condition: ${item.condition ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Campus: ${item.campus ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Date Posted: ${item.datePosted ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
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
