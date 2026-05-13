/// Central place to configure the ArcGIS Maps SDK + MMPK integration.
///
/// 1. Replace `apiKey` with your Esri developer key (free at
///    https://developers.arcgis.com).
/// 2. Drop the `riyadh2.mmpk` package into `assets/mmpk/` (the loader will
///    copy it from the asset bundle to the app's documents directory at
///    first launch). If you rename it, update `mmpkAssetPath` below.
/// 3. Make sure the feature layer name in your MMPK matches
///    `assetLayerName` (case-insensitive).
class ArcgisConfig {
  ArcgisConfig._();

  /// Your Esri API key. The map screen will throw a clear error message in
  /// debug if this is left as the placeholder.
 /* static const String apiKey = 'YOUR_ARCGIS_API_KEY';*/

  /// Bundled location of the MMPK file inside the Flutter `assets/`
  /// directory. Must also be listed in pubspec.yaml.
  static const String mmpkAssetPath = 'assets/mmpk/riyadh2.mmpk';

  /// Name of the feature layer (inside the MMPK) that holds the inspectable
  /// asset points. Case-insensitive match.
  static const String assetLayerName = 'Bridges';

  /// Substrings that flag a base / operational layer as a "local" raster
  /// basemap (so the loader can prefer it over the online World Imagery
  /// fallback).
  static const List<String> localBasemapHints = [
    '.tif',
    '.tpkx',
    'riyadh',
    'local',
  ];

  /// Approximate centre of the Riyadh 2 district used as the initial
  /// viewpoint when the MMPK doesn't provide one. (Riyadh 2 sits north of
  /// central Riyadh — adjust slightly if your MMPK uses a different anchor.)
  static const double riyadhLat = 24.7910;
  static const double riyadhLng = 46.6850;

  /// Initial map scale (~1:35 000 — close enough to fit the Riyadh 2 grid).
  static const double initialScale = 35000;

  /// Returns true if the API key has actually been replaced.
 /* static bool get hasValidApiKey =>
      apiKey.isNotEmpty && apiKey != 'YOUR_ARCGIS_API_KEY';*/
}
