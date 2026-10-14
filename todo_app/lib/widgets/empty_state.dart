import 'package:flutter/material.dart';

import '../state/todo_controller.dart';
import '../theme/app_theme.dart';
import 'block_decor.dart';
import 'color_card.dart';

/// Tampilan saat daftar kosong: panel oranye berisi dua "gelembung obrolan"
/// bertinta hitam, mengikuti panel "Your closet might be worth more..." di referensi.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.filter, required this.hasAny});

  final TodoFilter filter;

  /// Apakah ada tugas sama sekali (di semua filter).
  final bool hasAny;

  (String, String) get _copy {
    if (!hasAny) {
      return (
        'Belum ada tugas di sini.',
        'Ketuk "Tambah tugas baru" untuk mulai mencatat.',
      );
    }
    if (filter == TodoFilter.active) {
      return (
        'Semua tugas sudah beres!',
        'Saatnya istirahat, kamu layak mendapatkannya.',
      );
    }
    return (
      'Belum ada yang selesai.',
      'Centang tugas pertamamu dan rayakan kemenangan kecil.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final (first, second) = _copy;
    return ColorCard(
      color: AppColors.orange,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decor: const BlockDecor(
        color: AppColors.orangeDeep,
        layout: BlockLayout.steps,
      ),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: _Bubble(text: first)),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 36),
              child: _Bubble(text: second),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColorCard(
      color: AppColors.orangeLight,
      radius: 20,
      hardShadow: true,
      outline: false,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Text(text, style: AppText.h2.copyWith(fontSize: 19, height: 1.2)),
    );
  }
}
