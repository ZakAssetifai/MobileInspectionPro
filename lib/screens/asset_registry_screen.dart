import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';
import 'asset_detail_screen.dart';
import 'asset_scan_screen.dart';
import 'new_asset_dialog.dart';

/// Asset Registry (tablet) — matches the design video:
///
///   [ filter bar with search + 4 dropdowns + SCAN QR / BARCODE button ]
///   ┌─────────────────────────────────┬───────────────────┐
///   │                                  │ ASSETS · 22 results │
///   │       big satellite map          │ year/length/material│
///   │       with pins + polygon        │ ┌───── asset card ──┐│
///   │       MAP/SAT toggle             │ │ name              │ │
///   │       POLYGON / CLEAR            │ │ id · location     │ │
///   │                                  │ │ built · length    │ │
///   │                                  │ │ [VIEW DETAILS]    │ │
///   │                                  │ └────────────────────┘│
///   └─────────────────────────────────┴───────────────────┘
class AssetRegistryScreen extends StatefulWidget {
  const AssetRegistryScreen({super.key});

  @override
  State<AssetRegistryScreen> createState() => _AssetRegistryScreenState();
}

class _AssetRegistryScreenState extends State<AssetRegistryScreen> {
  String _query = '';
  String _typeFilter = 'All Asset types';
  String _locFilter = 'All locations';
  String _statusFilter = 'All statuses';
  String _conditionFilter = 'All conditions';
  String _yearFilter = 'Any year';
  String _lengthFilter = 'Any length';
  String _materialFilter = 'Any material';
  bool _mapView = true; // map vs grid view toggle at top
  bool _sat = false;
  bool _polygonActive = false;

