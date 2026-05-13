import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

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
              const Text('Sync',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
              const SizedBox(height: 4),
              const Text('Offline-first · cloud reconciliation',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.wifi, color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text('CONNECTION · STABLE',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6)),
                    ]),
                    const SizedBox(height: 10),
                    const Text('All systems normal',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22)),
                    const SizedBox(height: 4),
                    const Text('Last sync · 22 min ago',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primary),
                      label: Text(
                          'Sync ${DummyData.pendingSyncCount} pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SyncRow(
                  icon: Icons.edit_note,
                  iconBg: AppColors.statusDraftBg,
                  iconFg: AppColors.statusDraft,
                  title: 'Local drafts',
                  subtitle: 'On-device only',
                  value: '${DummyData.draftsCount}'),
              const SizedBox(height: 8),
              _SyncRow(
                  icon: Icons.cloud_upload_outlined,
                  iconBg: const Color(0xFFE9F1F0),
                  iconFg: AppColors.primary,
                  title: 'Pending sync',
                  subtitle: 'Submitted · awaiting upload',
                  value: '${DummyData.pendingSyncCount}'),
              const SizedBox(height: 8),
              _SyncRow(
                  icon: Icons.check_circle_outline,
                  iconBg: AppColors.statusSyncedBg,
                  iconFg: AppColors.statusSynced,
                  title: 'Synced',
                  subtitle: 'Stored on central server',
                  value: '${DummyData.syncedCount}'),
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.storage_outlined,
                          color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Storage',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Cached inspections · 12 MB',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5)),
                        Text('Media · 84 MB',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.45,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh,
                      color: AppColors.primary, size: 18),
                  label: const Text('Refresh status',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.value,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Icon(icon, color: iconFg, size: 18),
        ),
        const SizedBox(width: 14),
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
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 22)),
      ]),
    );
  }
}
