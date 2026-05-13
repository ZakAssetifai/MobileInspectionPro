import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/inspection_card.dart';
import '../widgets/mmpk_map_view.dart';
import '../widgets/status_chip.dart';
import 'inspection_routine_screen.dart';
import 'inspection_view_screen.dart';
import 'asset_detail_screen.dart';
import 'asset_registry_screen.dart' show AssetRegistryScreen;

/// Tablet-only Inspections screen — matches the design video with MAP/GRID
/// toggle, working filters, and the real MMPK map.
class InspectionsTabletScreen extends StatefulWidget {
  const InspectionsTabletScreen({super.key});

  @override
  State<InspectionsTabletScreen> createState() =>
      _InspectionsTabletScreenState();
}

class _InspectionsTabletScreenState extends State<InspectionsTabletScreen> {
  String _query = '';
  String _assetType = 'All Asset types';
  String _inspectionType = 'All inspection types';
  String _status = 'Any status';
  String _inspector = 'All inspectors';
  bool _mapView = true;

  // Build the actual filter pipeline — every dropdown now narrows the list.
  List<Inspection> get _filteredFlat {
    return DummyData.inspections.where((i) {
      final a = i.asset;
      if (_assetType == 'Bridges' && a.kind != AssetKind.bridge) return false;
      if (_assetType == 'Culverts' && a.kind != AssetKind.culvert) return false;
      if (_inspectionType != 'All inspection types' &&
          i.kind.label.toUpperCase() != _inspectionType.toUpperCase()) {
        return false;
      }
      if (_status == 'DRAFT' && i.status != InspectionStatus.draft) return false;
      if (_status == 'SUBMITTED' && i.status != InspectionStatus.submitted) {
        return false;
      }
      if (_status == 'SYNCED' && i.status != InspectionStatus.synced) return false;
      if (_inspector != 'All inspectors' && i.inspector != _inspector) {
        return false;
      }
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!a.name.toLowerCase().contains(q) &&
            !a.id.toLowerCase().contains(q) &&
            !a.city.toLowerCase().contains(q) &&
            !i.id.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Map<Asset, List<Inspection>> get _grouped {
    final byAsset = <Asset, List<Inspection>>{};
    for (final i in _filteredFlat) {
      byAsset.putIfAbsent(i.asset, () => []).add(i);
    }
    return byAsset;
  }

  @override
  Widget build(BuildContext context) {
    final flat = _filteredFlat;
    final grouped = _grouped;

    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----- Header (with MAP / GRID toggle + + New) -----
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            color: AppColors.surface,
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.assignment_outlined,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Inspections',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  Text(
                    '${flat.length} records · ${grouped.length} assets',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              _ViewToggle(
                mapView: _mapView,
                onChanged: (v) => setState(() => _mapView = v),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AssetRegistryScreen()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14)),
              ),
            ]),
          ),

          // ----- Filter row -----
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Inspection ID, asset, location',
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textTertiary, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                value: _assetType,
                items: const ['All Asset types', 'Bridges', 'Culverts'],
                onChanged: (v) => setState(() => _assetType = v),
              ),
              const SizedBox(width: 8),
              _Pill(
                value: _inspectionType,
                items: const [
                  'All inspection types', 'ROUTINE', 'DETAILED',
                  'DAMAGE', 'EMERGENCY',
                ],
                onChanged: (v) => setState(() => _inspectionType = v),
              ),
              const SizedBox(width: 8),
              _Pill(
                value: _status,
                items: const ['Any status', 'DRAFT', 'SUBMITTED', 'SYNCED'],
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(width: 8),
              _Pill(
                value: _inspector,
                items: const ['All inspectors', 'Zeeshan Khan', 'Ali Hassan'],
                onChanged: (v) => setState(() => _inspector = v),
              ),
            ]),
          ),

          // ----- Body — MAP / GRID variant -----
          Expanded(
            child: _mapView
                ? Row(children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 4, 8, 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: MmpkMapView(
                            assets: grouped.keys.toList(),
                            onAssetTap: (a) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AssetDetailScreen(asset: a)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Row(children: [
                              const Text('INSPECTIONS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                      color: AppColors.textSecondary)),
                              const Spacer(),
                              Text(
                                '${grouped.length} assets',
                                style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12),
                              ),
                            ]),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: grouped.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final asset = grouped.keys.elementAt(i);
                                final list = grouped[asset]!;
                                return _AssetGroup(
                                    asset: asset, inspections: list);
                              },
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ])
                : _GridBody(items: flat),
          ),
        ],
      ),
    );
  }
}

// =================================================================

class _Pill extends StatelessWidget {
  const _Pill({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.mapView, required this.onChanged});
  final bool mapView;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _toggle('MAP VIEW', mapView, () => onChanged(true)),
        _toggle('GRID VIEW', !mapView, () => onChanged(false)),
      ]),
    );
  }

  Widget _toggle(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.6)),
      ),
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({required this.items});
  final List<Inspection> items;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 560,
        mainAxisExtent: 110,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, i) => InspectionCard(
        inspection: items[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => items[i].status == InspectionStatus.draft
                ? InspectionRoutineScreen(inspection: items[i])
                : InspectionViewScreen(inspection: items[i]),
          ),
        ),
      ),
    );
  }
}

class _AssetGroup extends StatefulWidget {
  const _AssetGroup({required this.asset, required this.inspections});
  final Asset asset;
  final List<Inspection> inspections;
  @override
  State<_AssetGroup> createState() => _AssetGroupState();
}

class _AssetGroupState extends State<_AssetGroup> {
  bool _expanded = true;
  @override
  Widget build(BuildContext context) {
    final a = widget.asset;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: a)),
          ),
          child: Row(children: [
            AssetThumbnail(tag: a.kind.tag, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(a.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text('${a.id} · ${a.city}',
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11.5)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusSyncedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${widget.inspections.length} INSP',
                  style: const TextStyle(
                      color: AppColors.statusSynced,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.4)),
            ),
          ]),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          for (final i in widget.inspections) ...[
            _InspectionRow(inspection: i),
            const SizedBox(height: 6),
          ],
        ],
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size.fromHeight(34),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Text(_expanded ? 'COLLAPSE' : 'LIST OF INSPECTIONS',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 11.5)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: a)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(34),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('DETAILS ›',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 11.5)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _InspectionRow extends StatelessWidget {
  const _InspectionRow({required this.inspection});
  final Inspection inspection;
  @override
  Widget build(BuildContext context) {
    final i = inspection;
    final dateStr =
        '${i.started.day.toString().padLeft(2, '0')}/${i.started.month.toString().padLeft(2, '0')}/${i.started.year}, '
        '${i.started.hour.toString().padLeft(2, '0')}:${i.started.minute.toString().padLeft(2, '0')}';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => i.status == InspectionStatus.draft
              ? InspectionRoutineScreen(inspection: i)
              : InspectionViewScreen(inspection: i),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Text('#${i.id.split('-').last}',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 11)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(dateStr,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11.5)),
          ),
          StatusChip(status: i.status),
        ]),
      ),
    );
  }
}
