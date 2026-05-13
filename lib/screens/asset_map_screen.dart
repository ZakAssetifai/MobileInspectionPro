import 'dart:async';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

import '../config/arcgis_config.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../services/mmpk_service.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';
import 'asset_detail_screen.dart';

/// "Map view" — Step 1 of 2 · Select asset.
///
/// Loads the bundled MMPK (default `assets/mmpk/riyadh2.mmpk`) into an
/// [ArcGISMapView], promotes a local raster basemap if one exists in the
/// package, plots every point from the configured feature layer, and
/// supports filtering by inspection status / kind / date range. Tapping a
/// pin reveals a Use-this-asset bottom card.
class AssetMapScreen extends StatefulWidget {
  const AssetMapScreen({
    super.key,
    this.mmpkAssetPath = ArcgisConfig.mmpkAssetPath,
    this.layerName = ArcgisConfig.assetLayerName,
  });

  final String mmpkAssetPath;
  final String layerName;

  @override
  State<AssetMapScreen> createState() => _AssetMapScreenState();
}

enum _StatusFilter { all, done, pending }

class _AssetMapScreenState extends State<AssetMapScreen> {
  final ArcGISMapViewController _mapController =
      ArcGISMapView.createController();

  final GraphicsOverlay _pointsOverlay = GraphicsOverlay();

  late final MmpkService _mmpkService;

  bool _loading = true;
  String? _setupError;

  // All features as plain dart records — used by the filter and the
  // selection bottom card. Keeps a back-pointer to the underlying graphic so
  // we can update its symbol when the filter changes.
  final List<_AssetPoint> _points = [];
  _AssetPoint? _selected;

  bool _showFilter = false;
  bool _useSatBasemap = false;

