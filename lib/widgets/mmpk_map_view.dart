import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

import '../config/arcgis_config.dart';
import '../data/models.dart';
import '../services/mmpk_service.dart';
import '../theme/app_colors.dart';

/// Shared MMPK-backed map. Used by Asset Registry, Inspections, and the
/// asset-finder map. Drops one labelled circle per [Asset] over the basemap
/// from the bundled `riyadh2.mmpk`.
///
/// If the API key isn't set OR the MMPK file is missing, the widget loads
/// ArcGIS World Imagery as a fallback so the demo still works (a small
/// banner on top tells the user how to fix it).
class MmpkMapView extends StatefulWidget {
  const MmpkMapView({
    super.key,
    required this.assets,
    this.selectedId,
    this.onAssetTap,
    this.satelliteByDefault = false,
  });

  final List<Asset> assets;
  final String? selectedId;
  final ValueChanged<Asset>? onAssetTap;
  final bool satelliteByDefault;

  @override
  State<MmpkMapView> createState() => _MmpkMapViewState();
}

class _MmpkMapViewState extends State<MmpkMapView> {
  final ArcGISMapViewController _controller =
      ArcGISMapView.createController();
  final GraphicsOverlay _pinsOverlay = GraphicsOverlay();
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  @override
  void didUpdateWidget(covariant MmpkMapView old) {
    super.didUpdateWidget(old);
    if (_ready && old.assets != widget.assets) _refreshPins();
    if (_ready && old.selectedId != widget.selectedId) _refreshPins();
  }

  Future<void> _setup() async {
    try {
      // Always start with an online basemap so the map paints immediately.
      final fallback = ArcGISMap.withBasemap(
        Basemap.withStyle(widget.satelliteByDefault
            ? BasemapStyle.arcGISImagery
            : BasemapStyle.arcGISTopographic),
      );
      _controller.arcGISMap = fallback;
      _controller.graphicsOverlays.add(_pinsOverlay);
       _controller.setViewpoint(Viewpoint.fromCenter(
        ArcGISPoint(
          x: ArcgisConfig.riyadhLng,
          y: ArcgisConfig.riyadhLat,
          spatialReference: SpatialReference.wgs84,
        ),
        scale: ArcgisConfig.initialScale,
      ));
      _refreshPins();
      if (mounted) setState(() => _ready = true);

      // Try upgrading to the bundled MMPK in the background.
     /* if (!ArcgisConfig.hasValidApiKey) {
        if (mounted) {
          setState(() => _error =
              'ArcGIS API key missing — using the online fallback.');
        }
        return;
      }*/
      try {
        final pkg = await MmpkService().loadPackage();
        final result = await MmpkSetup.prepare(pkg);
        _controller.arcGISMap = result.map;
        if (!_controller.graphicsOverlays.contains(_pinsOverlay)) {
          _controller.graphicsOverlays.add(_pinsOverlay);
        }
         _controller.setViewpoint(Viewpoint.fromCenter(
          ArcGISPoint(
            x: ArcgisConfig.riyadhLng,
            y: ArcgisConfig.riyadhLat,
            spatialReference: SpatialReference.wgs84,
          ),
          scale: ArcgisConfig.initialScale,
        ));
        _refreshPins();
        if (mounted) setState(() => _error = null);
      } catch (e) {
        if (mounted) {
          setState(() => _error =
              'MMPK could not be loaded — using online imagery instead.');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Map setup failed: $e');
    }
  }

  void _refreshPins() {
    _pinsOverlay.graphics.clear();
    for (final a in widget.assets) {
      final isSelected = a.id == widget.selectedId;
      final colour = a.kind == AssetKind.bridge
          ? const Color(0xFF1E5BB8)
          : const Color(0xFFF59E0B);
      final pin = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: colour,
        size: isSelected ? 22 : 16,
      )..outline = SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: const Color(0xFFFFFFFF),
          width: 3,
        );
      final label = TextSymbol(
        text: a.id,
        color: const Color(0xFF0A2540),
        size: 10,
 /*       haloColor: Colors.white,
        haloWidth: 3,*/
      )..offsetY = isSelected ? 22 : 18;
      _pinsOverlay.graphics.add(Graphic(
        geometry: ArcGISPoint(
            x: a.lng,
            y: a.lat,
            spatialReference: SpatialReference.wgs84),
        symbol: CompositeSymbol(symbols: [pin, label]),
        attributes: {'id': a.id},
      ));
    }
    if (mounted) setState(() {});
  }

  Future<void> _onTap(Offset screenPoint) async {
    if (widget.onAssetTap == null) return;
    try {
      final result = await _controller.identifyGraphicsOverlay(
        _pinsOverlay,
        screenPoint: screenPoint,
        tolerance: 14,
        maximumResults: 1,
      );
      if (result.graphics.isEmpty) return;
      final id = result.graphics.first.attributes['id']?.toString();
      final hit = widget.assets.firstWhere(
        (a) => a.id == id,
        orElse: () => widget.assets.first,
      );
      widget.onAssetTap!(hit);
    } catch (_) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: ArcGISMapView(
          controllerProvider: () => _controller,
          onTap: _onTap,
        ),
      ),
      if (!_ready)
        const Center(child: CircularProgressIndicator()),
      if (_error != null)
        Positioned(
          left: 12, right: 12, top: 12,
          child: Material(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warningFg, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.warningFg, fontSize: 11.5)),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }
}
