import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class MapsTestWidget extends StatelessWidget {
  const MapsTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Google Maps Test'),
            const SizedBox(height: 16),
            Expanded(
              child: gmap.GoogleMap(
                initialCameraPosition: gmap.CameraPosition(
                  target: gmap.LatLng(18.8137326, 82.7001428), // Default coordinates
                  zoom: 14,
                ),
                mapType: gmap.MapType.satellite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show test dialog
void showMapsTestDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const MapsTestWidget(),
  );
} 