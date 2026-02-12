import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class IntensitySlider extends StatelessWidget {
  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: intensityColor(value),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: primary,
            overlayColor: primary.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '약함',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '강함',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
