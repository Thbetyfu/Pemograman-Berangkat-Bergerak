import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_count.dart';
import 'block_decor.dart';
import 'color_card.dart';

/// Kartu statistik kecil bergaris tepi hitam dengan bayangan keras
/// (setara kartu "Rewards earned" oranye dan "Pending rewards" pink).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.decorColor,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color decorColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$label: $value',
      child: ColorCard(
        color: color,
        radius: 22,
        hardShadow: true,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
        decor: BlockDecor(color: decorColor, layout: BlockLayout.scatter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: AppText.label)),
                const SizedBox(width: 8),
                Icon(icon, size: 20, color: AppColors.ink),
              ],
            ),
            const SizedBox(height: 22),
            AnimatedCount(value: value, style: AppText.stat),
          ],
        ),
      ),
    );
  }
}
