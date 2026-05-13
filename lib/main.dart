import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'config/arcgis_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ArcGIS Maps SDK — required for MMPK loading + ArcGISMapView. Replace
  // the placeholder in lib/config/arcgis_config.dart with your own key.
  if (ArcgisConfig.hasValidApiKey) {
    ArcGISEnvironment.apiKey = ArcgisConfig.apiKey;
  } else {
    debugPrint(
        '⚠️  ArcGIS API key is not set. Map screen will show a setup banner. '
        'Add your key in lib/config/arcgis_config.dart.');
  }

  // Tablets: prefer landscape but allow rotation.
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AssetifaiApp());
}
