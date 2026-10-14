import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_count.dart';
import 'block_decor.dart';
import 'color_card.dart';

/// Kartu hitam dengan bar progres bersegmen (setara kartu "Vintage explorer").
///
/// Jika tugas ≤ 10, satu segmen mewakili satu tugas. Jika lebih banyak, bar
/// tetap 10 segmen dan terisi secara proporsional.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.done, required this.total});

  final int done;
  final int total;

  int get _segments => total == 0 ? 10 : math.min(10, total);

  int get _filled {
    if (total == 0) return 0;
    if (total <= 10) return done;
    if (done >= total) return 10;
    if (done == 0) return 0;
    return (done * 10 / total).round().clamp(1, 9);
  }

  String get _caption {
    if (total == 0) return 'Belum ada tugas. Tambahkan yang pertama!';
    if (done >= total) return 'Luar biasa! Semua tugas sudah selesai.';
    return 'Selesaikan ${total - done} tugas lagi untuk menuntaskan semuanya.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Progres tugas: $done dari $total selesai. $_caption',
      child: ColorCard(
        color: AppColors.darkCard,
        radius: 26,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decor: const BlockDecor(
          color: AppColors.darkDecor,
          layout: BlockLayout.steps,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Progres tugas',
                    style: AppText.h2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedCount(
                  value: done,
                  style: AppText.h2.copyWith(color: Colors.white),
                ),
                Text(
                  ' / $total',
                  style: AppText.h2.copyWith(color: AppColors.darkMuted),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Segments(count: _segments, filled: _filled),
            const SizedBox(height: 14),
            Text(
              _caption,
              style: AppText.small.copyWith(color: AppColors.darkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.count, required this.filled});

  final int count;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: AnimatedContainer(
              // Durasi bertingkat membuat segmen terisi seperti gelombang.
              duration: Duration(milliseconds: 260 + i * 40),
              curve: Curves.easeOut,
              height: 13,
              decoration: BoxDecoration(
                color: i < filled ? AppColors.segmentOn : AppColors.segmentOff,
                borderRadius: BorderRadius.circular(4.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
