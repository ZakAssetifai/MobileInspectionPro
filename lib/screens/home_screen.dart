import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/inspection_card.dart';
import '../widgets/stat_card.dart';
import 'assets_screen.dart';
import 'inspection_routine_screen.dart';
import 'inspection_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  void _openInspection(BuildContext context, Inspection ins) {
    // Drafts resume the routine wizard so the inspector can keep going.
    // Submitted / synced inspections open the read-only view.
    if (ins.status == InspectionStatus.draft) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InspectionRoutineScreen(inspection: ins)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InspectionViewScreen(inspection: ins)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final hPad = isTablet ? 32.0 : 16.0;

    return Material(
      color: AppColors.background,
      child: CustomScrollView(
        slivers: [
          // Header + start-new card grouped in a Stack so the card visually
          // overlaps the gradient without using negative offsets that
          // overlap the greeting text.
          SliverToBoxAdapter(
            child: _HeroHeader(
              hPad: hPad,
              greeting: _greeting(),
              onStart: () => _openAssets(context),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            sliver: SliverToBoxAdapter(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.65,
                children: [
                  StatCard(
                    value: '${DummyData.draftsCount}',
                    label: 'DRAFTS',
                    icon: Icons.edit_note,
                    iconBg: AppColors.statusDraftBg,
                    iconFg: AppColors.statusDraft,
                  ),
                  StatCard(
                    value: '${DummyData.assignedCount}',
                    label: 'ASSIGNED',
                    icon: Icons.monitor_heart_outlined,
                    iconBg: const Color(0xFFE6EEF2),
                    iconFg: AppColors.textSecondary,
                  ),
                  StatCard(
                    value: '${DummyData.pendingSyncCount}',
                    label: 'PENDING SYNC',
                    icon: Icons.cloud_upload_outlined,
                    iconBg: const Color(0xFFE9F1F0),
                    iconFg: AppColors.primary,
                  ),
                  StatCard(
                    value: '${DummyData.syncedCount}',
                    label: 'SYNCED',
                    icon: Icons.check_circle_outline,
                    iconBg: AppColors.statusSyncedBg,
                    iconFg: AppColors.statusSynced,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent activity',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            sliver: SliverList.separated(
              itemCount: DummyData.inspections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final ins = DummyData.inspections[i];
                return InspectionCard(
                  inspection: ins,
                  onTap: () => _openInspection(context, ins),
                  onDelete: ins.status == InspectionStatus.draft
                      ? () => _confirmDelete(context, ins)
                      : null,
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warningFg.withOpacity(0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warningFg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${DummyData.criticalCount} critical findings',
                              style: const TextStyle(
                                  color: AppColors.warningFg,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text(
                            'Recent inspections flagged immediate-risk defects requiring senior review.',
                            style: TextStyle(
                                color: AppColors.warningFg, fontSize: 13),
                          ),
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
    );
  }

  void _openAssets(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssetsScreen()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Inspection ins) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete draft inspection?'),
        content: Text(
          'This will permanently delete the draft for ${ins.asset.name}. '
          'This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.severityHigh,
              minimumSize: const Size(96, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      DummyData.inspections.remove(ins);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.severityHigh,
            content: Text('Deleted draft for ${ins.asset.name}'),
          ),
        );
      }
    }
  }
}

/// Gradient header + start-new card combined in a Stack so the card overlaps
/// the gradient cleanly without negative offsets that collide with the name.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.hPad,
    required this.greeting,
    required this.onStart,
  });

  final double hPad;
  final String greeting;
  final VoidCallback onStart;

  static const double _cardHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient header — extends below the card by ~half the card height
        // so the card sits visually nested inside the colored band.
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              hPad, 24, hPad, _cardHeight / 2 + 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDeep, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('Zeeshan Khan',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1.1)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: const [
                      Icon(Icons.circle,
                          color: Color(0xFF4ADE80), size: 8),
                      SizedBox(width: 6),
                      Text('Online',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),

        // Start-new card sits at the bottom of the gradient, half-overlapping
        // the colored band — implemented via Positioned with no need for
        // negative-offset Transform (which is what was clipping into the name).
        Positioned(
          left: hPad,
          right: hPad,
          bottom: -_cardHeight / 2,
          child: _StartNewCard(onTap: onStart, height: _cardHeight),
        ),

        // Empty spacer so the Stack reserves room for the half-overlap.
        SizedBox(height: _cardHeight / 2),
      ],
    );
  }
}

class _StartNewCard extends StatelessWidget {
  const _StartNewCard({required this.onTap, required this.height});
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start new inspection',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Select asset · scan QR · resume draft',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
