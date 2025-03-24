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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortingOptions(filterViewModel),
              const SizedBox(height: 16),
              _buildPriceRangeFields(filterViewModel),
              const SizedBox(height: 16),
              _buildDateRangeSelector(context, filterViewModel),
              const SizedBox(height: 16),
              _buildConditionSelector(filterViewModel),
              const SizedBox(height: 24),
              _buildButtons(context, filterViewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortingOptions(FilterViewModel viewModel) {
    return Column(
      children: [
        ListTile(
          title: const Text('Price: Lowest first'),
          leading: Radio<SortOrder>(
            value: SortOrder.priceLowToHigh,
            groupValue: viewModel.sortOrder,
            onChanged: viewModel.setSortOrder,
          ),
        ),
        ListTile(
          title: const Text('Price: Highest first'),
          leading: Radio<SortOrder>(
            value: SortOrder.priceHighToLow,
            groupValue: viewModel.sortOrder,
            onChanged: viewModel.setSortOrder,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFields(FilterViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Min Price',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => viewModel.setMinPrice(double.tryParse(value)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Max Price',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => viewModel.setMaxPrice(double.tryParse(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, FilterViewModel viewModel) {
    return ListTile(
      title: const Text('Date Listed'),
      subtitle: Text(viewModel.dateFrom?.toString() ?? 'All time'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => viewModel.openDatePicker(context),
    );
  }

  Widget _buildConditionSelector(FilterViewModel viewModel) {
    return Wrap(
      spacing: 8,
      children: ['New', 'Almost New', 'Used', 'Fair'].map((condition) {
        return ChoiceChip(
          label: Text(condition),
          selected: viewModel.condition == condition,
          onSelected: (selected) {
            viewModel.setCondition(selected ? condition : null);
          },
        );
      }).toList(),
    );
  }

  Widget _buildButtons(BuildContext context, FilterViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: viewModel.clearFilters,
            child: const Text('Clear All'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              viewModel.applyFilters(context);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}