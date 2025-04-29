import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

/// Data class to hold marker information for boundary images
class MarkerData {
  final String imageUrl;
  final gmap.LatLng position;

  const MarkerData({
    required this.imageUrl,
    required this.position,
  });
}
