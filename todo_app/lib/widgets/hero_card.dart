import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'block_decor.dart';
import 'color_card.dart';

/// Kartu ungu besar di bagian atas (setara kartu "Invite friends" di referensi).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ColorCard(
      color: AppColors.purple,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decor: const BlockDecor(
        color: AppColors.purpleDeep,
        layout: BlockLayout.cloud,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SparkleIcon(),
          const SizedBox(height: 34),
          Text(formatFullDate(now).toUpperCase(), style: AppText.eyebrow),
          const SizedBox(height: 8),
          Text('Rencanakan harimu', style: AppText.display),
          const SizedBox(height: 10),
          Text(
            'Catat tugas, tetapkan prioritas dan tenggat, '
            'lalu selesaikan satu per satu.',
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

/// Ikon garis tipis dengan kilau kecil, mengikuti ikon "orang + kilau" di referensi.
class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox(
        width: 46,
        height: 40,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: Icon(Icons.checklist_rounded, size: 36, color: AppColors.ink),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.auto_awesome, size: 15, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
