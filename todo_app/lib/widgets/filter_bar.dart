import 'package:flutter/material.dart';

import '../state/todo_controller.dart';
import '../theme/app_theme.dart';
import 'tap_scale.dart';

/// Deretan pill filter: Semua / Aktif / Selesai, lengkap dengan jumlahnya.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selected,
    required this.countFor,
    required this.onChanged,
  });

  final TodoFilter selected;
  final int Function(TodoFilter filter) countFor;
  final ValueChanged<TodoFilter> onChanged;

  static const _labels = {
    TodoFilter.all: 'Semua',
    TodoFilter.active: 'Aktif',
    TodoFilter.done: 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in TodoFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _FilterChip(
                label: _labels[filter]!,
                count: countFor(filter),
                selected: filter == selected,
                onTap: () => onChanged(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: TapScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppText.button.copyWith(
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '$count',
                style: AppText.button.copyWith(
                  color: selected ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
