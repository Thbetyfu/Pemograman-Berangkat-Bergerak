import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../theme/priority_style.dart';
import '../utils/formatters.dart';
import 'outlined_action_button.dart';
import 'tap_scale.dart';

/// Hasil isian form, dikirim kembali ke pemanggil lewat `Navigator.pop`.
class TodoDraft {
  const TodoDraft({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueAt,
  });

  final String title;
  final String description;
  final TodoPriority priority;
  final DateTime? dueAt;
}

/// Menampilkan form tambah (atau ubah, bila [todo] diisi) sebagai bottom sheet.
/// Mengembalikan `null` jika dibatalkan.
Future<TodoDraft?> showTodoFormSheet(BuildContext context, {Todo? todo}) {
  return showModalBottomSheet<TodoDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => TodoFormSheet(todo: todo),
  );
}

class TodoFormSheet extends StatefulWidget {
  const TodoFormSheet({super.key, this.todo});

  final Todo? todo;

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  /// Jam yang dipakai bila pengguna hanya memilih tanggal: akhir hari.
  static const _endOfDay = TimeOfDay(hour: 23, minute: 59);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late TodoPriority _priority;
  DateTime? _date;
  TimeOfDay? _time;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _title = TextEditingController(text: todo?.title);
    _notes = TextEditingController(text: todo?.description);
    _priority = todo?.priority ?? TodoPriority.medium;
    final due = todo?.dueAt;
    if (due != null) {
      _date = DateUtils.dateOnly(due);
      _time = TimeOfDay.fromDateTime(due);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime? get _dueAt {
    final date = _date;
    if (date == null) return null;
    final time = _time ?? _endOfDay;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final earliest = DateTime(today.year - 1);
    final current = _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? today,
      firstDate: current != null && current.isBefore(earliest) ? current : earliest,
      lastDate: DateTime(today.year + 5, 12, 31),
      helpText: 'Pilih tanggal tenggat',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _time ??= _endOfDay;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 17, minute: 0),
      helpText: 'Pilih jam tenggat',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _time = picked;
      _date ??= DateUtils.dateOnly(DateTime.now());
    });
  }

  void _clearDue() => setState(() {
        _date = null;
        _time = null;
      });

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TodoDraft(
        title: _title.text.trim(),
        description: _notes.text.trim(),
        priority: _priority,
        dueAt: _dueAt,
      ),
    );
  }

  static String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  static final _fieldStyle = AppText.body.copyWith(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static OutlineInputBorder _border(Color color, [double width = 1.2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  static InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppText.body.copyWith(color: const Color(0xFF9A9A94)),
        filled: true,
        fillColor: const Color(0xFFF4F4F0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(AppColors.line),
        enabledBorder: _border(AppColors.line),
        focusedBorder: _border(AppColors.ink, 1.6),
        errorBorder: _border(AppColors.red, 1.4),
        focusedErrorBorder: _border(AppColors.red, 1.6),
        errorStyle: AppText.small.copyWith(
          color: AppColors.red,
          fontWeight: FontWeight.w700,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final date = _date;
    final time = _time;

    return Padding(
      // Naikkan sheet saat keyboard muncul.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(_isEditing ? 'Ubah tugas' : 'Tugas baru', style: AppText.h1),
                  const SizedBox(height: 20),
                  const _FieldLabel('Judul'),
                  TextFormField(
                    controller: _title,
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    style: _fieldStyle,
                    decoration: _decoration('Contoh: Kerjakan tugas Flutter'),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Catatan (opsional)'),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: _fieldStyle,
                    decoration: _decoration('Tambahkan detail tugas'),
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Prioritas'),
                  Row(
                    children: [
                      for (final p in TodoPriority.values) ...[
                        if (p != TodoPriority.values.first) const SizedBox(width: 10),
                        Expanded(
                          child: _PriorityOption(
                            priority: p,
                            selected: p == _priority,
                            onTap: () => setState(() => _priority = p),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Tenggat'),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.calendar_today_outlined,
                          label: date == null ? 'Pilih tanggal' : formatShortDate(date),
                          isSet: date != null,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.schedule_rounded,
                          label: time == null ? 'Pilih jam' : _timeLabel(time),
                          isSet: time != null,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  // AnimatedSize: baris "Hapus tenggat" muncul/hilang dengan halus,
                  // tidak membuat sheet melompat.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: date == null
                        ? const SizedBox(width: double.infinity)
                        : Align(
                            alignment: Alignment.centerRight,
                            child: TapScale(
                              onTap: _clearDue,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 12, 2, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColors.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Hapus tenggat',
                                      style: AppText.meta.copyWith(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedActionButton(
                          label: 'Batal',
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _SaveButton(
                          label: _isEditing ? 'Simpan perubahan' : 'Simpan tugas',
                          onTap: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppText.label),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final TodoPriority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: TapScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Warna harus opak: bayangan keras di bawahnya akan tembus kalau
            // isiannya semi-transparan.
            color: selected
                ? Color.alphaBlend(
                    priority.color.withValues(alpha: 0.24),
                    Colors.white,
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.4 : 1.2,
            ),
            boxShadow: selected
                ? const [BoxShadow(color: AppColors.ink, offset: Offset(1.5, 2))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: priority.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  priority.label,
                  style: AppText.button,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.isSet,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSet
              ? Color.alphaBlend(
                  AppColors.purple.withValues(alpha: 0.24),
                  Colors.white,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ink, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.ink),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(label, style: AppText.button, maxLines: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppText.button.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
