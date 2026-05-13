import 'dart:io';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../config/arcgis_config.dart';

/// Loads an MMPK from the Flutter asset bundle.
///
/// Esri's [MobileMapPackage] needs a real file URI, so the bundled MMPK is
/// copied into the application documents directory on first launch.
class MmpkService {
  MmpkService({this.assetPath = ArcgisConfig.mmpkAssetPath});

  final String assetPath;

  MobileMapPackage? _cached;

  /// Loads (and caches) the package. Subsequent calls return the same
  /// instance unless [forceReload] is `true`.
  Future<MobileMapPackage> loadPackage({bool forceReload = false}) async {
    if (_cached != null && !forceReload) return _cached!;
    final filePath = await _ensureLocalCopy();
    final pkg = MobileMapPackage.withFileUri(Uri.file(filePath));
    await pkg.load();
    _cached = pkg;
    return pkg;
  }

  Future<String> _ensureLocalCopy() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = assetPath.split('/').last;
    final dest = File('${dir.path}/$fileName');
    if (!dest.existsSync()) {
      try {
        final bytes = await rootBundle.load(assetPath);
        await dest.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
      } catch (e) {
        throw StateError(
          'Could not load MMPK asset "$assetPath". Make sure the file is '
          'present and listed under "flutter / assets" in pubspec.yaml. '
          'Underlying error: $e',
        );
      }
    }
    return dest.path;
  }
}

/// Ports the basemap-promotion + feature-layer discovery logic from the
/// reference snippet — kept in one place so the map screen stays readable.
class MmpkSetupResult {
  MmpkSetupResult({
    required this.map,
    required this.featureLayer,
    required this.featureTable,
  });

  final ArcGISMap map;
  final FeatureLayer? featureLayer;
  final FeatureTable? featureTable;
}

class MmpkSetup {
  MmpkSetup._();

  /// Picks a sensible basemap (preferring a local raster from the MMPK if
  /// one exists, otherwise falling back to ArcGIS World Imagery), finds the
  /// inspectable feature layer, and returns the prepared map.
  static Future<MmpkSetupResult> prepare(MobileMapPackage pkg,
      {String layerName = ArcgisConfig.assetLayerName}) async {
    if (pkg.maps.isEmpty) {
      throw StateError('MMPK contains no maps');
    }
    final map = pkg.maps.first;

    // -------- Basemap selection --------
    bool foundLocalBasemap = false;
    String? chosenBasemapLayerName;

    try {
      if (map.basemap != null && map.basemap!.baseLayers.isNotEmpty) {
        for (final base in map.basemap!.baseLayers) {
          final n = (base.name ?? '').toString().toLowerCase();
          final isLocal =
              ArcgisConfig.localBasemapHints.any((h) => n.contains(h));
          if (isLocal) {
            base.isVisible = true;
            foundLocalBasemap = true;
            debugPrint('MMPK: using local basemap layer "$n"');
          }
        }
        if (foundLocalBasemap) {
          for (final base in map.basemap!.baseLayers) {
            final n = (base.name ?? '').toString().toLowerCase();
            final isLocal =
                ArcgisConfig.localBasemapHints.any((h) => n.contains(h));
            if (!isLocal) {
              try {
                base.isVisible = false;
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint('MMPK: error inspecting basemap layers — $e');
    }

    // If the MMPK basemap layers don't have a local raster, look for one
    // among the operational layers and promote it.
    if (!foundLocalBasemap) {
      for (final layer in map.operationalLayers) {
        final lname = (layer.name ?? '').toString().toLowerCase();
        final rtype = layer.runtimeType.toString().toLowerCase();
        final isHint =
            ArcgisConfig.localBasemapHints.any((h) => lname.contains(h));
        final isRaster = rtype.contains('raster') ||
            rtype.contains('imag') ||
            rtype.contains('tiled');
        if (isHint || isRaster) {
          chosenBasemapLayerName = lname;
          try {
            layer.isVisible = true;
          } catch (_) {}
          foundLocalBasemap = true;
          debugPrint('MMPK: promoting operational layer "$lname" to basemap');
          break;
        }
      }
    }

    // Promote the chosen operational layer into the basemap proper if we
    // can — that way it renders behind the feature graphics.
    if (foundLocalBasemap && chosenBasemapLayerName != null) {
      for (final layer in List.of(map.operationalLayers)) {
        final nm = (layer.name ?? '').toString().toLowerCase();
        if (nm != chosenBasemapLayerName) continue;
        try {
          map.operationalLayers.remove(layer);
          if (layer is ArcGISTiledLayer) {
            map.basemap = Basemap.withBaseLayer(layer);
          } else {
            try {
              map.basemap?.baseLayers.add(layer);
            } catch (e) {
              debugPrint('MMPK: could not add layer to basemap — $e');
              try {
                layer.isVisible = true;
              } catch (_) {}
            }
          }
        } catch (e) {
          debugPrint('MMPK: promotion failed — $e');
        }
        break;
      }
    }

    // No local basemap found — fall back to online imagery.
    if (!foundLocalBasemap) {
      debugPrint('MMPK: no local basemap found, falling back to World Imagery');
      final fallback = ArcGISTiledLayer.withUri(Uri.parse(
          'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer'));
      map.basemap = Basemap.withBaseLayer(fallback);
    }

    // -------- Feature layer discovery --------
    FeatureLayer? featureLayer;
    FeatureTable? featureTable;
    for (final layer in map.operationalLayers) {
      if (layer is FeatureLayer &&
          (layer.name ?? '').toLowerCase() == layerName.toLowerCase()) {
        layer.isVisible = true;
        featureLayer = layer;
        featureTable = layer.featureTable;
        try {
          await featureTable?.load();
        } catch (e) {
          debugPrint('MMPK: feature table load failed — $e');
        }
        break;
      }
    }

    return MmpkSetupResult(
      map: map,
      featureLayer: featureLayer,
      featureTable: featureTable,
    );
  }
}
