import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import 'asset_detail_screen.dart';

/// Real QR / barcode scanner using `mobile_scanner` (ML-Kit on Android,
/// AVFoundation on iOS). The reticle is perfectly centred and a manual entry
/// field is always available as a fallback.
class AssetScanScreen extends StatefulWidget {
  const AssetScanScreen({super.key});

  @override
  State<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends State<AssetScanScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final TextEditingController _manual = TextEditingController(text: 'BR-NAJ-013');
  bool _torch = false;
  bool _handled = false;

  @override
  void dispose() {
    _scanner.dispose();
    _manual.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue ?? '')
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (raw.isEmpty) return;
    _handled = true;
    _resolveAndOpen(raw);
  }

  void _resolveAndOpen(String code) {
    final normalised = code.trim().toUpperCase();
    final match = DummyData.assets.firstWhere(
      (a) => a.id.toUpperCase() == normalised,
      orElse: () => DummyData.assets.first,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: match)),
    );
  }

  void _findManual() => _resolveAndOpen(_manual.text);

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Scan asset',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18)),
                      Text('Point the camera at the QR / barcode tag',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _scanner.toggleTorch();
                    setState(() => _torch = !_torch);
                  },
                  icon: Icon(_torch ? Icons.flash_on : Icons.flash_off),
                  color: AppColors.textPrimary,
                  tooltip: 'Torch',
                ),
                IconButton(
                  onPressed: () async {
                    await _scanner.switchCamera();
                  },
                  icon: const Icon(Icons.cameraswitch),
                  color: AppColors.textPrimary,
                  tooltip: 'Switch camera',
                ),
              ]),
            ),

            // ---- Scanner area (centered) ----
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 480, maxHeight: 720),
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(fit: StackFit.expand, children: [
                          MobileScanner(
                            controller: _scanner,
                            onDetect: _onDetect,
                            errorBuilder: (context, err, _) => Container(
                              color: const Color(0xFF1B1B1B),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.no_photography_outlined,
                                        color: Colors.white60, size: 36),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Camera unavailable: ${err.errorCode.name}\n'
                                      'Use manual entry below.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Centred reticle overlay
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(painter: _ReticlePainter()),
                            ),
                          ),
                          // Hint pill
                          Positioned(
                            left: 0, right: 0, bottom: 14,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Hold steady · tag inside the frame',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---- Manual entry footer ----
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 14, pad, 16),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OR ENTER ASSET ID MANUALLY',
                      style: TextStyle(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _manual,
                          textCapitalization: TextCapitalization.characters,
                          decoration:
                              const InputDecoration(hintText: 'e.g. BR-RUH-001'),
                          onSubmitted: (_) => _findManual(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _findManual,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(96, 48)),
                        child: const Text('Find'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dim the area outside the reticle.
    const inset = 36.0;
    final r = Rect.fromLTWH(
        inset, inset, size.width - inset * 2, size.height - inset * 2);
    final overlay = Paint()..color = Colors.black.withOpacity(0.45);
    final everything = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(16)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, everything, hole),
      overlay,
    );

    // Crisp white frame
    final frame = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(16)), frame);

    // Brand-coloured corner brackets
    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 26.0;
    final corners = [
      [Offset(r.left, r.top + arm),
          Offset(r.left, r.top), Offset(r.left + arm, r.top)],
      [Offset(r.right - arm, r.top),
          Offset(r.right, r.top), Offset(r.right, r.top + arm)],
      [Offset(r.right, r.bottom - arm),
          Offset(r.right, r.bottom), Offset(r.right - arm, r.bottom)],
      [Offset(r.left + arm, r.bottom),
          Offset(r.left, r.bottom), Offset(r.left, r.bottom - arm)],
    ];
    for (final c in corners) {
      final p = Path()
        ..moveTo(c[0].dx, c[0].dy)
        ..lineTo(c[1].dx, c[1].dy)
        ..lineTo(c[2].dx, c[2].dy);
      canvas.drawPath(p, corner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
