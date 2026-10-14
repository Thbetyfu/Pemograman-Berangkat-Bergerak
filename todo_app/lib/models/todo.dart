/// Tingkat prioritas sebuah tugas.
enum TodoPriority {
  low('Rendah'),
  medium('Sedang'),
  high('Tinggi');

  const TodoPriority(this.label);

  final String label;
}

/// Satu item pada daftar tugas. Objek ini tidak bisa diubah (immutable);
/// untuk memperbarui gunakan [copyWith].
class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.priority = TodoPriority.medium,
    this.dueAt,
    this.isDone = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final TodoPriority priority;
  final DateTime? dueAt;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Membuat salinan dengan beberapa field diganti.
  /// Gunakan [clearDueAt] / [clearCompletedAt] untuk mengosongkan field nullable.
  Todo copyWith({
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueAt,
    bool clearDueAt = false,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  /// Apakah tugas ini melewati tenggat dan belum selesai.
  bool isOverdue(DateTime now) =>
      !isDone && dueAt != null && dueAt!.isBefore(now);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.name,
        'dueAt': dueAt?.toIso8601String(),
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      priority: TodoPriority.values.asNameMap()[json['priority']] ??
          TodoPriority.medium,
      dueAt: _parseDate(json['dueAt']),
      isDone: (json['isDone'] as bool?) ?? false,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      completedAt: _parseDate(json['completedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
