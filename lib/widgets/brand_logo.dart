import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// BridgeInspect Pro brand lockup. Renders the bridge mark + wordmark.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 28,
    this.color,
    this.tagline,
    this.compact = false,
  });

  final double size;
  final Color? color;
  final String? tagline;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BridgeMark(size: size, color: c),
        SizedBox(width: size * 0.35),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BridgeInspect',
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.78,
                letterSpacing: -0.4,
                height: 1,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 2),
              Text(
                tagline ?? 'PRO',
                style: TextStyle(
                  color: c.withOpacity(0.75),
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.34,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _BridgeMark extends StatelessWidget {
  const _BridgeMark({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.15,
      height: size * 1.15,
      child: CustomPaint(painter: _BridgePainter(color: color)),
    );
  }
}

class _BridgePainter extends CustomPainter {
  _BridgePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Suspension bridge silhouette
    final w = size.width;
    final h = size.height;
    // Towers
    canvas.drawLine(Offset(w * 0.22, h * 0.20), Offset(w * 0.22, h * 0.78), paint);
    canvas.drawLine(Offset(w * 0.78, h * 0.20), Offset(w * 0.78, h * 0.78), paint);
    // Cable curve
    final cable = Path()
      ..moveTo(w * 0.22, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.62, w * 0.78, h * 0.30);
    canvas.drawPath(cable, paint);
    // Deck
    final deckPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.05, h * 0.78), Offset(w * 0.95, h * 0.78), deckPaint);
  }

  @override
  bool shouldRepaint(covariant _BridgePainter oldDelegate) =>
      oldDelegate.color != color;
}
