import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/item_listing/view_models/filter.viewmodel.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterViewModel>(
      builder: (context, filterViewModel, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCampusSection(filterViewModel),
              const SizedBox(height: 16),
              _buildSortingSection(filterViewModel),
              const SizedBox(height: 16),
              _buildPriceRangeButton(context, filterViewModel),
              const SizedBox(height: 16),
              _buildDateSection(context, filterViewModel),
              const SizedBox(height: 16),
              _buildConditionSection(filterViewModel),
              const SizedBox(height: 24),
              _buildButtons(context, filterViewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampusSection(FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Mississauga', 'St. George', 'Scarborough'].map((campus) {
            final isSelected = viewModel.campus == campus;
            return FilterChip(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(
                campus,
                style: TextStyle(
                  fontSize: 13.1,
                  color: isSelected ? const Color(0xFF2F9CCF) : Colors.black,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                viewModel.setCampus(selected ? campus : null);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF2F9CCF).withAlpha(51),
              checkmarkColor: const Color(0xFF2F9CCF),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortingSection(FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSortOption(
                'Price: Lowest first',
                SortOrder.priceLowToHigh,
                viewModel,
              ),
              Divider(height: 1, color: Colors.grey[300]),
              _buildSortOption(
                'Price: Highest first',
                SortOrder.priceHighToLow,
                viewModel,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption(
    String title,
    SortOrder value,
    FilterViewModel viewModel,
  ) {
    return InkWell(
      onTap: () => viewModel.setSortOrder(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            if (viewModel.sortOrder == value)
              const Icon(
                Icons.check,
                color: Color(0xFF2F9CCF),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeButton(BuildContext context, FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showPriceRangeDialog(context, viewModel),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getPriceRangeText(viewModel),
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getPriceRangeText(FilterViewModel viewModel) {
    if (viewModel.minPrice == null && viewModel.maxPrice == null) {
      return 'Any price';
    }
    if (viewModel.minPrice != null && viewModel.maxPrice == null) {
      return 'From \$${viewModel.minPrice!.toStringAsFixed(2)}';
    }
    if (viewModel.minPrice == null && viewModel.maxPrice != null) {
      return 'Up to \$${viewModel.maxPrice!.toStringAsFixed(2)}';
    }
    return '\$${viewModel.minPrice!.toStringAsFixed(2)} - \$${viewModel.maxPrice!.toStringAsFixed(2)}';
  }

  void _showPriceRangeDialog(BuildContext context, FilterViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => PriceRangeDialog(
        initialMinPrice: viewModel.minPrice,
        initialMaxPrice: viewModel.maxPrice,
        onApply: (min, max) {
          viewModel.setMinPrice(min);
          viewModel.setMaxPrice(max);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listed Since',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => viewModel.openDatePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  viewModel.dateFrom?.toString() ?? 'All time',
                  style: const TextStyle(fontSize: 16),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSection(FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condition',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['New', 'Almost New', 'Used', 'Fair'].map((condition) {
            final isSelected = viewModel.condition == condition;
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (selected) {
                viewModel.setCondition(selected ? condition : null);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF2F9CCF).withAlpha(51),
              checkmarkColor: const Color(0xFF2F9CCF),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2F9CCF) : Colors.black,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, FilterViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: viewModel.clearFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2F9CCF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFF2F9CCF)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              viewModel.applyFilters(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11384A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class PriceRangeDialog extends StatefulWidget {
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final Function(double?, double?) onApply;

  const PriceRangeDialog({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<PriceRangeDialog> createState() => _PriceRangeDialogState();
}

class _PriceRangeDialogState extends State<PriceRangeDialog> {
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMinPrice?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.initialMaxPrice?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Price Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum Price',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum Price',
              prefixText: '\$',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final min = double.tryParse(_minController.text);
            final max = double.tryParse(_maxController.text);
            widget.onApply(min, max);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }
}