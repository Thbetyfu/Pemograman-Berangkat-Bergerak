import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  final created = DateTime(2026, 10, 14, 9);

  test('toJson lalu fromJson menghasilkan data yang sama', () {
    final todo = Todo(
      id: 'a1',
      title: 'Belajar Flutter',
      description: 'Bab widget',
      priority: TodoPriority.high,
      dueAt: DateTime(2026, 10, 15, 20, 30),
      isDone: true,
      createdAt: created,
      completedAt: DateTime(2026, 10, 14, 12),
    );

    final copy = Todo.fromJson(todo.toJson());

    expect(copy.id, 'a1');
    expect(copy.title, 'Belajar Flutter');
    expect(copy.description, 'Bab widget');
    expect(copy.priority, TodoPriority.high);
    expect(copy.dueAt, DateTime(2026, 10, 15, 20, 30));
    expect(copy.isDone, isTrue);
    expect(copy.createdAt, created);
    expect(copy.completedAt, DateTime(2026, 10, 14, 12));
  });

  test('fromJson memakai nilai bawaan untuk field yang hilang atau tidak dikenal', () {
    final todo = Todo.fromJson({
      'id': 'x',
      'title': 'Tanpa detail',
      'priority': 'tidak-ada',
      'createdAt': created.toIso8601String(),
    });

    expect(todo.description, '');
    expect(todo.priority, TodoPriority.medium);
    expect(todo.dueAt, isNull);
    expect(todo.isDone, isFalse);
  });

  test('copyWith bisa mengosongkan tenggat', () {
    final todo = Todo(
      id: 'a',
      title: 'T',
      createdAt: created,
      dueAt: DateTime(2026, 10, 20),
    );

    expect(todo.copyWith(title: 'Baru').dueAt, DateTime(2026, 10, 20));
    expect(todo.copyWith(clearDueAt: true).dueAt, isNull);
  });

  test('isOverdue hanya benar untuk tugas aktif yang lewat tenggat', () {
    final now = DateTime(2026, 10, 14, 12);
    final late = Todo(
      id: 'l',
      title: 'Telat',
      createdAt: created,
      dueAt: DateTime(2026, 10, 14, 11),
    );

    expect(late.isOverdue(now), isTrue);
    expect(late.copyWith(isDone: true).isOverdue(now), isFalse);
    expect(late.copyWith(dueAt: DateTime(2026, 10, 14, 13)).isOverdue(now), isFalse);
    expect(late.copyWith(clearDueAt: true).isOverdue(now), isFalse);
  });
}
