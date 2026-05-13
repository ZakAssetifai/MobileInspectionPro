import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';
import 'inspection_routine_screen.dart';
import 'inspection_view_screen.dart';
import 'asset_detail_screen.dart';
import 'asset_registry_screen.dart' show AssetRegistryScreen;

/// Tablet-only Inspections screen — matches the design video:
/// map left, scrollable inspections-grouped-by-asset right.
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

  // Returns inspections grouped by asset (only assets that have ≥1 record).
  Map<Asset, List<Inspection>> get _grouped {
    final byAsset = <Asset, List<Inspection>>{};
    for (final i in DummyData.inspections) {
      final a = i.asset;
      if (_assetType == 'Bridges' && a.kind != AssetKind.bridge) continue;
      if (_assetType == 'Culverts' && a.kind != AssetKind.culvert) continue;
      if (_inspectionType != 'All inspection types' &&
          i.kind.label.toLowerCase() != _inspectionType.toLowerCase()) {
        continue;
      }
      if (_status == 'DRAFT' && i.status != InspectionStatus.draft) continue;
      if (_status == 'SUBMITTED' && i.status != InspectionStatus.submitted) {
        continue;
      }
      if (_status == 'SYNCED' && i.status != InspectionStatus.synced) continue;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!a.name.toLowerCase().contains(q) &&
            !a.id.toLowerCase().contains(q) &&
            !a.city.toLowerCase().contains(q)) {
          continue;
        }
      }
      byAsset.putIfAbsent(a, () => []).add(i);
    }
    return byAsset;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final totalRecs = grouped.values.fold<int>(0, (s, v) => s + v.length);

    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
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
                    '$totalRecs records · ${grouped.length} assets',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list_alt, size: 16),
                label: const Text('List',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(0, 44)),
              ),
              const SizedBox(width: 8),
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

          // Filter row
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

          // Body: map + grouped list
          Expanded(
            child: Row(children: [
              Expanded(flex: 2, child: _MapPlaceholder(grouped: grouped)),
              Expanded(
                flex: 1,
                child: Container(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
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
                              color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: grouped.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final asset = grouped.keys.elementAt(i);
                          final list = grouped[asset]!;
                          return _AssetGroup(asset: asset, inspections: list);
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.grouped});
  final Map<Asset, List<Inspection>> grouped;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 8, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD3E2EA), Color(0xFFEAF1F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(painter: _LandPainter()),
            ),
          ),
          // Asset pins
          for (final entry in grouped.entries) _pinFor(entry.key, entry.value),

          // Map mode pill (decorative)
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                _MiniPill(label: 'MAP', selected: true),
                _MiniPill(label: 'SAT'),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pinFor(Asset a, List<Inspection> records) {
    final allAssets = grouped.keys.toList();
    if (allAssets.isEmpty) return const SizedBox.shrink();
    final minLat = allAssets.map((x) => x.lat).reduce((a, b) => a < b ? a : b);
    final maxLat = allAssets.map((x) => x.lat).reduce((a, b) => a > b ? a : b);
    final minLng = allAssets.map((x) => x.lng).reduce((a, b) => a < b ? a : b);
    final maxLng = allAssets.map((x) => x.lng).reduce((a, b) => a > b ? a : b);
    final latRange = (maxLat - minLat).abs() < 1 ? 1.0 : (maxLat - minLat);
    final lngRange = (maxLng - minLng).abs() < 1 ? 1.0 : (maxLng - minLng);
    final x = (a.lng - minLng) / lngRange;
    final y = 1 - (a.lat - minLat) / latRange;
    return Align(
      alignment: Alignment(x * 2 - 1, y * 2 - 1),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(a.id,
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700)),
        ),
        Icon(
          Icons.location_on,
          size: 22,
          color: a.kind == AssetKind.bridge
              ? AppColors.primary
              : AppColors.statusDraft,
        ),
        if (records.length > 1)
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.severityHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.4),
              ),
              child: Text('${records.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, this.selected = false});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.6)),
    );
  }
}

class _LandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()..color = const Color(0xFFE9E1D6);
    final coast = Path()
      ..moveTo(size.width * 0.10, size.height * 0.20)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.10,
          size.width * 0.55, size.height * 0.20)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.30,
          size.width * 0.90, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.85,
          size.width * 0.55, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.95,
          size.width * 0.05, size.height * 0.65)
      ..close();
    canvas.drawPath(coast, landPaint);
    final grid = Paint()..color = Colors.white.withOpacity(0.4);
    for (var i = 1; i < 10; i++) {
      final dx = size.width * i / 10;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), grid);
      final dy = size.height * i / 10;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
    }
  }
  @override bool shouldRepaint(covariant _LandPainter old) => false;
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
