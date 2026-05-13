import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import 'asset_search_screen.dart';
import 'asset_map_screen.dart';
import 'asset_scan_screen.dart';
import 'new_asset_dialog.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final pad = isTablet ? 32.0 : 16.0;
    // Wrap in Material so the screen works both as a tab (inside ShellScreen's
    // Scaffold) AND when pushed as a standalone route (where there is no
    // ancestor Scaffold to provide a Material for the InkWells below).
    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 20),
            child: const StepHeader(
              title: 'How will you find the asset?',
              subtitle: 'Step 1 of 2 · Choose method',
              showBack: false,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: ContentColumn(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pick the fastest way to locate the structure you’ll inspect.',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 14),
                    _MethodCard(
                      title: 'Map view',
                      subtitle: 'Show nearby assets using your GPS location',
                      icon: Icons.map_outlined,
                      primary: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AssetMapScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MethodCard(
                      title: 'Asset registry',
                      subtitle: 'Browse and filter by category, type or ID',
                      icon: Icons.list_alt_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AssetSearchScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MethodCard(
                      title: 'Scan QR / Barcode',
                      subtitle: 'Point your camera at the asset tag',
                      icon: Icons.qr_code_scanner,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AssetScanScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    /*_MethodCard(
                      title: '+ New asset on the field',
                      subtitle:
                          'Drop a pin at your current location and create a new asset record',
                      icon: Icons.add_location_alt_outlined,
                      onTap: () async {
                        final created = await NewAssetDialog.show(
                            context,
                            lat: 24.79, lng: 46.68);
                        if (created != null && context.mounted) {
                          DummyData.assets.add(created);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Created ${created.id} · ${created.name}')),
                          );
                        }
                      },
                    ),*/
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

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? AppColors.primary : AppColors.surface;
    final fg = primary ? Colors.white : AppColors.textPrimary;
    final sub = primary ? Colors.white70 : AppColors.textTertiary;
    final iconBg =
        primary ? Colors.white12 : const Color(0xFFEEF1F4);
    final iconFg = primary ? Colors.white : AppColors.textSecondary;

    // Material is required for InkWell. Wrapping locally guarantees the
    // ripple works regardless of where this card is mounted in the tree.
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: primary ? Colors.transparent : AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconFg),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: fg)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(color: sub, fontSize: 12.5)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: fg.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
