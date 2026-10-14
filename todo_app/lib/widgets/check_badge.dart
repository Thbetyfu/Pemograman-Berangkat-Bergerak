import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tap_scale.dart';

/// Kotak ikon berwarna (setara badge hijau/merah pada kartu notifikasi di
/// referensi) yang berfungsi sebagai kotak centang. Kosong = belum selesai,
/// hijau bercentang = selesai.
class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key, required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: done ? 'Tandai belum selesai' : 'Tandai selesai',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: done ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.ink, width: 1.4),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(2, 2.5)),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: done
              ? const Icon(
                  Icons.check_rounded,
                  key: ValueKey('done'),
                  size: 26,
                  color: AppColors.ink,
                )
              : const SizedBox.shrink(key: ValueKey('open')),
        ),
      ),
    );
  }
}
