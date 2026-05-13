import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/inspection_card.dart';
import 'assets_screen.dart';
import 'inspection_routine_screen.dart';
import 'inspection_view_screen.dart';

class InspectionsScreen extends StatefulWidget {
  const InspectionsScreen({super.key});

  @override
  State<InspectionsScreen> createState() => _InspectionsScreenState();
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

class _InspectionsScreenState extends State<InspectionsScreen> {
  String _filter = 'ALL';
  String _typeFilter = 'ALL';
  String _query = '';

  static const filters = ['ALL', 'DRAFT', 'SUBMITTED', 'SYNCED'];
  static const typeFilters = ['ALL', 'BRIDGES', 'CULVERTS'];

  Future<void> _confirmDelete(BuildContext context, Inspection ins) async {
    final ok = await showDialog<bool>(
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
    if (ok == true) {
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

  List<Inspection> get _records {
    return DummyData.inspections.where((i) {
      if (_filter == 'DRAFT' && i.status != InspectionStatus.draft) return false;
      if (_filter == 'SUBMITTED' && i.status != InspectionStatus.submitted) return false;
      if (_filter == 'SYNCED' && i.status != InspectionStatus.synced) return false;
      if (_typeFilter == 'BRIDGES' && i.asset.kind != AssetKind.bridge) return false;
      if (_typeFilter == 'CULVERTS' && i.asset.kind != AssetKind.culvert) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!i.asset.name.toLowerCase().contains(q) &&
            !i.asset.id.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    final isTablet = Responsive.isTablet(context);
    final pad = isTablet ? 32.0 : 16.0;

    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inspections',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${records.length} records',
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AssetsScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(110, 44),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Asset ID or name',
                      prefixIcon: Icon(Icons.search,
                          color: AppColors.textTertiary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: f,
                              selected: _filter == f,
                              onTap: () => setState(() => _filter = f),
                            ),
                          ),
                        Container(
                          width: 1,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: AppColors.border,
                        ),
                        for (final f in typeFilters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: f,
                              selected: _typeFilter == f,
                              dark: true,
                              onTap: () => setState(() => _typeFilter = f),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (records.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(children: [
                        Icon(Icons.filter_alt_outlined,
                            color: AppColors.textTertiary),
                        SizedBox(height: 10),
                        Text('No inspections match',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Try adjusting filters or start a new inspection.',
                            style: TextStyle(
                                color: AppColors.textTertiary, fontSize: 13)),
                      ]),
                    )
                  else
                    isTablet
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: records.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 560,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 100,
                            ),
                            itemBuilder: (_, i) => InspectionCard(
                              inspection: records[i],
                              onTap: () =>
                                  _openInspection(context, records[i]),
                              onDelete: records[i].status ==
                                      InspectionStatus.draft
                                  ? () => _confirmDelete(context, records[i])
                                  : null,
                            ),
                          )
                        : Column(
                            children: [
                              for (final r in records) ...[
                                InspectionCard(
                                  inspection: r,
                                  onTap: () => _openInspection(context, r),
                                  onDelete: r.status == InspectionStatus.draft
                                      ? () => _confirmDelete(context, r)
                                      : null,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dark = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (selected) {
      bg = dark ? Colors.black87 : AppColors.primary;
      fg = Colors.white;
    } else {
      bg = AppColors.surface;
      fg = AppColors.textSecondary;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 11.5,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
