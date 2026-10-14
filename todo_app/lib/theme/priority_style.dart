import 'package:flutter/material.dart';

import '../models/todo.dart';
import 'app_theme.dart';

/// Warna tiap tingkat prioritas, diambil dari palet desain referensi.
extension TodoPriorityStyle on TodoPriority {
  Color get color => switch (this) {
        TodoPriority.low => AppColors.purple,
        TodoPriority.medium => AppColors.orange,
        TodoPriority.high => AppColors.red,
      };
}
