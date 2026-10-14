import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/state/todo_controller.dart';
import 'package:todo_app/widgets/check_badge.dart';
import 'package:todo_app/widgets/filter_bar.dart';

void main() {
  /// Membuka aplikasi dengan penyimpanan tiruan. Tanpa [stored], controller
  /// memuat 6 contoh tugas (4 aktif, 2 selesai). Layarnya dibuat sangat tinggi
  /// supaya seluruh daftar langsung terbangun tanpa perlu scroll; [width]
  /// (dalam dp) dan [textScale] bisa diubah untuk menguji layar sempit / teks besar.
  Future<TodoController> pumpApp(
    WidgetTester tester, {
    String? stored,
    double width = 360,
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({'todos_v1': ?stored});
    final prefs = await SharedPreferences.getInstance();
    final controller = TodoController(prefs)..load();

    tester.view.physicalSize = Size(width * 3, 12000);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(TodoApp(controller: controller));
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('menampilkan ringkasan dan contoh tugas saat pertama dibuka', (tester) async {
    await pumpApp(tester);

    expect(find.text('Rencanakan harimu'), findsOneWidget);
    expect(find.text('Progres tugas'), findsOneWidget);
    expect(find.text('Tambah tugas baru'), findsOneWidget);
    expect(find.text('Kerjakan tugas aplikasi Flutter'), findsOneWidget);
    expect(find.byType(CheckBadge), findsNWidgets(6));
  });

  testWidgets('daftar kosong menampilkan panel ajakan', (tester) async {
    await pumpApp(tester, stored: '[]');

    expect(find.text('Belum ada tugas di sini.'), findsOneWidget);
    expect(find.byType(CheckBadge), findsNothing);
  });

  testWidgets('menambah tugas lewat bottom sheet', (tester) async {
    final controller = await pumpApp(tester, stored: '[]');

    await tester.tap(find.text('Tambah tugas baru'));
    await tester.pumpAndSettle();
    expect(find.text('Tugas baru'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Belajar Flutter');
    await tester.tap(find.text('Simpan tugas'));
    await tester.pumpAndSettle();

    expect(controller.totalCount, 1);
    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('Tugas ditambahkan'), findsOneWidget);
  });

  testWidgets('judul kosong menampilkan pesan kesalahan dan sheet tetap terbuka', (tester) async {
    final controller = await pumpApp(tester, stored: '[]');

    await tester.tap(find.text('Tambah tugas baru'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan tugas'));
    await tester.pumpAndSettle();

    expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
    expect(find.text('Tugas baru'), findsOneWidget);
    expect(controller.totalCount, 0);
  });

  testWidgets('mengetuk badge menyelesaikan tugas', (tester) async {
    final controller = await pumpApp(tester);
    expect(controller.doneCount, 2);

    // Kartu pertama adalah tugas aktif dengan tenggat terdekat.
    await tester.tap(find.byType(CheckBadge).first);
    await tester.pumpAndSettle();

    expect(controller.doneCount, 3);
    expect(controller.pendingCount, 3);
  });

  testWidgets('menghapus tugas bisa diurungkan', (tester) async {
    final controller = await pumpApp(tester);

    await tester.tap(find.text('Hapus').first);
    await tester.pumpAndSettle();
    expect(controller.totalCount, 5);
    expect(find.text('Tugas dihapus'), findsOneWidget);

    await tester.tap(find.text('Urungkan'));
    await tester.pumpAndSettle();
    expect(controller.totalCount, 6);
  });

  testWidgets('mengubah tugas lewat tombol Ubah', (tester) async {
    final controller = await pumpApp(tester);

    await tester.tap(find.text('Ubah').first);
    await tester.pumpAndSettle();
    expect(find.text('Ubah tugas'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Judul baru');
    await tester.tap(find.text('Simpan perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Judul baru'), findsOneWidget);
    expect(controller.visibleTodos.map((t) => t.title), contains('Judul baru'));
  });

  testWidgets('filter Selesai hanya menampilkan tugas yang selesai', (tester) async {
    await pumpApp(tester);

    final doneChip = find.descendant(
      of: find.byType(FilterBar),
      matching: find.text('Selesai'),
    );
    // Font uji (Ahem) sangat lebar sehingga chip bisa terdorong keluar layar.
    await tester.ensureVisible(doneChip);
    await tester.pumpAndSettle();
    await tester.tap(doneChip);
    await tester.pumpAndSettle();

    expect(find.byType(CheckBadge), findsNWidgets(2));
    expect(find.text('Kerjakan tugas aplikasi Flutter'), findsNothing);
  });

  testWidgets('halaman utama tidak overflow pada layar sempit dengan teks besar', (tester) async {
    await pumpApp(tester, width: 320, textScale: 1.6);

    expect(tester.takeException(), isNull);
    // Teks besar membuat halaman sangat panjang, jadi hanya sebagian kartu
    // yang terbangun (ListView membangun item secara malas).
    expect(find.byType(CheckBadge), findsWidgets);
  });

  testWidgets('form tugas tidak overflow pada layar sempit dengan teks besar', (tester) async {
    await pumpApp(tester, width: 320, textScale: 1.6, stored: '[]');

    await tester.tap(find.text('Tambah tugas baru'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas baru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol Bersihkan menghapus semua tugas selesai', (tester) async {
    final controller = await pumpApp(tester);

    await tester.tap(find.text('Bersihkan'));
    await tester.pumpAndSettle();

    expect(controller.doneCount, 0);
    expect(controller.totalCount, 4);
    expect(find.text('Bersihkan'), findsNothing);
  });
}
