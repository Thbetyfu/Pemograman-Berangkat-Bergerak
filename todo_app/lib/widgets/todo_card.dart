import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../theme/priority_style.dart';
import '../utils/formatters.dart';
import 'check_badge.dart';
import 'outlined_action_button.dart';

/// Kartu putih untuk satu tugas (setara kartu "Purchase completed" di referensi):
/// badge berwarna + judul, deskripsi, info sisa waktu, dan tombol outline.
class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.now,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = todo.isDone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckBadge(done: done, onTap: onToggle),
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      todo.title,
                      style: AppText.title.copyWith(
                        fontSize: 17,
                        color: done ? AppColors.muted : AppColors.ink,
                        decoration:
                            done ? TextDecoration.lineThrough : TextDecoration.none,
                        decorationColor: AppColors.muted,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (todo.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              todo.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.small.copyWith(
                color: done ? AppColors.muted : const Color(0xFF4B4B46),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _MetaInfo(todo: todo, now: now)),
              const SizedBox(width: 10),
              _PriorityChip(priority: todo.priority),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedActionButton(
                  label: 'Ubah',
                  icon: Icons.edit_outlined,
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedActionButton(
                  label: 'Hapus',
                  icon: Icons.close_rounded,
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Baris info waktu: ikon jam + sisa waktu (mis. "18j 42m tersisa"), diikuti
/// tenggat lengkap. Merah bila terlambat.
class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.todo, required this.now});

  final Todo todo;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final due = todo.dueAt;
    final completedAt = todo.completedAt;

    final IconData icon;
    final Color iconColor;
    final String primary;
    Color primaryColor = AppColors.ink;
    String? secondary;

    if (todo.isDone) {
      icon = Icons.check_circle_outline_rounded;
      iconColor = AppColors.green;
      primary = 'Selesai';
      primaryColor = AppColors.muted;
      if (completedAt != null) secondary = formatDueLabel(completedAt, now);
    } else if (due != null) {
      final overdue = todo.isOverdue(now);
      icon = Icons.schedule_rounded;
      iconColor = overdue ? AppColors.red : AppColors.ink;
      primary = formatRemaining(due, now);
      primaryColor = overdue ? AppColors.red : AppColors.ink;
      secondary = formatDueLabel(due, now);
    } else {
      icon = Icons.schedule_rounded;
      iconColor = AppColors.muted;
      primary = 'Tanpa tenggat';
      primaryColor = AppColors.muted;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: 6),
              // Flexible: pada layar sempit / font besar teks turun baris, bukan overflow.
              Flexible(
                child: Text(
                  primary,
                  style: AppText.meta.copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
          if (secondary != null)
            Text(
              secondary,
              style: AppText.meta.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final TodoPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: AppText.meta.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
