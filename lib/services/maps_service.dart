// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:logging/logging.dart';

class MapsService {
  static final _logger = Logger('MapsService');
  static const String _mapsApiKeyConfigKey = 'google_maps_api_key_web';
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              Duration.zero, // Allow fetching immediately in development
        ),
      );

      await remoteConfig.fetchAndActivate();
      final apiKey = remoteConfig.getString(_mapsApiKeyConfigKey);

      if (apiKey.isEmpty) {
        throw Exception(
          'Google Maps API key not found in Remote Config. Please set the "$_mapsApiKeyConfigKey" parameter in Firebase Remote Config.',
        );
      }

      // Call the JavaScript function to load Google Maps with the API key
      final result = js.context.callMethod('initializeGoogleMaps', [apiKey]);

      // Convert the JavaScript Promise to a Dart Future and wait for it
      if (hasProperty(result, 'then')) {
        await promiseToFuture(result);
      }

      _isInitialized = true;
    } catch (e) {
      _logger.severe('Error initializing Google Maps: $e');
      rethrow;
    }
  }
}
