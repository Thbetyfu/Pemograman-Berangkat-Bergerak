import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

enum TodoFilter { all, active, done }

/// Menyimpan seluruh daftar tugas, menyediakan operasi CRUD, dan menyimpannya
/// ke penyimpanan lokal setiap ada perubahan. UI cukup mendengarkan controller
/// ini (lihat `ListenableBuilder` di HomeScreen).
class TodoController extends ChangeNotifier {
  TodoController(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static const _todosKey = 'todos_v1';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  List<Todo> _todos = [];
  TodoFilter _filter = TodoFilter.all;
  int _sequence = 0;

  TodoFilter get filter => _filter;
  int get totalCount => _todos.length;
  int get doneCount => _todos.where((t) => t.isDone).length;
  int get pendingCount => totalCount - doneCount;

  int countFor(TodoFilter filter) => switch (filter) {
        TodoFilter.all => totalCount,
        TodoFilter.active => pendingCount,
        TodoFilter.done => doneCount,
      };

  /// Tugas yang tampil sesuai filter: yang belum selesai di atas (urut tenggat
  /// terdekat), yang sudah selesai di bawah (terbaru dulu).
  List<Todo> get visibleTodos {
    final list = _todos.where((t) {
      return switch (_filter) {
        TodoFilter.all => true,
        TodoFilter.active => !t.isDone,
        TodoFilter.done => t.isDone,
      };
    }).toList()
      ..sort(_compare);
    return list;
  }

  static int _compare(Todo a, Todo b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
    if (a.isDone) {
      return (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt);
    }
    final aDue = a.dueAt;
    final bDue = b.dueAt;
    if (aDue != null && bDue != null) {
      final byDue = aDue.compareTo(bDue);
      if (byDue != 0) return byDue;
    } else if (aDue != null) {
      return -1;
    } else if (bDue != null) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  /// Membaca data tersimpan. Pada peluncuran pertama diisi contoh tugas.
  void load() {
    final raw = _prefs.getString(_todosKey);
    if (raw == null) {
      _todos = _sampleTodos(_clock());
      _persist();
    } else {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _todos = [
          for (final item in decoded)
            Todo.fromJson(item as Map<String, dynamic>),
        ];
      } catch (_) {
        _todos = []; // Data rusak: mulai dari daftar kosong.
      }
    }
    notifyListeners();
  }

  Todo add({
    required String title,
    String description = '',
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueAt,
  }) {
    final now = _clock();
    final todo = Todo(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      title: title,
      description: description,
      priority: priority,
      dueAt: dueAt,
      createdAt: now,
    );
    _todos = [..._todos, todo];
    _commit();
    return todo;
  }

  void update(Todo updated) {
    _todos = [for (final t in _todos) t.id == updated.id ? updated : t];
    _commit();
  }

  /// Membalik status selesai / belum selesai.
  void toggle(String id) {
    final now = _clock();
    _todos = [
      for (final t in _todos)
        if (t.id != id)
          t
        else if (t.isDone)
          t.copyWith(isDone: false, clearCompletedAt: true)
        else
          t.copyWith(isDone: true, completedAt: now),
    ];
    _commit();
  }

  /// Menghapus satu tugas; mengembalikan tugas yang dihapus untuk fitur "Urungkan".
  Todo? remove(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index < 0) return null;
    final removed = _todos[index];
    _todos = [..._todos]..removeAt(index);
    _commit();
    return removed;
  }

  void restore(Todo todo) => restoreAll([todo]);

  /// Menghapus semua tugas yang sudah selesai; mengembalikan daftar yang dihapus.
  List<Todo> removeCompleted() {
    final removed = _todos.where((t) => t.isDone).toList();
    if (removed.isEmpty) return removed;
    _todos = _todos.where((t) => !t.isDone).toList();
    _commit();
    return removed;
  }

  void restoreAll(Iterable<Todo> todos) {
    final existing = {for (final t in _todos) t.id};
    _todos = [..._todos, ...todos.where((t) => !existing.contains(t.id))];
    _commit();
  }

  void setFilter(TodoFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void _commit() {
    _persist();
    notifyListeners();
  }

  void _persist() {
    final json = jsonEncode([for (final t in _todos) t.toJson()]);
    unawaited(_prefs.setString(_todosKey, json));
  }

  /// Contoh data supaya tampilan langsung terlihat saat pertama kali dibuka.
  List<Todo> _sampleTodos(DateTime now) {
    DateTime atDay(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);

    return [
      Todo(
        id: 'sample-1',
        title: 'Kerjakan tugas aplikasi Flutter',
        description:
            'Bangun aplikasi todo list yang mengikuti desain referensi dari Dribbble.',
        priority: TodoPriority.high,
        dueAt: now.add(const Duration(hours: 4, minutes: 20)),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Todo(
        id: 'sample-2',
        title: 'Pelajari widget dan state management',
        description: 'StatelessWidget, StatefulWidget, setState, dan ChangeNotifier.',
        priority: TodoPriority.medium,
        dueAt: atDay(1, 20),
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Todo(
        id: 'sample-3',
        title: 'Kumpulkan laporan praktikum',
        description: 'Unggah file PDF ke LMS sebelum jam pengumpulan ditutup.',
        priority: TodoPriority.high,
        dueAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Todo(
        id: 'sample-4',
        title: 'Olahraga ringan',
        description: 'Jogging 20 menit di sekitar kampus.',
        priority: TodoPriority.low,
        dueAt: atDay(2, 6, 30),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Todo(
        id: 'sample-5',
        title: 'Beli kebutuhan bulanan',
        description: 'Sabun, sikat gigi, dan camilan untuk begadang.',
        priority: TodoPriority.low,
        isDone: true,
        completedAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Todo(
        id: 'sample-6',
        title: 'Rapikan catatan kuliah',
        priority: TodoPriority.medium,
        isDone: true,
        completedAt: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
