import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';
import 'package:utm_marketplace/create_listing/components/image_selector.component.dart';
import 'package:utm_marketplace/create_listing/components/form_input_field.component.dart';
import 'package:utm_marketplace/create_listing/components/condition_selector.component.dart';
import 'package:utm_marketplace/create_listing/components/campus_selector.component.dart';

class CreateListingView extends StatefulWidget {
  const CreateListingView({super.key});

  @override
  State<CreateListingView> createState() => _CreateListingViewState();
}

class _CreateListingViewState extends State<CreateListingView> {
  final _formKey = GlobalKey<FormState>();
  late CreateListingViewModel viewModel;
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreateListingViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    viewModel.clearImages();
    viewModel.clearCondition();
    super.dispose();
  }

  // Header widgets
  final appBarTitle = const Text(
    'Create Post',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  );

  final postButton = const Text(
    'Post',
    style: TextStyle(
      color: Color(0xFF2F9CCF),
      fontSize: 16,
    ),
  );

  void _handleSubmit() async {
    final success = await viewModel.submitForm(
      formKey: _formKey,
      title: _titleController.text,
      price: _priceController.text,
      description: _descriptionController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Posting successfully created!'),
      ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error in posting. Please try again later.'),
      ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
        color: const Color(0xFF2F9CCF),
      ),
      centerTitle: true,
      title: appBarTitle,
      actions: [
        TextButton(
          onPressed: _handleSubmit,
          child: postButton,
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<CreateListingViewModel>(
            builder: (_, model, __) => ImageSelector(
              showValidationErrors: model.showValidationErrors,
            ),
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _titleController,
            label: 'Title',
            validator: (value) => viewModel.validateTitle(value),
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _priceController,
            label: 'Price',
            isPrice: true,
            validator: (value) => viewModel.validatePrice(value),
          ),
          const SizedBox(height: 16),
          Consumer<CreateListingViewModel>(
            builder: (_, model, __) => ConditionSelector(
              showValidationErrors: model.showValidationErrors,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<CreateListingViewModel>(
            builder: (_, model, __) => CampusSelector(
              showValidationErrors: model.showValidationErrors,
            ),
          ),
          const SizedBox(height: 16),
          FormInputField(
            controller: _descriptionController,
            label: '',
            hintText: 'Description (recommended)',
            isMultiline: true,
            minLines: 5,
            maxLines: null,
            validator: (value) => viewModel.validateDescription(value),
          ),
        ],
      ),
    );

    final scrollableContent = SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80,
      ),
      child: formContent,
    );

    final bottomButton = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF11384A),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Post',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          scrollableContent,
          bottomButton,
        ],
      ),
    );
  }
}