  List<Asset> get _filtered {
    return DummyData.assets.where((a) {
      if (_typeFilter == 'Bridges' && a.kind != AssetKind.bridge) return false;
      if (_typeFilter == 'Culverts' && a.kind != AssetKind.culvert) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Material(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----- Header bar -----
          _Header(
            total: DummyData.assets.length,
            shown: list.length,
            mapView: _mapView,
            onToggleView: (v) => setState(() => _mapView = v),
          ),
          // ----- Filter row -----
          _FilterRow(
            query: _query,
            onQuery: (v) => setState(() => _query = v),
            typeFilter: _typeFilter,
            onTypeFilter: (v) => setState(() => _typeFilter = v),
            locFilter: _locFilter,
            onLocFilter: (v) => setState(() => _locFilter = v),
            statusFilter: _statusFilter,
            onStatusFilter: (v) => setState(() => _statusFilter = v),
            conditionFilter: _conditionFilter,
            onConditionFilter: (v) => setState(() => _conditionFilter = v),
            onScan: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AssetScanScreen()),
            ),
          ),

          // ----- Body -----
          Expanded(
            child: _mapView
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _MapPanel(
                          assets: list,
                          sat: _sat,
                          polygon: _polygonActive,
                          onSat: (v) => setState(() => _sat = v),
                          onPolygon: () =>
                              setState(() => _polygonActive = !_polygonActive),
                          onAssetTap: (a) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AssetDetailScreen(asset: a)),
                          ),
                          onNewAsset: () async {
                            final created = await NewAssetDialog.show(
                                context,
                                lat: 24.79, lng: 46.68);
                            if (created != null && mounted) {
                              setState(() {
                                DummyData.assets.add(created);
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _AssetListPanel(
                          assets: list,
                          yearFilter: _yearFilter,
                          lengthFilter: _lengthFilter,
                          materialFilter: _materialFilter,
                          onYearFilter: (v) => setState(() => _yearFilter = v),
                          onLengthFilter: (v) =>
                              setState(() => _lengthFilter = v),
                          onMaterialFilter: (v) =>
                              setState(() => _materialFilter = v),
                          inPolygon: _polygonActive,
                          onNewAsset: () async {
                            final created = await NewAssetDialog.show(
                                context,
                                lat: 24.79, lng: 46.68);
                            if (created != null && mounted) {
                              setState(() {
                                DummyData.assets.add(created);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : _GridView(
                    assets: list,
                    onTap: (a) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AssetDetailScreen(asset: a)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
//  Header / filters
// =================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.shown,
    required this.mapView,
    required this.onToggleView,
  });
  final int total, shown;
  final bool mapView;
  final ValueChanged<bool> onToggleView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      color: AppColors.surface,
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.apartment_outlined,
              color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Asset Registry',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18)),
            Text('$shown of $total assets',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 12)),
          ],
        ),
        const Spacer(),
        _ViewToggle(mapView: mapView, onChanged: onToggleView),
      ]),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.query,
    required this.onQuery,
    required this.typeFilter,
    required this.onTypeFilter,
    required this.locFilter,
    required this.onLocFilter,
    required this.statusFilter,
    required this.onStatusFilter,
    required this.conditionFilter,
    required this.onConditionFilter,
    required this.onScan,
  });

  final String query;
  final ValueChanged<String> onQuery;
  final String typeFilter, locFilter, statusFilter, conditionFilter;
  final ValueChanged<String> onTypeFilter, onLocFilter, onStatusFilter,
      onConditionFilter;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(children: [
        Expanded(
          child: TextField(
            onChanged: onQuery,
            decoration: const InputDecoration(
              hintText: 'Asset ID, name or location',
              prefixIcon: Icon(Icons.search,
                  color: AppColors.textTertiary, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _FilterPill(
          value: typeFilter,
          items: const ['All Asset types', 'Bridges', 'Culverts'],
          onChanged: onTypeFilter,
        ),
        const SizedBox(width: 8),
        _FilterPill(
          value: locFilter,
          items: const ['All locations', 'Riyadh', 'Eastern', 'Hail', 'Jazan'],
          onChanged: onLocFilter,
        ),
        const SizedBox(width: 8),
        _FilterPill(
          value: statusFilter,
          items: const ['All statuses', 'Active', 'Decommissioned'],
          onChanged: onStatusFilter,
        ),
        const SizedBox(width: 8),
        _FilterPill(
          value: conditionFilter,
          items: const ['All conditions', 'Excellent', 'Good', 'Fair', 'Poor'],
          onChanged: onConditionFilter,
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
          label: const Text('SCAN QR / BARCODE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.6),
          ),
        ),
      ]),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
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

// =================================================================
//  Map panel
// =================================================================

class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.assets,
    required this.sat,
    required this.polygon,
    required this.onSat,
    required this.onPolygon,
    required this.onAssetTap,
    required this.onNewAsset,
  });
  final List<Asset> assets;
  final bool sat;
  final bool polygon;
  final ValueChanged<bool> onSat;
  final VoidCallback onPolygon;
  final ValueChanged<Asset> onAssetTap;
  final VoidCallback onNewAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 8, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Mock map background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: sat
                        ? const [Color(0xFF1B3A5C), Color(0xFF2D5F8D)]
                        : const [Color(0xFFD3E2EA), Color(0xFFEAF1F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CustomPaint(painter: _MapPainter(sat: sat)),
              ),
            ),

            // Top-right toggles
            Positioned(
              top: 12, right: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _MapPill(items: [
                  _MapPillItem(label: 'MAP', selected: !sat, onTap: () => onSat(false)),
                  _MapPillItem(label: 'SAT', selected: sat, onTap: () => onSat(true)),
                ]),
                const SizedBox(height: 8),
                _MapPill(items: [
                  _MapPillItem(
                      label: 'POLYGON',
                      icon: Icons.crop_square,
                      selected: polygon,
                      onTap: onPolygon),
                ]),
                if (polygon) ...[
                  const SizedBox(height: 4),
                  _MapPill(items: [
                    _MapPillItem(
                        label: 'CLEAR',
                        icon: Icons.close,
                        onTap: onPolygon),
                  ]),
                ],
              ]),
            ),

            // "+ NEW ASSET" floating button (top-right per the video)
            Positioned(
              top: 12, right: 100,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(22),
                color: AppColors.primary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onNewAsset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.add_location_alt_outlined,
                          size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('+ NEW ASSET',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11.5,
                              letterSpacing: 0.6)),
                    ]),
                  ),
                ),
              ),
            ),

            // Polygon overlay (decorative)
            if (polygon)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PolygonPainter()),
                ),
              ),

            // Pins
            ..._buildPins(context, assets, sat),

            // Attribution
            const Positioned(
              right: 8, bottom: 4,
              child: Text('Leaflet · OpenStreetMap',
                  style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPins(BuildContext context, List<Asset> assets, bool sat) {
    if (assets.isEmpty) return const [];
    final minLat = assets.map((a) => a.lat).reduce((a, b) => a < b ? a : b);
    final maxLat = assets.map((a) => a.lat).reduce((a, b) => a > b ? a : b);
    final minLng = assets.map((a) => a.lng).reduce((a, b) => a < b ? a : b);
    final maxLng = assets.map((a) => a.lng).reduce((a, b) => a > b ? a : b);
    final latRange = (maxLat - minLat).abs() < 1 ? 1.0 : (maxLat - minLat);
    final lngRange = (maxLng - minLng).abs() < 1 ? 1.0 : (maxLng - minLng);
    return assets.map((a) {
      final x = (a.lng - minLng) / lngRange;
      final y = 1 - (a.lat - minLat) / latRange;
      return Align(
        alignment: Alignment(x * 2 - 1, y * 2 - 1),
        child: GestureDetector(
          onTap: () => onAssetTap(a),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(a.id,
                  style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 2),
            Icon(
              Icons.location_on,
              size: 22,
              color: a.kind == AssetKind.bridge
                  ? AppColors.primary
                  : AppColors.statusDraft,
            ),
          ]),
        ),
      );
    }).toList();
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.sat});
  final bool sat;
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = sat ? const Color(0xFF3E5C42) : const Color(0xFFE9E1D6);
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
    final grid = Paint()..color = (sat ? Colors.white : Colors.white).withOpacity(0.4);
    for (var i = 1; i < 10; i++) {
      final dx = size.width * i / 10;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), grid);
      final dy = size.height * i / 10;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
    }
  }
  @override bool shouldRepaint(covariant _MapPainter old) => old.sat != sat;
}

