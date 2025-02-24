import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';
import 'package:utm_marketplace/shared/components/loading.component.dart';

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
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<CreateListingViewModel>(context, listen: false);
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

  // Form widgets
  Widget _buildImageSelector() {
    return Consumer<CreateListingViewModel>(
      builder: (_, model, __) {
        final bool showError = !model.hasImage && _showValidationErrors;
        
        return GestureDetector(
          onTap: () async {
            // Your existing image selection logic
          },
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showError
                    ? const Color(0xFFFF5252)
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: model.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      model.image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: showError
                            ? const Color(0xFFFF5252)
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add photos / video',
                        style: TextStyle(
                          color: showError
                              ? const Color(0xFFFF5252)
                              : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      if (showError)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Add a photo to continue.',
                            style: TextStyle(
                              color: Color(0xFFFF5252),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: isPrice ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter a ${label.toLowerCase()} to continue.';
            }
            if (label == 'Title') {
              if (value.length > CreateListingModel.maxTitleLength) {
                return 'Title must be less than ${CreateListingModel.maxTitleLength} characters';
              }
              if (value.trim().isEmpty) {
                return 'Title cannot be only whitespace';
              }
            }
            if (isPrice) {
              final price = double.tryParse(value);
              if (price == null) {
                return 'Enter a price to continue.';
              }
              if (price <= 0) {
                return 'Price must be greater than 0';
              }
              if (price > CreateListingModel.maxPrice) {
                return 'Price must be less than \$${CreateListingModel.maxPrice}';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            errorStyle: const TextStyle(
              color: Color(0xFFFF5252),
              fontSize: 12,
              height: 0.8,
            ),
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey[600],
            ),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSelector() {
    return Consumer<CreateListingViewModel>(
      builder: (_, model, __) {
        final bool showError = _showValidationErrors && model.condition.isEmpty;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Condition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildConditionChip('New', model),
                _buildConditionChip('Almost New', model),
                _buildConditionChip('Used', model),
                _buildConditionChip('Fair', model),
              ],
            ),
            if (showError)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Select a condition to continue.',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConditionChip(String condition, CreateListingViewModel model) {
    final isSelected = model.condition == condition;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          condition,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.grey[200],
        backgroundColor: const Color(0xFF2C2C2C),
        onSelected: (selected) {
          if (selected) {
            model.setCondition(condition);
          }
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: null,
          minLines: 5,
          validator: (value) {
            if (value != null) {
              if (value.length > CreateListingModel.maxDescriptionLength) {
                return 'Description must be less than ${CreateListingModel.maxDescriptionLength} characters';
              }
              if (value.isNotEmpty && value.trim().isEmpty) {
                return 'Description cannot be only whitespace';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              height: 0.8,
            ),
            hintText: 'Description (recommended)',
            hintStyle: TextStyle(
              color: Colors.grey[600],
            ),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    setState(() {
      _showValidationErrors = true;
    });

    final isFormValid = _formKey.currentState!.validate();
    final hasImage = viewModel.hasImage;
    final hasCondition = viewModel.condition.isNotEmpty;

    if (isFormValid && hasImage && hasCondition) {
      final success = await viewModel.createListing(
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text),
        description: _descriptionController.text.trim(),
      );

      if (success && mounted) {
        context.pop();
      }
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
          onPressed: _submitForm,
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
          _buildImageSelector(),
          const SizedBox(height: 16),
          _buildTextField('Title', _titleController),
          const SizedBox(height: 16),
          _buildTextField('Price', _priceController, isPrice: true),
          const SizedBox(height: 16),
          _buildConditionSelector(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
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
          onPressed: _submitForm,
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
      body: Consumer<CreateListingViewModel>(
        builder: (_, model, __) {
          if (model.isLoading) {
            return const Center(child: LoadingComponent());
          }

          return Stack(
            children: [
              scrollableContent,
              bottomButton,
            ],
          );
        },
      ),
    );
  }
}