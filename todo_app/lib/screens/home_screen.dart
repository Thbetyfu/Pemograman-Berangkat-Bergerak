import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/todo.dart';
import '../state/todo_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_cta.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/hero_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/tap_scale.dart';
import '../widgets/todo_card.dart';
import '../widgets/todo_form_sheet.dart';

/// Layar utama: ringkasan progres di atas, daftar tugas di bawahnya.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final TodoController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late DateTime _now = DateTime.now();
  Timer? _ticker;

  TodoController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Perbarui teks "sisa waktu" setiap 30 detik.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => _refreshNow());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshNow();
  }

  void _refreshNow() {
    if (mounted) setState(() => _now = DateTime.now());
  }

  Future<void> _addTodo() async {
    final draft = await showTodoFormSheet(context);
    if (draft == null) return;
    _controller.add(
      title: draft.title,
      description: draft.description,
      priority: draft.priority,
      dueAt: draft.dueAt,
    );
    // Supaya tugas baru langsung terlihat.
    if (_controller.filter == TodoFilter.done) {
      _controller.setFilter(TodoFilter.all);
    }
    _showMessage('Tugas ditambahkan');
  }

  Future<void> _editTodo(Todo todo) async {
    final draft = await showTodoFormSheet(context, todo: todo);
    if (draft == null) return;
    _controller.update(
      todo.copyWith(
        title: draft.title,
        description: draft.description,
        priority: draft.priority,
        dueAt: draft.dueAt,
        clearDueAt: draft.dueAt == null,
      ),
    );
    _showMessage('Perubahan disimpan');
  }

  void _deleteTodo(Todo todo) {
    final removed = _controller.remove(todo.id);
    if (removed == null) return;
    _showMessage('Tugas dihapus', onUndo: () => _controller.restore(removed));
  }

  void _clearCompleted() {
    final removed = _controller.removeCompleted();
    if (removed.isEmpty) return;
    _showMessage(
      '${removed.length} tugas selesai dihapus',
      onUndo: () => _controller.restoreAll(removed),
    );
  }

  void _showMessage(String message, {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: onUndo == null ? 2 : 5),
          action: onUndo == null
              ? null
              : SnackBarAction(label: 'Urungkan', onPressed: onUndo),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: BottomCta(onTap: _addTodo),
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final todos = _controller.visibleTodos;
    // Dengan extendBody, padding bawah sudah memperhitungkan tinggi tombol "Tambah".
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomInset),
          children: [
            _Header(
              canClear: _controller.doneCount > 0,
              onClear: _clearCompleted,
            ),
            const SizedBox(height: 20),
            HeroCard(now: _now),
            const SizedBox(height: 14),
            ProgressCard(
              done: _controller.doneCount,
              total: _controller.totalCount,
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Selesai',
                      value: _controller.doneCount,
                      icon: Icons.emoji_events_outlined,
                      color: AppColors.orange,
                      decorColor: AppColors.orangeDeep,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StatCard(
                      label: 'Tertunda',
                      value: _controller.pendingCount,
                      icon: Icons.schedule_rounded,
                      color: AppColors.pink,
                      decorColor: AppColors.pinkDeep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text('Daftar tugas', style: AppText.h1)),
                Text('${todos.length} tugas', style: AppText.small),
              ],
            ),
            const SizedBox(height: 14),
            FilterBar(
              selected: _controller.filter,
              countFor: _controller.countFor,
              onChanged: _controller.setFilter,
            ),
            const SizedBox(height: 18),
            if (todos.isEmpty)
              EmptyState(
                filter: _controller.filter,
                hasAny: _controller.totalCount > 0,
              )
            else
              for (final todo in todos)
                Padding(
                  key: ValueKey(todo.id),
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _Entrance(
                    child: TodoCard(
                      todo: todo,
                      now: _now,
                      onToggle: () => _controller.toggle(todo.id),
                      onEdit: () => _editTodo(todo),
                      onDelete: () => _deleteTodo(todo),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Baris atas: logo kecil + judul, dan tombol "Bersihkan" (mengikuti pill
/// "My rewards" di referensi) yang muncul bila ada tugas selesai.
class _Header extends StatelessWidget {
  const _Header({required this.canClear, required this.onClear});

  final bool canClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.tile,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: const Icon(Icons.checklist_rounded, size: 24, color: AppColors.ink),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text('Todo List', style: AppText.h2)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: canClear
              ? _PillButton(
                  key: const ValueKey('clear'),
                  icon: Icons.delete_sweep_outlined,
                  label: 'Bersihkan',
                  onTap: onClear,
                )
              : const SizedBox.shrink(key: ValueKey('none')),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ink, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: AppColors.ink),
            const SizedBox(width: 7),
            Text(label, style: AppText.button.copyWith(fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

/// Animasi masuk (fade + naik sedikit) untuk kartu yang baru muncul.
class _Entrance extends StatelessWidget {
  const _Entrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
