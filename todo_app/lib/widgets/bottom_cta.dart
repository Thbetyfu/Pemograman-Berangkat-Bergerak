import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'tap_scale.dart';

/// Tombol "Tambah tugas baru" berbentuk pill abu-abu dengan tombol bulat di
/// kanan (setara pill "Shop with confidence" pada referensi). Dipasang di
/// `Scaffold.bottomNavigationBar`; latarnya memudar agar daftar yang
/// bergulir di belakangnya tidak terpotong kasar.
class BottomCta extends StatelessWidget {
  const BottomCta({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
            AppColors.background,
          ],
          stops: const [0, 0.32, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        // heightFactor: 1 -> tingginya mengikuti isi. Tanpa ini Center melebar
        // setinggi layar dan menutupi seluruh daftar.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: TapScale(
                onTap: onTap,
                scale: 0.98,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 68),
                  padding: const EdgeInsets.fromLTRB(26, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECE7),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: const Color(0xFFDCDCD6)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Tambah tugas baru', style: AppText.title),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