  // Filter state ----------
  _StatusFilter _status = _StatusFilter.all;
  bool _includeBridges = true;
  bool _includeCulverts = true;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _mmpkService = MmpkService(assetPath: widget.mmpkAssetPath);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupMap());
  }

  // -------------------- MAP SETUP --------------------

  Future<void> _setupMap() async {
    // 1) Always seed the dummy / Riyadh demo points first so the screen
    //    never appears empty — even before the MMPK has loaded.
    _seedDemoPoints();

    // 2) Stand up an ArcGIS basemap immediately (online imagery) and add the
    //    points overlay. This gives us a map + pins right away.
    try {
      final fallbackMap = ArcGISMap.withBasemap(
        Basemap.withStyle(BasemapStyle.arcGISImagery),
      );
      _mapController.arcGISMap = fallbackMap;
      _mapController.graphicsOverlays.add(_pointsOverlay);

      final centre = ArcGISPoint(
        x: ArcgisConfig.riyadhLng,
        y: ArcgisConfig.riyadhLat,
        spatialReference: SpatialReference.wgs84,
      );
       _mapController.setViewpoint(
        Viewpoint.fromCenter(centre, scale: ArcgisConfig.initialScale),
      );
      _refreshGraphics();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('Default basemap failed: $e');
    }

    // 3) Bail out of MMPK loading if no API key has been configured —
    //    the demo points + online basemap are still showing.
   /* if (!ArcgisConfig.hasValidApiKey) {
      setState(() => _setupError =
          'ArcGIS API key is missing. Showing demo points only — set the key in lib/config/arcgis_config.dart to load the Riyadh 2 MMPK.');
      return;
    }*/

    // 4) Try to upgrade to the real MMPK basemap + features in the
    //    background. If it fails we keep the demo points / fallback basemap.
    try {
      final pkg = await _mmpkService.loadPackage();
      final result =
          await MmpkSetup.prepare(pkg, layerName: widget.layerName);
      _mapController.arcGISMap = result.map;
      // The graphics overlay is reattached after swapping the map.
      if (!_mapController.graphicsOverlays.contains(_pointsOverlay)) {
        _mapController.graphicsOverlays.add(_pointsOverlay);
      }
      final centre = ArcGISPoint(
        x: ArcgisConfig.riyadhLng,
        y: ArcgisConfig.riyadhLat,
        spatialReference: SpatialReference.wgs84,
      );
       _mapController.setViewpoint(
        Viewpoint.fromCenter(centre, scale: ArcgisConfig.initialScale),
      );

      // If the MMPK has its own feature layer, overlay those points on top
      // of the demo seed (real features take precedence by id).
      await _loadFeaturesAsPoints(result);
      _refreshGraphics();
      if (mounted) setState(() => _setupError = null);
    } catch (e, st) {
      debugPrint('MMPK load failed: $e\n$st');
      if (mounted) {
        setState(() => _setupError =
            'MMPK could not be loaded — showing demo points instead.\n$e');
      }
    }
  }

  /// Populates `_points` with a deterministic Riyadh-area demo set so the
  /// map is never empty. Real MMPK features (when loaded) merge in by ID.
  void _seedDemoPoints() {
    _points.clear();

    // Real Asset rows (mostly outside Riyadh — kept for completeness).
    for (final a in DummyData.assets) {
      final pt = ArcGISPoint(
        x: a.lng,
        y: a.lat,
        spatialReference: SpatialReference.wgs84,
      );
      final hits = DummyData.inspections.where((i) => i.asset.id == a.id);
      final inspected = hits.any((i) =>
          i.status == InspectionStatus.submitted ||
          i.status == InspectionStatus.synced);
      DateTime? last;
      if (hits.isNotEmpty) {
        last = hits
            .map((i) => i.submitted ?? i.started)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }
      _points.add(_AssetPoint(
        id: a.id,
        name: a.name,
        kind: a.kind,
        point: pt,
        inspected: inspected,
        asset: a,
        lastInspected: last,
      ));
    }

    // Demo Riyadh 2 inventory — a small grid plus a handful of "landmark"
    // points sprinkled across the area so the map feels populated even
    // before the MMPK is loaded.
    const named = <_DemoEntry>[
      _DemoEntry('BR-RYD-201', 'King Salman Overpass', AssetKind.bridge,
          24.7965, 46.6841),
      _DemoEntry('BR-RYD-202', 'Northern Ring Bridge', AssetKind.bridge,
          24.8005, 46.6790),
      _DemoEntry('BR-RYD-203', 'Al Yasmin Causeway', AssetKind.bridge,
          24.7888, 46.6920),
      _DemoEntry('CV-RYD-204', 'Wadi Hanifa Culvert', AssetKind.culvert,
          24.7842, 46.6772),
      _DemoEntry('CV-RYD-205', 'Al Aqiq Box Culvert', AssetKind.culvert,
          24.7951, 46.6905),
      _DemoEntry('BR-RYD-206', 'Al Malqa Pedestrian', AssetKind.bridge,
          24.7878, 46.6700),
      _DemoEntry('CV-RYD-207', 'Al Wadi Drainage', AssetKind.culvert,
          24.8018, 46.6890),
      _DemoEntry('BR-RYD-208', 'Riyadh Front Span', AssetKind.bridge,
          24.7793, 46.6830),
    ];
    var counter = 1;
    for (final e in named) {
      final pt = ArcGISPoint(
        x: e.lng,
        y: e.lat,
        spatialReference: SpatialReference.wgs84,
      );
      final inspected = counter % 3 != 0;
      final last =
          inspected ? DateTime(2026, 4, 1 + (counter % 28)) : null;
      _points.add(_AssetPoint(
        id: e.id,
        name: e.name,
        kind: e.kind,
        point: pt,
        inspected: inspected,
        lastInspected: last,
        asset: Asset(
          id: e.id,
          name: e.name,
          kind: e.kind,
          region: 'Riyadh',
          city: 'Riyadh 2',
          yearBuilt: 2008 + counter,
          length: e.kind == AssetKind.bridge ? 180.0 : 24.0,
          material: 'Reinforced concrete',
          lat: e.lat,
          lng: e.lng,
        ),
      ));
      counter++;
    }

    // Filler grid for density — 4×3 = 12 additional pins around the
    // Riyadh 2 centroid.
    const rows = 3;
    const cols = 4;
    const stepLat = 0.0080;
    const stepLng = 0.0095;
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        final lat = ArcgisConfig.riyadhLat + (i - rows / 2) * stepLat;
        final lng = ArcgisConfig.riyadhLng + (j - cols / 2) * stepLng;
        final isBridge = (i + j) % 2 == 0;
        final id =
            '${isBridge ? 'BR' : 'CV'}-RYD-${(300 + counter).toString().padLeft(3, '0')}';
        final name = isBridge
            ? 'Riyadh 2 Bridge ${counter.toString().padLeft(2, '0')}'
            : 'Riyadh 2 Culvert ${counter.toString().padLeft(2, '0')}';
        final pt = ArcGISPoint(
          x: lng,
          y: lat,
          spatialReference: SpatialReference.wgs84,
        );
        final inspected = (counter % 3) != 0;
        final last =
            inspected ? DateTime(2026, 4, 1 + (counter % 28)) : null;
        _points.add(_AssetPoint(
          id: id,
          name: name,
          kind: isBridge ? AssetKind.bridge : AssetKind.culvert,
          point: pt,
          inspected: inspected,
          lastInspected: last,
          asset: Asset(
            id: id,
            name: name,
            kind: isBridge ? AssetKind.bridge : AssetKind.culvert,
            region: 'Riyadh',
            city: 'Riyadh 2',
            yearBuilt: 2010 + (counter % 14),
            length: isBridge ? 120.0 + counter * 4 : 18.0 + counter,
            material: 'Reinforced concrete',
            lat: lat,
            lng: lng,
          ),
        ));
        counter++;
      }
    }
  }

  Future<void> _loadFeaturesAsPoints(MmpkSetupResult result) async {
    final table = result.featureTable;
    if (table == null) return;

    final realPoints = <_AssetPoint>[];
    try {
      final params = QueryParameters()..whereClause = '1=1';
      final qres = await table.queryFeatures(params);
      for (final f in qres.features()) {
        final geom = f.geometry;
        if (geom is! ArcGISPoint) continue;
        final attrs = f.attributes;
        // Try common attribute names — adjust if your MMPK uses different keys.
        final id = (attrs['AssetID'] ?? attrs['ID'] ?? attrs['CODE'] ?? '')
            .toString();
        final name = (attrs['Name'] ?? attrs['NAME'] ?? id).toString();
        final kindStr = (attrs['Kind'] ?? attrs['Type'] ?? '')
            .toString()
            .toLowerCase();
        final kind =
            kindStr.contains('cul') ? AssetKind.culvert : AssetKind.bridge;
        final inspected =
            attrs['Inspected'] == true || (attrs['Status']?.toString() == 'Done');

        // Try to look up an Asset row that matches the ID for the bottom-card
        // hand-off; if there's no match, synthesise one.
        final asset = DummyData.assets.firstWhere(
          (a) => a.id == id,
          orElse: () => Asset(
            id: id,
            name: name,
            kind: kind,
            region: 'Riyadh',
            city: 'Riyadh',
            yearBuilt: 0,
            length: 0,
            material: '',
            lat: geom.y,
            lng: geom.x,
          ),
        );

        realPoints.add(_AssetPoint(
          id: id,
          name: name,
          kind: kind,
          point: geom,
          inspected: inspected,
          asset: asset,
        ));
      }
    } catch (e) {
      debugPrint('Feature query failed — keeping demo points ($e)');
    }

    // Merge: real points replace any demo seed with the same id, then add
    // any extras that the demo set didn't already cover.
    if (realPoints.isNotEmpty) {
      final byId = {for (final p in _points) p.id: p};
      for (final rp in realPoints) {
        byId[rp.id] = rp; // replace or insert
      }
      _points
        ..clear()
        ..addAll(byId.values);
    }
  }

  // -------------------- FILTER + GRAPHICS --------------------

  bool _passesFilter(_AssetPoint p) {
    if (!_includeBridges && p.kind == AssetKind.bridge) return false;
    if (!_includeCulverts && p.kind == AssetKind.culvert) return false;
    if (_status == _StatusFilter.done && !p.inspected) return false;
    if (_status == _StatusFilter.pending && p.inspected) return false;
    if (_from != null) {
      if (p.lastInspected == null || p.lastInspected!.isBefore(_from!)) {
        return false;
      }
    }
    if (_to != null) {
      if (p.lastInspected == null || p.lastInspected!.isAfter(_to!)) {
        return false;
      }
    }
    return true;
  }

  void _refreshGraphics() {
    _pointsOverlay.graphics.clear();
    for (final p in _points) {
      if (!_passesFilter(p)) continue;
      final colour = p.kind == AssetKind.bridge
          ? const Color(0xFF1E5BB8)
          : const Color(0xFFF59E0B);
      final isSelected = _selected?.id == p.id;

      // Pin (colored circle with white outline). Larger when selected.
      final pin = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: colour,
        size: isSelected ? 22 : 16,
      )..outline = SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: const Color(0xFFFFFFFF),
          width: 3,
        );

      // Asset-ID label above the pin — white halo so it stays legible on
      // any basemap (matches the look in the original Assetifai video).
      final label = TextSymbol(
        text: p.id,
        color: const Color(0xFF0A2540),
        size: 10,
   /*     haloColor: Colors.white,
        haloWidth: 3,*/
      )..offsetY = isSelected ? 22 : 18;

      _pointsOverlay.graphics.add(Graphic(
        geometry: p.point,
        symbol: CompositeSymbol(symbols: [pin, label]),
        attributes: {'id': p.id},
      ));
    }
    if (mounted) setState(() {});
  }

  bool get _hasActiveFilter =>
      _status != _StatusFilter.all ||
      !_includeBridges ||
      !_includeCulverts ||
      _from != null ||
      _to != null;

  // -------------------- ZOOM + INTERACTIONS --------------------

  Future<void> _zoomBy(double factor) async {
    try {
      final vp =
          _mapController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final scale = vp?.targetScale ?? ArcgisConfig.initialScale;
      await _mapController.setViewpointScale(scale * factor);
    } catch (e) {
      debugPrint('Zoom failed: $e');
    }
  }

  Future<void> _recenter() async {
    final centre = ArcGISPoint(
      x: ArcgisConfig.riyadhLng,
      y: ArcgisConfig.riyadhLat,
      spatialReference: SpatialReference.wgs84,
    );
    _mapController.setViewpoint(
      Viewpoint.fromCenter(centre, scale: ArcgisConfig.initialScale),
    );
  }

  Future<void> _toggleSatellite() async {
    setState(() => _useSatBasemap = !_useSatBasemap);
    final map = _mapController.arcGISMap;
    if (map == null) return;
    if (_useSatBasemap) {
      final sat = ArcGISTiledLayer.withUri(Uri.parse(
          'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer'));
      map.basemap = Basemap.withBaseLayer(sat);
    } else {
      // Re-run setup to reinstate the MMPK basemap.
      try {
        final pkg = await _mmpkService.loadPackage();
        await MmpkSetup.prepare(pkg, layerName: widget.layerName);
      } catch (_) {}
    }
  }

  Future<void> _onMapTap(Offset screenPoint) async {
    try {
      // The graphics overlay is a positional argument in the SDK; only the
      // screen point + tolerance + max results are named.
      final result = await _mapController.identifyGraphicsOverlay(
        _pointsOverlay,
        screenPoint: screenPoint,
        tolerance: 14,
        maximumResults: 1,
      );
      if (result.graphics.isEmpty) return;
      final g = result.graphics.first;
      final id = g.attributes['id']?.toString();
      final point = _points.firstWhere(
        (p) => p.id == id,
        orElse: () => _points.first,
      );
      setState(() => _selected = point);
      _refreshGraphics();
    } catch (e) {
      debugPrint('Identify failed: $e');
    }
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    final filteredCount = _points.where(_passesFilter).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: const StepHeader(
                title: 'Map view',
                subtitle: 'Step 1 of 2 · Select asset',
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // ---- ArcGIS map (always rendered so demo points
                      //      stay visible even when MMPK can't load) ----
                      Positioned.fill(
                        child: ArcGISMapView(
                          controllerProvider: () => _mapController,
                          onTap: _onMapTap,
                        ),
                      ),

                      if (_loading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // ---- Setup-warning banner (collapses the actual map
                      //      when MMPK / API key isn't ready, but keeps the
                      //      fallback basemap + demo points visible) ----
                      if (_setupError != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 60,
                          child: _SetupErrorBanner(
                            message: _setupError!,
                            onDismiss: () =>
                                setState(() => _setupError = null),
                          ),
                        ),

                      // ---- Top-left counter ----
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _Pill(
                          child: Text(
                            'Showing $filteredCount of ${_points.length} assets',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),

                      // ---- Top-right Map / Sat + Filter ----
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _MapPill(
                              children: [
                                _MapPillItem(
                                    label: 'MAP',
                                    selected: !_useSatBasemap,
                                    onTap: () {
                                      if (_useSatBasemap) _toggleSatellite();
                                    }),
                                _MapPillItem(
                                    label: 'SAT',
                                    selected: _useSatBasemap,
                                    onTap: () {
                                      if (!_useSatBasemap) _toggleSatellite();
                                    }),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showFilter = !_showFilter),
                              child: _MapPill(
                                children: [
                                  _MapPillItem(
                                    label: 'FILTER',
                                    icon: Icons.filter_list,
                                    selected:
                                        _showFilter || _hasActiveFilter,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---- Right-side zoom + recenter cluster ----
                      Positioned(
                        right: 12,
                        bottom: _selected == null ? 80 : 168,
                        child: Column(
                          children: [
                            _MapButton(
                                icon: Icons.add,
                                onTap: () => _zoomBy(0.5),
                                tooltip: 'Zoom in'),
                            const SizedBox(height: 8),
                            _MapButton(
                                icon: Icons.remove,
                                onTap: () => _zoomBy(2.0),
                                tooltip: 'Zoom out'),
                            const SizedBox(height: 8),
                            _MapButton(
                                icon: Icons.gps_fixed,
                                onTap: _recenter,
                                tooltip: 'Recenter on Riyadh 2'),
                          ],
                        ),
                      ),

                      // ---- Bottom legend ----
                      Positioned(
                        left: 12,
                        bottom: _selected == null ? 12 : 100,
                        child: _Pill(
                          child: Row(children: const [
                            _LegendDot(color: Color(0xFF1E5BB8)),
                            SizedBox(width: 4),
                            Text('Bridges',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary)),
                            SizedBox(width: 14),
                            _LegendDot(color: Color(0xFFF59E0B)),
                            SizedBox(width: 4),
                            Text('Culverts',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary)),
                          ]),
                        ),
                      ),

                      // ---- Bottom-right attribution ----
                      const Positioned(
                        right: 8,
                        bottom: 6,
                        child: Text(
                          'MMPK · Esri',
                          style: TextStyle(
                              fontSize: 9.5, color: AppColors.textTertiary),
                        ),
                      ),

                      // ---- Filter sheet ----
                      if (_showFilter)
                        Positioned(
                          top: 64,
                          right: 12,
                          child: _FilterSheet(
                            status: _status,
                            includeBridges: _includeBridges,
                            includeCulverts: _includeCulverts,
                            from: _from,
                            to: _to,
                            onStatus: (s) {
                              setState(() => _status = s);
                              _refreshGraphics();
                            },
                            onBridges: (v) {
                              setState(() => _includeBridges = v);
                              _refreshGraphics();
                            },
                            onCulverts: (v) {
                              setState(() => _includeCulverts = v);
                              _refreshGraphics();
                            },
                            onFrom: (d) {
                              setState(() => _from = d);
                              _refreshGraphics();
                            },
                            onTo: (d) {
                              setState(() => _to = d);
                              _refreshGraphics();
                            },
                            onClose: () =>
                                setState(() => _showFilter = false),
                            onClear: () {
                              setState(() {
                                _status = _StatusFilter.all;
                                _includeBridges = true;
                                _includeCulverts = true;
                                _from = null;
                                _to = null;
                              });
                              _refreshGraphics();
                            },
                          ),
                        ),

                      // ---- Selection bottom card ----
                      if (_selected != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: _SelectionCard(
                            point: _selected!,
                            onUse: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AssetDetailScreen(
                                      asset: _selected!.asset)),
                            ),
                            onDismiss: () {
                              setState(() => _selected = null);
                              _refreshGraphics();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  Local data + UI helpers
// ===========================================================================

class _AssetPoint {
  _AssetPoint({
    required this.id,
    required this.name,
    required this.kind,
    required this.point,
    required this.asset,
    this.inspected = false,
    this.lastInspected,
  });
  final String id;
  final String name;
  final AssetKind kind;
  final ArcGISPoint point;
  final Asset asset;
  final bool inspected;
  final DateTime? lastInspected;
}

/// Static demo entry used by `_seedDemoPoints` to drop a handful of named
/// landmark assets into the Riyadh 2 area.
class _DemoEntry {
  const _DemoEntry(this.id, this.name, this.kind, this.lat, this.lng);
  final String id;
  final String name;
  final AssetKind kind;
  final double lat;
  final double lng;
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _MapPill extends StatelessWidget {
  const _MapPill({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _MapPillItem extends StatelessWidget {
  const _MapPillItem({
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 14),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton(
      {required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SetupErrorBanner extends StatelessWidget {
  const _SetupErrorBanner(
      {required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warningBg,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.severityHigh.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline,
              color: AppColors.warningFg, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.warningFg, fontSize: 12, height: 1.3),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close,
                size: 16, color: AppColors.warningFg),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Filter sheet
// ===========================================================================

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.status,
    required this.includeBridges,
    required this.includeCulverts,
    required this.from,
    required this.to,
    required this.onStatus,
    required this.onBridges,
    required this.onCulverts,
    required this.onFrom,
    required this.onTo,
    required this.onClose,
    required this.onClear,
  });

  final _StatusFilter status;
  final bool includeBridges;
  final bool includeCulverts;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<_StatusFilter> onStatus;
  final ValueChanged<bool> onBridges;
  final ValueChanged<bool> onCulverts;
  final ValueChanged<DateTime?> onFrom;
  final ValueChanged<DateTime?> onTo;
  final VoidCallback onClose;
  final VoidCallback onClear;

  String _fmt(DateTime? d) => d == null
      ? 'dd/mm/yyyy'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const Text('INSPECTION STATUS',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  )),
              const Spacer(),
              IconButton(
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.textTertiary),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final s in _StatusFilter.values) ...[
                  Expanded(
                    child: _StatusBtn(
                      label: switch (s) {
                        _StatusFilter.all => 'All',
                        _StatusFilter.done => 'Done',
                        _StatusFilter.pending => 'Pending',
                      },
                      selected: status == s,
                      onTap: () => onStatus(s),
                    ),
                  ),
                  if (s != _StatusFilter.values.last)
                    const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 14),
            const Text('ASSET KIND',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.0,
                )),
            const SizedBox(height: 6),
            Row(children: [
              _Toggle(
                label: 'Bridges',
                value: includeBridges,
                color: const Color(0xFF1E5BB8),
                onChanged: onBridges,
              ),
              const SizedBox(width: 10),
              _Toggle(
                label: 'Culverts',
                value: includeCulverts,
                color: const Color(0xFFF59E0B),
                onChanged: onCulverts,
              ),
            ]),
            const SizedBox(height: 14),
            const Text('INSPECTED BETWEEN',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.0,
                )),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _DatePickerField(
                  label: 'FROM',
                  value: from,
                  onPick: onFrom,
                  fmt: _fmt,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DatePickerField(
                  label: 'TO',
                  value: to,
                  onPick: onTo,
                  fmt: _fmt,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.severityHigh),
                child: const Text('CLEAR DATES',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 11.5)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14)),
                child: const Text('Apply'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  const _StatusBtn(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: value ? color.withOpacity(0.10) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: value ? color : AppColors.border,
                width: value ? 1.4 : 1),
          ),
          child: Row(children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: value ? color : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? color : AppColors.textTertiary,
              size: 16,
            ),
          ]),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.fmt,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;
  final String Function(DateTime?) fmt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(fmt(value),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: value == null
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textTertiary),
            ]),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  Selection bottom card
// ===========================================================================

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.point,
    required this.onUse,
    required this.onDismiss,
  });
  final _AssetPoint point;
  final VoidCallback onUse;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          AssetThumbnail(tag: point.kind.tag),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(point.id,
                    style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6)),
                const SizedBox(height: 2),
                Text(point.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(point.asset.city,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 12)),
                  if (point.lastInspected != null) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check_circle,
                        size: 12, color: AppColors.statusSynced),
                    const SizedBox(width: 4),
                    Text(
                      'Inspected ${point.lastInspected!.day}/${point.lastInspected!.month}/${point.lastInspected!.year}',
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onUse,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(72, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14)),
            child: const Text('Use'),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close,
                size: 18, color: AppColors.textTertiary),
          ),
        ]),
      ),
    );
  }
}
