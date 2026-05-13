import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import 'asset_detail_screen.dart';

/// "Scan asset" — Step 1 of 2.
///
/// We don't bind to a real camera plugin (keeps the demo build dependency-free).
/// Instead we fake the scanner with an animated viewfinder + reticle that
/// "auto-detects" an asset code after a couple of seconds. Manual entry still
/// works as a fallback.
class AssetScanScreen extends StatefulWidget {
  const AssetScanScreen({super.key});

  @override
  State<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends State<AssetScanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanLine;
  late final AnimationController _pulse;

  final _manualCtrl = TextEditingController(text: 'BR-NAJ-013');
  Timer? _autoDetect;
  Asset? _detected;
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Simulate the camera locking onto a tag after a moment.
    _autoDetect = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final pool = DummyData.assets.toList()..shuffle(Random());
      setState(() {
        _detected = pool.first;
        _scanning = false;
      });
      _scanLine.stop();
      _pulse.stop();
    });
  }

  @override
  void dispose() {
    _autoDetect?.cancel();
    _scanLine.dispose();
    _pulse.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _restartScan() {
    setState(() {
      _detected = null;
      _scanning = true;
    });
    _scanLine.repeat();
    _pulse.repeat(reverse: true);
    _autoDetect?.cancel();
    _autoDetect = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final pool = DummyData.assets.toList()..shuffle(Random());
      setState(() {
        _detected = pool.first;
        _scanning = false;
      });
      _scanLine.stop();
      _pulse.stop();
    });
  }

  void _openDetail(Asset a) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: a)),
    );
  }

  void _findManual() {
    final id = _manualCtrl.text.trim().toUpperCase();
    final match = DummyData.assets.firstWhere(
      (a) => a.id.toUpperCase() == id,
      orElse: () => DummyData.assets.first,
    );
    _openDetail(match);
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: const StepHeader(
                title: 'Scan asset',
                subtitle: 'Point camera at the QR / barcode',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: ContentColumn(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _ScannerView(
                            scanLine: _scanLine,
                            pulse: _pulse,
                            scanning: _scanning,
                            detected: _detected,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _scanning
                            ? 'Hold steady · Tag must be inside the frame'
                            : 'Tag detected · review and continue',
                        style: TextStyle(
                          color: _scanning
                              ? AppColors.textTertiary
                              : AppColors.statusSynced,
                          fontWeight:
                              _scanning ? FontWeight.w500 : FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_detected != null) ...[
                        _DetectedCard(
                          asset: _detected!,
                          onContinue: () => _openDetail(_detected!),
                          onRetry: _restartScan,
                        ),
                        const SizedBox(height: 16),
                      ],
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OR ENTER ASSET ID MANUALLY',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: TextField(
                                  controller: _manualCtrl,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                      hintText: 'e.g. BR-NH48-027'),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Scanner viewfinder
// ---------------------------------------------------------------------------

class _ScannerView extends StatelessWidget {
  const _ScannerView({
    required this.scanLine,
    required this.pulse,
    required this.scanning,
    required this.detected,
  });
  final AnimationController scanLine;
  final AnimationController pulse;
  final bool scanning;
  final Asset? detected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1320),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera-feed mock (radial dark gradient with simulated noise lines)
          CustomPaint(painter: _NoisePainter()),

          // Reticle frame with corner accents
          Center(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final glow = scanning ? 6 + 6 * pulse.value : 12.0;
                return Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: scanning
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: glow,
                              spreadRadius: 1,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.statusSynced.withOpacity(0.55),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: CustomPaint(
                    painter: _ReticlePainter(
                      color: scanning
                          ? Colors.white
                          : AppColors.statusSynced,
                    ),
                  ),
                );
              },
            ),
          ),

          // Sweep line
          if (scanning)
            Center(
              child: AnimatedBuilder(
                animation: scanLine,
                builder: (context, _) {
                  return SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _SweepPainter(progress: scanLine.value),
                    ),
                  );
                },
              ),
            ),

          // Bottom status pill
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      scanning ? Icons.qr_code_scanner : Icons.check_circle,
                      size: 14,
                      color: scanning
                          ? Colors.white
                          : AppColors.statusSynced,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      scanning
                          ? 'Scanning…'
                          : 'Detected · ${detected?.id ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 26.0;
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    // 4 corner brackets
    final corners = [
      [Offset(r.left, r.top + arm), Offset(r.left, r.top), Offset(r.left + arm, r.top)],
      [Offset(r.right - arm, r.top), Offset(r.right, r.top), Offset(r.right, r.top + arm)],
      [Offset(r.right, r.bottom - arm), Offset(r.right, r.bottom), Offset(r.right - arm, r.bottom)],
      [Offset(r.left + arm, r.bottom), Offset(r.left, r.bottom), Offset(r.left, r.bottom - arm)],
    ];
    for (final c in corners) {
      final path = Path()
        ..moveTo(c[0].dx, c[0].dy)
        ..lineTo(c[1].dx, c[1].dy)
        ..lineTo(c[2].dx, c[2].dy);
      canvas.drawPath(path, paint);
    }
    // Faint frame
    final faint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(18)), faint);
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SweepPainter extends CustomPainter {
  _SweepPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = 12 + (size.height - 24) * progress;
    final rect = Rect.fromLTWH(8, y - 1, size.width - 16, 2);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryAccent.withOpacity(0.9),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryAccent.withOpacity(0.0),
          AppColors.primaryAccent.withOpacity(0.18),
          AppColors.primaryAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(8, y - 18, size.width - 16, 36));
    canvas.drawRect(
        Rect.fromLTWH(8, y - 18, size.width - 16, 36), glow);
  }

  @override
  bool shouldRepaint(covariant _SweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background radial dark
    final bg = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1B2638), Color(0xFF050A12)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    // Faint scanlines
    final line = Paint()..color = Colors.white.withOpacity(0.025);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
//  Detected-asset card
// ---------------------------------------------------------------------------

class _DetectedCard extends StatelessWidget {
  const _DetectedCard({
    required this.asset,
    required this.onContinue,
    required this.onRetry,
  });
  final Asset asset;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusSynced.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.statusSyncedBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.statusSynced),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.id,
                      style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  Text(asset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text('${asset.region} · ${asset.city}',
                        style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GhostButton(
                  label: 'Re-scan',
                  icon: Icons.refresh,
                  onPressed: onRetry),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                  label: 'Continue', onPressed: onContinue),
            ),
          ]),
        ],
      ),
    );
  }
}
