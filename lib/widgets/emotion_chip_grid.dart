import 'package:flutter/material.dart';

class EmotionChipGrid extends StatelessWidget {
  const EmotionChipGrid({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (v) {
            if (v) {
              onChanged([...selectedTags, tag]);
            } else {
              onChanged(selectedTags.where((t) => t != tag).toList());
            }
          },
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }
}
