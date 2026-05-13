import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import 'inspection_setup_screen.dart';
import 'inspection_routine_screen.dart';
import 'inspection_view_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key, required this.asset});
  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    final isTablet = Responsive.isTablet(context);

    final hero = AspectRatio(
      aspectRatio: isTablet ? 2.5 : 1.6,
      child: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB1A38F), Color(0xFF6F5F4D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 48, color: Colors.white38),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.collections_outlined,
                  color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text('MORE PHOTOS · 6',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5)),
            ]),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text('${asset.lat}, ${asset.lng}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5)),
            ]),
          ),
        ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(asset.name,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: ContentColumn(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16), child: hero),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.kind.label,
                        style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(asset.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('${asset.region} · ${asset.city}',
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 13)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isTablet ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.4,
                children: [
                  _InfoTile(label: '# ASSET ID', value: asset.id),
                  _InfoTile(
                      label: 'YEAR BUILT',
                      value: '${asset.yearBuilt}',
                      icon: Icons.calendar_today_outlined),
                  _InfoTile(
                      label: 'LENGTH',
                      value: '${asset.length.toInt()} m',
                      icon: Icons.straighten),
                  _InfoTile(
                      label: 'MATERIAL',
                      value: asset.material,
                      icon: Icons.layers_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Recent inspections',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                Material(
                  color: AppColors.primaryLight.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _startNewInspection(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text('+ Start new inspection',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              ..._buildInspectionList(context),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Documents',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                const Text('6 FILES',
                    style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 10),
              for (final doc in (asset.documents.isEmpty
                  ? [
                      '${asset.id}_general-arrangement.pdf',
                      '${asset.id}_structural-details.pdf',
                      '${asset.id}_load-rating-report.pdf',
                    ]
                  : asset.documents)) ...[
                _DocumentTile(name: doc),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Continue to inspection setup',
                icon: Icons.arrow_forward,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => InspectionSetupScreen(asset: asset)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInspectionList(BuildContext context) {
    final items = DummyData.inspections
        .where((i) => i.asset.id == asset.id)
        .toList();
    if (items.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text('No inspections yet for this asset.',
              style: TextStyle(color: AppColors.textTertiary)),
        )
      ];
    }
    return items.map((i) {
      final dateStr =
          '${i.started.day.toString().padLeft(2, '0')}/${i.started.month.toString().padLeft(2, '0')}/${i.started.year}';
      final isDraft = i.status == InspectionStatus.draft;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openInspection(context, i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.kind.label[0].toUpperCase() +
                              i.kind.label.substring(1).toLowerCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isDraft) ...[
                    const Text(
                      'TAP TO RESUME',
                      style: TextStyle(
                        color: AppColors.statusDraft,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    i.status.label,
                    style: TextStyle(
                      color: isDraft
                          ? AppColors.statusDraft
                          : AppColors.statusSubmitted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textTertiary),
                ]),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helpers ------------------------------------------------------------------

  void _startNewInspection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => InspectionSetupScreen(asset: asset)),
    );
  }

  void _openInspection(BuildContext context, Inspection ins) {
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
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            color: const Color(0xFFE9F2F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              const Text('Drawing · 5.1 MB · Jun 2006',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 11.5)),
            ],
          ),
        ),
        const Icon(Icons.download_outlined,
            color: AppColors.textTertiary),
      ]),
    );
  }
}
