import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';

class ConditionSelector extends StatelessWidget {
  final bool showValidationErrors;

  const ConditionSelector({
    super.key,
    required this.showValidationErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateListingViewModel>(
      builder: (_, model, __) {
        final bool showError = showValidationErrors && model.condition.isEmpty;
        
        final titleText = const Text(
          'Condition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        );
        
        final conditionChips = Row(
          children: [
            _buildConditionChip('New', model),
            _buildConditionChip('Almost New', model),
            _buildConditionChip('Used', model),
            _buildConditionChip('Fair', model),
          ],
        );
        
        final errorMessage = showError
          ? const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Select a condition to continue.',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 12,
                ),
              ),
            )
          : const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText,
            const SizedBox(height: 8),
            conditionChips,
            errorMessage,
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
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF2F9CCF),
        onSelected: (selected) {
          if (selected) {
            model.setCondition(condition);
          }
        },
      ),
    );
  }
}