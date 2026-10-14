import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/state/todo_controller.dart';

void main() {
  final now = DateTime(2026, 10, 14, 10);

  late SharedPreferences prefs;

  /// Membuat controller dengan penyimpanan tiruan. Tanpa [stored], data masih
  /// kosong sehingga controller memuat contoh tugas.
  Future<TodoController> createController({String? stored}) async {
    SharedPreferences.setMockInitialValues({'todos_v1': ?stored});
    prefs = await SharedPreferences.getInstance();
    return TodoController(prefs, clock: () => now)..load();
  }

  Future<TodoController> createEmpty() => createController(stored: '[]');

  test('peluncuran pertama mengisi contoh tugas', () async {
    final controller = await createController();

    expect(controller.totalCount, 6);
    expect(controller.doneCount, 2);
    expect(controller.pendingCount, 4);
  });

  test('daftar kosong yang tersimpan tidak diisi contoh lagi', () async {
    final controller = await createEmpty();

    expect(controller.totalCount, 0);
  });

  test('data rusak diabaikan dan dimulai dari daftar kosong', () async {
    final controller = await createController(stored: 'bukan-json{');

    expect(controller.totalCount, 0);
  });

  test('add menyimpan tugas dan bisa dimuat ulang', () async {
    final controller = await createEmpty();

    controller.add(
      title: 'Belajar Flutter',
      description: 'Bab state',
      priority: TodoPriority.high,
      dueAt: DateTime(2026, 10, 15, 8),
    );

    expect(controller.totalCount, 1);

    final reloaded = TodoController(prefs, clock: () => now)..load();
    expect(reloaded.totalCount, 1);
    final todo = reloaded.visibleTodos.single;
    expect(todo.title, 'Belajar Flutter');
    expect(todo.priority, TodoPriority.high);
    expect(todo.dueAt, DateTime(2026, 10, 15, 8));
  });

  test('add dua kali pada waktu yang sama menghasilkan id berbeda', () async {
    final controller = await createEmpty();

    final a = controller.add(title: 'A');
    final b = controller.add(title: 'B');

    expect(a.id, isNot(b.id));
  });

  test('toggle menandai selesai lalu membatalkannya', () async {
    final controller = await createEmpty();
    final todo = controller.add(title: 'Cuci baju');

    controller.toggle(todo.id);
    var current = controller.visibleTodos.single;
    expect(current.isDone, isTrue);
    expect(current.completedAt, now);
    expect(controller.doneCount, 1);

    controller.toggle(todo.id);
    current = controller.visibleTodos.single;
    expect(current.isDone, isFalse);
    expect(current.completedAt, isNull);
    expect(controller.doneCount, 0);
  });

  test('update mengganti isi tugas', () async {
    final controller = await createEmpty();
    final todo = controller.add(title: 'Lama');

    controller.update(todo.copyWith(title: 'Baru', priority: TodoPriority.low));

    final current = controller.visibleTodos.single;
    expect(current.title, 'Baru');
    expect(current.priority, TodoPriority.low);
  });

  test('remove mengembalikan tugas yang dihapus dan restore memulihkannya', () async {
    final controller = await createEmpty();
    final todo = controller.add(title: 'Sementara');

    final removed = controller.remove(todo.id);
    expect(removed?.title, 'Sementara');
    expect(controller.totalCount, 0);
    expect(controller.remove('tidak-ada'), isNull);

    controller.restore(removed!);
    expect(controller.totalCount, 1);

    // Restore dua kali tidak membuat duplikat.
    controller.restore(removed);
    expect(controller.totalCount, 1);
  });

  test('removeCompleted dan restoreAll', () async {
    final controller = await createController();

    final removed = controller.removeCompleted();
    expect(removed, hasLength(2));
    expect(controller.totalCount, 4);
    expect(controller.doneCount, 0);

    controller.restoreAll(removed);
    expect(controller.totalCount, 6);
    expect(controller.doneCount, 2);
  });

  test('urutan: tenggat terdekat dulu, tanpa tenggat di akhir, selesai paling bawah', () async {
    final controller = await createEmpty();
    controller.add(title: 'Tanpa tenggat');
    controller.add(title: 'Lusa', dueAt: DateTime(2026, 10, 16, 9));
    controller.add(title: 'Besok', dueAt: DateTime(2026, 10, 15, 9));
    final selesai = controller.add(title: 'Sudah selesai', dueAt: DateTime(2026, 10, 14, 8));
    controller.toggle(selesai.id);

    final titles = controller.visibleTodos.map((t) => t.title).toList();

    expect(titles, ['Besok', 'Lusa', 'Tanpa tenggat', 'Sudah selesai']);
  });

  test('filter menampilkan tugas sesuai statusnya', () async {
    final controller = await createController();

    controller.setFilter(TodoFilter.active);
    expect(controller.visibleTodos, hasLength(4));
    expect(controller.visibleTodos.every((t) => !t.isDone), isTrue);

    controller.setFilter(TodoFilter.done);
    expect(controller.visibleTodos, hasLength(2));
    expect(controller.visibleTodos.every((t) => t.isDone), isTrue);

    expect(controller.countFor(TodoFilter.all), 6);
    expect(controller.countFor(TodoFilter.active), 4);
    expect(controller.countFor(TodoFilter.done), 2);
  });

  test('perubahan disimpan sebagai JSON di penyimpanan lokal', () async {
    final controller = await createEmpty();
    controller.add(title: 'Tersimpan');

    final decoded = jsonDecode(prefs.getString('todos_v1')!) as List<dynamic>;

    expect(decoded, hasLength(1));
    expect((decoded.single as Map<String, dynamic>)['title'], 'Tersimpan');
  });

  test('listener dipanggil saat data berubah', () async {
    final controller = await createEmpty();
    var calls = 0;
    controller.addListener(() => calls++);

    final todo = controller.add(title: 'A');
    controller.toggle(todo.id);
    controller.setFilter(TodoFilter.done);
    controller.setFilter(TodoFilter.done); // sama: tidak memicu notifikasi

    expect(calls, 3);
  });
}
