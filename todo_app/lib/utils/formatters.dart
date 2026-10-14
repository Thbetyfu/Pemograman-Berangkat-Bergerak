/// Fungsi pemformat tanggal & waktu berbahasa Indonesia.
/// Semuanya fungsi murni (menerima `now` sebagai argumen) agar mudah diuji.
library;

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _daysShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
const _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// "Rabu, 14 Oktober"
String formatFullDate(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// "Rab, 14 Okt"
String formatShortDate(DateTime d) =>
    '${_daysShort[d.weekday - 1]}, ${d.day} ${_monthsShort[d.month - 1]}';

/// "18.05"
String formatTime(DateTime d) => '${_two(d.hour)}.${_two(d.minute)}';

/// Selisih hari kalender antara [a] dan [b] (a - b), mengabaikan jam.
int calendarDaysBetween(DateTime a, DateTime b) {
  final da = DateTime.utc(a.year, a.month, a.day);
  final db = DateTime.utc(b.year, b.month, b.day);
  return da.difference(db).inDays;
}

/// "Hari ini, 18.00", "Besok, 08.00", "Kemarin, 17.00" atau "Jum, 16 Okt, 08.00".
String formatDueLabel(DateTime due, DateTime now) {
  final diff = calendarDaysBetween(due, now);
  final time = formatTime(due);
  return switch (diff) {
    0 => 'Hari ini, $time',
    1 => 'Besok, $time',
    -1 => 'Kemarin, $time',
    _ => '${formatShortDate(due)}, $time',
  };
}

/// Durasi singkat: "2 hari 5j", "18j 42m" atau "7m".
String formatSpan(Duration d) {
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return hours > 0 ? '$days hari ${hours}j' : '$days hari';
  if (d.inHours > 0) return '${d.inHours}j ${minutes}m';
  return '${d.inMinutes < 1 ? 1 : d.inMinutes}m';
}

/// "18j 42m tersisa" atau "Terlambat 2j 10m".
String formatRemaining(DateTime due, DateTime now) {
  final diff = due.difference(now);
  if (diff.isNegative) return 'Terlambat ${formatSpan(-diff)}';
  return '${formatSpan(diff)} tersisa';
}
