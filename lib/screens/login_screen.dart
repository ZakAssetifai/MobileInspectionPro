import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_logo.dart';
import '../widgets/primary_button.dart';
import 'shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController(text: 'INS-2024-001');
  final _key = TextEditingController(text: '••••••••••••');
  bool _offlineMode = false;
  bool _showKey = false;

  @override
  void dispose() {
    _id.dispose();
    _key.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    final hero = const _BridgeHero();
    final form = _LoginForm(
      idCtrl: _id,
      keyCtrl: _key,
      showKey: _showKey,
      offlineMode: _offlineMode,
      onToggleShowKey: () => setState(() => _showKey = !_showKey),
      onToggleOffline: (v) => setState(() => _offlineMode = v),
      onSubmit: _submit,
      onBiometric: _submit,
    );

    if (isTablet) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              Expanded(flex: 6, child: hero),
              Expanded(
                flex: 5,
                child: Container(
                  color: AppColors.background,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(36),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: hero,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: form,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  HERO  ·  bridge silhouette + brand pitch
// ===========================================================================

class _BridgeHero extends StatelessWidget {
  const _BridgeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF103A65), Color(0xFF1E5BB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Bridge cables / structure pattern
          CustomPaint(painter: _HeroBackdropPainter()),

          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BrandLogo(size: 30, color: Colors.white),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'BridgeInspect Pro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: 380,
                      child: Text(
                        'High-fidelity structural analysis and\nmission-critical inspection management\nfor civil engineers.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(children: const [
                  _HeroBadge(
                      icon: Icons.shield_outlined,
                      title: 'Secure Access',
                      sub: 'End-to-end encrypted structural data'),
                  SizedBox(width: 12),
                  _HeroBadge(
                      icon: Icons.wifi_off_outlined,
                      title: 'Offline Ready',
                      sub: 'Inspector-grade ready for remote sites'),
                ]),
              ],
            ),
          ),

          // bottom-right floating sync warning
          Positioned(
            right: 24,
            bottom: 24,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.cloud_off_outlined,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Sync Network · Offline\nLocal storage available',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft grid
    final grid = Paint()..color = Colors.white.withOpacity(0.04);
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Suspension bridge silhouette across the bottom third
    final w = size.width;
    final h = size.height;
    final towerPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final cablePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final deckPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final yDeck = h * 0.86;
    final yTowerTop = h * 0.45;

    // Towers
    canvas.drawLine(
        Offset(w * 0.20, yTowerTop), Offset(w * 0.20, yDeck), towerPaint);
    canvas.drawLine(
        Offset(w * 0.80, yTowerTop), Offset(w * 0.80, yDeck), towerPaint);
    // Main cable
    final cable = Path()
      ..moveTo(0, yDeck)
      ..quadraticBezierTo(w * 0.20, yTowerTop + 8, w * 0.20, yTowerTop)
      ..quadraticBezierTo(w * 0.50, yDeck + 6, w * 0.80, yTowerTop)
      ..quadraticBezierTo(w * 0.80, yTowerTop + 8, w, yDeck);
    canvas.drawPath(cable, cablePaint);
    // Suspender lines
    for (var i = 0; i <= 24; i++) {
      final x = w * 0.20 + (w * 0.60) * (i / 24);
      // Approx parabola y between towers
      final t = (x - w * 0.20) / (w * 0.60);
      final yCable = yTowerTop + 4 * (yDeck - yTowerTop) * t * (1 - t);
      canvas.drawLine(Offset(x, yCable), Offset(x, yDeck), cablePaint);
    }
    // Deck
    canvas.drawLine(Offset(0, yDeck), Offset(w, yDeck), deckPaint);

    // Far horizon glow
    final glow = Paint()
      ..shader = RadialGradient(colors: [
        Colors.white.withOpacity(0.10),
        Colors.transparent
      ]).createShader(Rect.fromCircle(
          center: Offset(w * 0.7, h * 0.35), radius: w * 0.4));
    canvas.drawCircle(Offset(w * 0.7, h * 0.35), w * 0.4, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge(
      {required this.icon, required this.title, required this.sub});
  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  FORM  ·  Inspector Login card
// ===========================================================================

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.idCtrl,
    required this.keyCtrl,
    required this.showKey,
    required this.offlineMode,
    required this.onToggleShowKey,
    required this.onToggleOffline,
    required this.onSubmit,
    required this.onBiometric,
  });

  final TextEditingController idCtrl;
  final TextEditingController keyCtrl;
  final bool showKey;
  final bool offlineMode;
  final VoidCallback onToggleShowKey;
  final ValueChanged<bool> onToggleOffline;
  final VoidCallback onSubmit;
  final VoidCallback onBiometric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Inspector Login',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Enter your credentials to access this terminal.',
            style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.9),
                fontSize: 13.5),
          ),
          const SizedBox(height: 22),

          // Inspector ID
          const _FieldLabel(label: 'INSPECTOR ID'),
          const SizedBox(height: 8),
          TextField(
            controller: idCtrl,
            decoration: const InputDecoration(
              hintText: 'E.g. INS-2024-001',
              prefixIcon:
                  Icon(Icons.alternate_email, color: AppColors.gray400, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Access Key
          Row(children: [
            const _FieldLabel(label: 'ACCESS KEY'),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: const Text('Reset Key?',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: keyCtrl,
            obscureText: !showKey,
            decoration: InputDecoration(
              hintText: '••••••••••••',
              prefixIcon: const Icon(Icons.vpn_key_outlined,
                  color: AppColors.gray400, size: 20),
              suffixIcon: IconButton(
                onPressed: onToggleShowKey,
                icon: Icon(
                    showKey ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.gray400, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Offline mode toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Enable Offline Mode',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Auth with cached credentials',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 11.5)),
                  ],
                ),
              ),
              Switch(
                  value: offlineMode,
                  activeColor: AppColors.primary,
                  onChanged: onToggleOffline),
            ]),
          ),
          const SizedBox(height: 18),

          // Authorize Session
          PrimaryButton(
            label: 'Authorize Session',
            icon: Icons.lock_open_outlined,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 18),

          // OR BIOMETRICS divider
          Row(children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR BIOMETRICS',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  fontSize: 10.5,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _BiometricButton(
                  icon: Icons.fingerprint,
                  label: 'Touch ID',
                  onTap: onBiometric),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BiometricButton(
                  icon: Icons.face_outlined,
                  label: 'Face ID',
                  onTap: onBiometric),
            ),
          ]),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'By logging in, you agree to the Security Protocols and\nAgency Terms of Service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _BiometricButton extends StatelessWidget {
  const _BiometricButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
