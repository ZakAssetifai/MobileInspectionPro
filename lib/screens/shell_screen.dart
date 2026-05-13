import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/side_nav.dart';
import 'home_screen.dart';
import 'inspections_screen.dart';
import 'inspections_tablet_screen.dart';
import 'assets_screen.dart';
import 'asset_registry_screen.dart';
import 'sync_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _index = widget.initialIndex;

  // Mobile uses the existing screens; tablets get the wider master-detail
  // variants (Asset Registry + Inspections-with-map replace the
  // narrower mobile equivalents).
  List<Widget> _pages(bool isTablet) => <Widget>[
        const HomeScreen(),
        isTablet ? const AssetRegistryScreen() : const AssetsScreen(),
        isTablet ? const InspectionsTabletScreen() : const InspectionsScreen(),
        const SyncScreen(),
        const ProfileScreen(),
      ];

  void _signOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final pages = _pages(isTablet);

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              AppSideRail(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                extended: Responsive.isLarge(context),
                onHelp: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support — coming soon')),
                ),
                onSignOut: _signOut,
                onUserMenu: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User menu — coming soon')),
                ),
              ),
              Expanded(child: pages[_index]),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
