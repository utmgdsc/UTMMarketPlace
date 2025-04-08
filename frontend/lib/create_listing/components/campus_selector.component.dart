import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';

class CampusSelector extends StatelessWidget {
  final bool showValidationErrors;

  const CampusSelector({
    super.key,
    required this.showValidationErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateListingViewModel>(
      builder: (_, model, __) {
        final bool showError = showValidationErrors && model.campus == null;
        final titleText = const Text(
          'Campus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        );

        final campusChips = Row(
          children: [
            _buildCampusChip('Mississauga', model),
            _buildCampusChip('St. George', model),
            _buildCampusChip('Scarborough', model),
          ],
        );

        final errorMessage = showError
            ? const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Select a campus to continue.',
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
            campusChips,
            errorMessage,
          ],
        );
      },
    );
  }

  Widget _buildCampusChip(String campus, CreateListingViewModel model) {
    final isSelected = model.campus == campus;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          campus,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF2F9CCF),
        onSelected: (selected) {
          if (selected) {
            model.setCampus(campus);
          } else if (model.campus == campus) {
            model.setCampus(null);
          }
        },
      ),
    );
  }
}
