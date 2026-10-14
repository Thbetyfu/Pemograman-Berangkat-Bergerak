import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu berwarna solid dengan sudut sangat membulat seperti pada referensi.
///
/// Jika [hardShadow] true, kartu diberi bayangan hitam keras (tanpa blur) di
/// sisi kanan-bawah, ditambah garis tepi hitam bila [outline] true.
class ColorCard extends StatelessWidget {
  const ColorCard({
    super.key,
    required this.color,
    required this.child,
    this.decor,
    this.radius = 24,
    this.padding = const EdgeInsets.all(20),
    this.hardShadow = false,
    this.outline = true,
  });

  final Color color;
  final Widget child;

  /// Dekorasi yang digambar di belakang [child], mis. [BlockDecor].
  final Widget? decor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool hardShadow;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: hardShadow
            ? const [BoxShadow(color: AppColors.ink, offset: Offset(2.5, 3.5))]
            : null,
      ),
      child: DecoratedBox(
        // Garis tepi digambar di atas konten agar tidak tertutup dekorasi.
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: hardShadow && outline
              ? Border.all(color: AppColors.ink, width: 1.4)
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              if (decor != null) Positioned.fill(child: decor!),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