class _PolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width * 0.30, size.height * 0.30)
      ..lineTo(size.width * 0.70, size.height * 0.35)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..lineTo(size.width * 0.55, size.height * 0.70)
      ..lineTo(size.width * 0.30, size.height * 0.60)
      ..close();
    canvas.drawPath(p,
        Paint()..color = AppColors.primary.withOpacity(0.10));
    canvas.drawPath(p,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke);
  }
  @override bool shouldRepaint(covariant _PolygonPainter old) => false;
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.items});
  final List<Widget> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}

class _MapPillItem extends StatelessWidget {
  const _MapPillItem({
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, color: fg, size: 13), const SizedBox(width: 4)],
          Text(label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.6)),
        ]),
      ),
    );
  }
}

// =================================================================
//  Right-side asset list
// =================================================================

class _AssetListPanel extends StatelessWidget {
  const _AssetListPanel({
    required this.assets,
    required this.yearFilter,
    required this.lengthFilter,
    required this.materialFilter,
    required this.onYearFilter,
    required this.onLengthFilter,
    required this.onMaterialFilter,
    required this.inPolygon,
    required this.onNewAsset,
  });
  final List<Asset> assets;
  final String yearFilter, lengthFilter, materialFilter;
  final ValueChanged<String> onYearFilter, onLengthFilter, onMaterialFilter;
  final bool inPolygon;
  final VoidCallback onNewAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight.withOpacity(0.4),
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(children: [
              const Text('ASSETS',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Text(
                inPolygon
                    ? '${assets.length} results in polygon'
                    : '${assets.length} results',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 12),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onNewAsset,
                icon: const Icon(Icons.add, size: 14),
                label: const Text('+ New asset',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        letterSpacing: 0.4)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ]),
          ),
          Row(children: [
            Expanded(
              child: _SmallFilter(
                value: yearFilter,
                items: const ['Any year', '2020+', '2010-2019', '<2010'],
                onChanged: onYearFilter,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _SmallFilter(
                value: lengthFilter,
                items: const ['Any length', '<50 m', '50-200 m', '>200 m'],
                onChanged: onLengthFilter,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _SmallFilter(
                value: materialFilter,
                items: const ['Any material', 'RC', 'Steel', 'Composite'],
                onChanged: onMaterialFilter,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: assets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _RegistryCard(asset: assets[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallFilter extends StatelessWidget {
  const _SmallFilter({
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary, size: 18),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _RegistryCard extends StatelessWidget {
  const _RegistryCard({required this.asset});
  final Asset asset;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          AssetThumbnail(tag: asset.kind.tag, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(asset.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text(asset.id,
                    style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4)),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text(asset.city,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11)),
                ]),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _attr('${asset.yearBuilt}', 'BUILT'),
          const SizedBox(width: 8),
          _attr('${asset.length.toInt()}m', 'LENGTH'),
          const SizedBox(width: 8),
          Expanded(
            child: _attr(asset.material, 'MATERIAL', truncate: true),
          ),
        ]),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
          ),
          icon: const SizedBox.shrink(),
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('VIEW DETAILS',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      fontSize: 11.5)),
              SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 16),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  Widget _attr(String value, String label, {bool truncate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            maxLines: 1,
            overflow: truncate ? TextOverflow.ellipsis : TextOverflow.clip,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12.5)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6)),
      ],
    );
  }
}

// =================================================================
//  Grid view (when MAP VIEW toggle is off)
// =================================================================

class _GridView extends StatelessWidget {
  const _GridView({required this.assets, required this.onTap});
  final List<Asset> assets;
  final ValueChanged<Asset> onTap;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => InkWell(
        onTap: () => onTap(assets[i]),
        borderRadius: BorderRadius.circular(12),
        child: _RegistryCard(asset: assets[i]),
      ),
    );
  }
}
