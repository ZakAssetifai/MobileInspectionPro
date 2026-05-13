import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const navItems = <NavItem>[
  NavItem(Icons.home_outlined, 'Home'),
  NavItem(Icons.apartment_outlined, 'Assets'),
  NavItem(Icons.assignment_outlined, 'Inspections'),
  NavItem(Icons.sync_outlined, 'Sync'),
  NavItem(Icons.settings_outlined, 'Settings'),
];

/// Persistent left rail for tablet — matches the "Field Inspection" video.
///
/// Layout:
///   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
///   tiny bridge icon
///   FIELD INSPECTION
///   ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
///   ⌂ Home          (selected → teal-tint pill)
///   ⌂ Assets
///   ⌂ Inspections
///   ⌂ Sync
///   ⌂ Settings
///
///   …
///   ? Help & Support
///   ⎋ Sign out                (red text)
///   ─────────────
///   ZK  Zeeshan Khan  ▾       (user pill with avatar + dropdown)
///       z.k@assetifai.com
class AppSideRail extends StatelessWidget {
  const AppSideRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = true,
    this.onHelp,
    this.onSignOut,
    this.onUserMenu,
    this.userInitials = 'ZK',
    this.userName = 'Zeeshan Khan',
    this.userEmail = 'zeeshan.khan@assetifai.com',
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;
  final VoidCallback? onHelp;
  final VoidCallback? onSignOut;
  final VoidCallback? onUserMenu;
  final String userInitials;
  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 232 : 84,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand mark
            Padding(
              padding: EdgeInsets.fromLTRB(extended ? 20 : 12, 20, 20, 18),
              child: extended ? _brandExtended() : _brandCompact(),
            ),
            const SizedBox(height: 8),

            // Navigation items
            for (var i = 0; i < navItems.length; i++)
              _RailButton(
                item: navItems[i],
                selected: currentIndex == i,
                extended: extended,
                onTap: () => onTap(i),
              ),

            const Spacer(),

            // Help + Sign out footer
            if (extended) ...[
              const Divider(height: 1, color: AppColors.divider),
              _FooterRow(
                icon: Icons.help_outline,
                label: 'Help & Support',
                color: AppColors.textSecondary,
                onTap: onHelp,
              ),
              _FooterRow(
                icon: Icons.logout,
                label: 'Sign out',
                color: AppColors.red,
                onTap: onSignOut,
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, color: AppColors.divider),
              _UserPill(
                initials: userInitials,
                name: userName,
                email: userEmail,
                onTap: onUserMenu,
              ),
            ] else ...[
              const Divider(height: 1, color: AppColors.divider),
              IconButton(
                onPressed: onHelp,
                icon: const Icon(Icons.help_outline,
                    color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout, color: AppColors.red),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _brandExtended() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28, height: 28,
          child: CustomPaint(painter: _BridgeMarkPainter()),
        ),
        const SizedBox(height: 10),
        const Text(
          'FIELD INSPECTION',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _brandCompact() {
    return Center(
      child: SizedBox(
        width: 28, height: 28,
        child: CustomPaint(painter: _BridgeMarkPainter()),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });
  final NavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      child: Material(
        color: selected
            ? AppColors.primaryLight.withOpacity(0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              mainAxisAlignment:
                  extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: fg, size: 20),
                if (extended) ...[
                  const SizedBox(width: 14),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5)),
        ]),
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill({
    required this.initials,
    required this.name,
    required this.email,
    required this.onTap,
  });
  final String initials;
  final String name;
  final String email;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: const TextStyle(
                    color: AppColors.primaryDeep,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5)),
                Text(email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 10.5)),
              ],
            ),
          ),
          const Icon(Icons.expand_more,
              color: AppColors.textTertiary, size: 18),
        ]),
      ),
    );
  }
}

/// Bridge silhouette painter (used for the sidebar logo + login hero etc.).
class _BridgeMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDeep
      ..strokeWidth = size.width * 0.10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(w * 0.22, h * 0.20), Offset(w * 0.22, h * 0.78), paint);
    canvas.drawLine(Offset(w * 0.78, h * 0.20), Offset(w * 0.78, h * 0.78), paint);
    final cable = Path()
      ..moveTo(w * 0.22, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.62, w * 0.78, h * 0.30);
    canvas.drawPath(cable, paint);
    final deck = Paint()
      ..color = AppColors.primaryDeep
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.05, h * 0.78), Offset(w * 0.95, h * 0.78), deck);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom nav for compact (phone) layouts. Tablets use [AppSideRail].
class AppBottomNav extends StatelessWidget {
  const AppBottomNav(
      {super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.surface,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < navItems.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          navItems[i].icon,
                          size: 22,
                          color: currentIndex == i
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          navItems[i].label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: currentIndex == i
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
