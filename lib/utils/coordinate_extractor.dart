import 'package:coffee_mapper_web/models/marker_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:logging/logging.dart';

/// Utility class to extract coordinates from boundary image URLs
class CoordinateExtractor {
  static final _logger = Logger('CoordinateExtractor');

  // Regex pattern to match coordinates in the format: latitude_longitude
  static final _coordsPattern = RegExp(r'(\d+\.\d+)_(\d+\.\d+)');

  /// Extracts coordinates from a boundary image URL
  /// The URL format is expected to be:
  /// .../boundaryImages/{latitude}_{longitude}...
  static gmap.LatLng? extractFromUrl(String url) {
    try {
      // Find the boundaryImages part in the URL
      final boundaryImagesIndex = url.indexOf('boundaryImages');
      if (boundaryImagesIndex == -1) {
        _logger.warning('Could not find boundaryImages in URL');
        return null;
      }

      // Get the part of the URL after boundaryImages
      final afterBoundaryImages =
          url.substring(boundaryImagesIndex + 'boundaryImages'.length);

      // Handle URL encoding by looking for %2F (encoded forward slash)
      final searchArea = afterBoundaryImages.contains('%2F')
          ? afterBoundaryImages
              .substring(afterBoundaryImages.indexOf('%2F') + 3)
          : afterBoundaryImages;

      // Find the first match of the coordinates pattern in the search area
      final match = _coordsPattern.firstMatch(searchArea);

      if (match != null && match.groupCount >= 2) {
        final lat = double.tryParse(match.group(1)!);
        final lng = double.tryParse(match.group(2)!);

        if (lat != null && lng != null) {
          // Validate coordinate ranges
          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
            return gmap.LatLng(lat, lng);
          } else {
            _logger.warning('Coordinates out of valid range: ($lat, $lng)');
          }
        }
      }

      _logger.warning('Could not find valid coordinates in URL');
      return null;
    } catch (e, stackTrace) {
      _logger.severe('Error extracting coordinates from URL', e, stackTrace);
      return null;
    }
  }

  /// Extracts coordinates from a list of boundary image URLs and returns a list of MarkerData
  static List<MarkerData> extractMarkersFromUrls(List<String> urls) {
    final markers = urls
        .map((url) {
          final position = extractFromUrl(url);
          if (position != null) {
            return MarkerData(
              imageUrl: url,
              position: position,
            );
          }
          return null;
        })
        .whereType<MarkerData>()
        .toList();

    return markers;
  }
}
