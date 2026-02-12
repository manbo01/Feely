import 'package:flutter/material.dart';

class EmotionChipGrid extends StatelessWidget {
  const EmotionChipGrid({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
    this.onAddNew,
  });

  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback? onAddNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...availableTags.map((tag) {
          final isSelected = selectedTags.contains(tag);
          final isDark = theme.brightness == Brightness.dark;
          final labelColor = isDark
              ? (isSelected ? Colors.black : Colors.white)
              : (isSelected ? Colors.white : Colors.black);
          return FilterChip(
            label: Text(
              tag,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (v) {
              if (v) {
                onChanged([...selectedTags, tag]);
              } else {
                onChanged(selectedTags.where((t) => t != tag).toList());
              }
            },
            selectedColor: primary,
            checkmarkColor: Colors.transparent,
            showCheckmark: false,
            side: BorderSide(color: primary, width: 1),
            backgroundColor: primary.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
        if (onAddNew != null)
          FilterChip(
            label: Text(
              '+',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            selected: false,
            onSelected: (_) => onAddNew!(),
            selectedColor: primary,
            checkmarkColor: Colors.transparent,
            showCheckmark: false,
            side: BorderSide(color: primary, width: 1),
            backgroundColor: primary.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }
}
