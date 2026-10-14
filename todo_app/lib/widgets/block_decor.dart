import 'package:flutter/material.dart';

/// Variasi susunan blok dekoratif.
enum BlockLayout { cloud, steps, scatter }

/// Dekorasi "blok piksel" berwarna lebih gelap yang muncul di sudut kartu
/// pada desain referensi. Digambar dengan [CustomPaint] di belakang konten.
class BlockDecor extends StatelessWidget {
  const BlockDecor({
    super.key,
    required this.color,
    this.layout = BlockLayout.cloud,
  });

  final Color color;
  final BlockLayout layout;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(painter: _BlockPainter(color: color, layout: layout)),
      ),
    );
  }
}

class _BlockPainter extends CustomPainter {
  const _BlockPainter({required this.color, required this.layout});

  final Color color;
  final BlockLayout layout;

  /// Posisi tiap blok sebagai pecahan (0..1) dari lebar dan tinggi kartu.
  /// Nilai di luar 0..1 membuat blok "keluar" dari tepi dan terpotong kartu.
  static const _layouts = <BlockLayout, List<Rect>>{
    BlockLayout.cloud: [
      Rect.fromLTRB(0.56, -0.06, 1.06, 0.28),
      Rect.fromLTRB(0.46, 0.33, 1.06, 0.50),
    ],
    BlockLayout.steps: [
      Rect.fromLTRB(0.66, -0.10, 1.06, 0.44),
      Rect.fromLTRB(0.56, 0.52, 1.06, 0.80),
    ],
    BlockLayout.scatter: [
      Rect.fromLTRB(0.52, -0.08, 1.06, 0.34),
      Rect.fromLTRB(0.62, 0.42, 1.06, 0.66),
      Rect.fromLTRB(0.18, 0.60, 0.58, 1.08),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const radius = Radius.circular(10);
    for (final r in _layouts[layout]!) {
      final rect = Rect.fromLTRB(
        r.left * size.width,
        r.top * size.height,
        r.right * size.width,
        r.bottom * size.height,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    }
  }

  @override
  bool shouldRepaint(_BlockPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.layout != layout;
}
