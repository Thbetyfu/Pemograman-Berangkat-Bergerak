import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/utils/formatters.dart';

void main() {
  // Rabu, 14 Oktober 2026, pukul 10.00.
  final now = DateTime(2026, 10, 14, 10);

  group('tanggal dan jam', () {
    test('formatFullDate memakai nama hari dan bulan Indonesia', () {
      expect(formatFullDate(now), 'Rabu, 14 Oktober');
    });

    test('formatShortDate menyingkat hari dan bulan', () {
      expect(formatShortDate(now), 'Rab, 14 Okt');
    });

    test('formatTime memakai titik dan nol di depan', () {
      expect(formatTime(DateTime(2026, 10, 14, 8, 5)), '08.05');
    });
  });

  group('formatDueLabel', () {
    test('hari ini, besok, dan kemarin', () {
      expect(formatDueLabel(DateTime(2026, 10, 14, 18), now), 'Hari ini, 18.00');
      expect(formatDueLabel(DateTime(2026, 10, 15, 8), now), 'Besok, 08.00');
      expect(formatDueLabel(DateTime(2026, 10, 13, 17), now), 'Kemarin, 17.00');
    });

    test('tanggal lain menampilkan hari dan tanggal singkat', () {
      expect(formatDueLabel(DateTime(2026, 10, 16, 8), now), 'Jum, 16 Okt, 08.00');
    });

    test('tidak terpengaruh jam saat melewati tengah malam', () {
      final lateNight = DateTime(2026, 10, 14, 23, 50);
      expect(formatDueLabel(DateTime(2026, 10, 15, 0, 10), lateNight), 'Besok, 00.10');
    });
  });

  group('formatSpan', () {
    test('jam dan menit', () {
      expect(formatSpan(const Duration(hours: 18, minutes: 42)), '18j 42m');
    });

    test('hari dan jam', () {
      expect(formatSpan(const Duration(days: 2, hours: 5, minutes: 10)), '2 hari 5j');
      expect(formatSpan(const Duration(days: 3)), '3 hari');
    });

    test('kurang dari semenit dibulatkan menjadi 1m', () {
      expect(formatSpan(const Duration(seconds: 20)), '1m');
      expect(formatSpan(const Duration(minutes: 7)), '7m');
    });
  });

  group('formatRemaining', () {
    test('masih ada waktu', () {
      final due = now.add(const Duration(hours: 18, minutes: 42));
      expect(formatRemaining(due, now), '18j 42m tersisa');
    });

    test('sudah terlambat', () {
      final due = now.subtract(const Duration(hours: 2, minutes: 10));
      expect(formatRemaining(due, now), 'Terlambat 2j 10m');
    });
  });
}
