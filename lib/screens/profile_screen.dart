import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    return Material(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: ContentColumn(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
              const SizedBox(height: 16),
              SectionCard(
                child: Row(children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: const Text('ZK',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zeeshan Khan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18)),
                        SizedBox(height: 2),
                        Text('zeeshan.khan@assetifai.com',
                            style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13)),
                        SizedBox(height: 8),
                        Text(
                          'Senior Bridge Inspector · Eastern Region',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              const _ProfileRow(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Critical findings · assignments · sync alerts'),
              const _ProfileRow(
                  icon: Icons.translate,
                  title: 'Language',
                  subtitle: 'English (US)'),
              const _ProfileRow(
                  icon: Icons.shield_outlined,
                  title: 'Inspection codes',
                  subtitle: 'AASHTO · Saudi Highway Code (SHC)'),
              const _ProfileRow(
                  icon: Icons.cloud_outlined,
                  title: 'Backup & sync',
                  subtitle: 'Auto-sync over Wi-Fi only'),
              const _ProfileRow(
                  icon: Icons.lock_outline,
                  title: 'Security',
                  subtitle: 'Biometric unlock · device lock policy'),
              const _ProfileRow(
                  icon: Icons.help_outline,
                  title: 'Help & support',
                  subtitle: 'Field manual · contact regional admin'),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.severityHigh,
                  side: BorderSide(
                      color: AppColors.severityHigh.withOpacity(0.3)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Assetifai · v1.0.0 (demo build)',
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(
      {required this.icon,
      required this.title,
      required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
