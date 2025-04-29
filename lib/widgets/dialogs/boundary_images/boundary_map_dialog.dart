import 'package:coffee_mapper_web/models/marker_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/dialogs/boundary_images/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class BoundaryMapDialog extends StatefulWidget {
  final List<MarkerData> markers;
  final List<gmap.LatLng> polygonPoints;

  const BoundaryMapDialog({
    super.key,
    required this.markers,
    required this.polygonPoints,
  });

  static void show(
    BuildContext context, {
    required List<MarkerData> markers,
    required List<gmap.LatLng> polygonPoints,
  }) {
    if (markers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid coordinates available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate coordinate ranges
    bool hasInvalidCoordinates = markers.any((marker) =>
        marker.position.latitude < -90 ||
        marker.position.latitude > 90 ||
        marker.position.longitude < -180 ||
        marker.position.longitude > 180);

    if (hasInvalidCoordinates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some coordinates are invalid'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: BoundaryMapDialog(
            markers: markers,
            polygonPoints: polygonPoints,
          ),
        ),
      ),
    );
  }

  @override
  State<BoundaryMapDialog> createState() => _BoundaryMapDialogState();
}

class _BoundaryMapDialogState extends State<BoundaryMapDialog> {
  gmap.GoogleMapController? _mapController;
  final Set<gmap.Marker> _markers = {};
  final Set<gmap.Polygon> _polygons = {};
  gmap.LatLng? _selectedLocation;
  String? _selectedImageUrl;
  bool _initialized = false;
  bool _isMapLoading = true;
  bool _areMarkersReady = false;
  String? _mapError;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _setupPolygon();
      _initialized = true;
    }
  }

  void _setupMarkers() {
    if (_isDisposed) return;

    setState(() {
      _markers.clear();
      // Add markers
      for (int i = 0; i < widget.markers.length; i++) {
        final markerData = widget.markers[i];
        _markers.add(
          gmap.Marker(
            markerId: gmap.MarkerId('image_$i'),
            position: markerData.position,
            icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
              gmap.BitmapDescriptor.hueOrange,
            ),
            onTap: () {
              setState(() {
                _selectedLocation = markerData.position;
                _selectedImageUrl = markerData.imageUrl;
              });
            },
          ),
        );
      }
      _areMarkersReady = true;
    });
  }

  void _setupPolygon() {
    // Add polygon
    if (widget.polygonPoints.isNotEmpty) {
      _polygons.add(
        gmap.Polygon(
          polygonId: const gmap.PolygonId('boundary'),
          points: widget.polygonPoints,
          strokeColor: Theme.of(context).colorScheme.secondary,
          fillColor:
              Theme.of(context).colorScheme.secondary.withValues(alpha: 120),
          strokeWidth: 2,
        ),
      );
    }
  }

  void _onMapCreated(gmap.GoogleMapController controller) {
    if (_isDisposed) return;

    try {
      setState(() {
        _mapController = controller;
        _isMapLoading = false;
        _mapError = null;
      });

      // First fit bounds
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_isDisposed && _mapController != null) {
          _fitBounds();
          // Then add markers after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!_isDisposed) {
              _setupMarkers();
            }
          });
        }
      });
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isMapLoading = false;
          _mapError = 'Error loading map: $e';
        });
      }
    }
  }

  void _fitBounds() {
    if (_mapController == null || widget.markers.isEmpty || _isDisposed) return;

    double minLat = widget.markers.first.position.latitude;
    double maxLat = widget.markers.first.position.latitude;
    double minLng = widget.markers.first.position.longitude;
    double maxLng = widget.markers.first.position.longitude;

    // Include both markers and polygon points in bounds calculation
    for (final marker in widget.markers) {
      final point = marker.position;
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    for (final point in widget.polygonPoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    // Add padding to the bounds
    final latPadding = (maxLat - minLat) * 0.3; // 30% padding
    final lngPadding = (maxLng - minLng) * 0.3; // 30% padding

    _mapController!.animateCamera(
      gmap.CameraUpdate.newLatLngBounds(
        gmap.LatLngBounds(
          southwest: gmap.LatLng(minLat - latPadding, minLng - lngPadding),
          northeast: gmap.LatLng(maxLat + latPadding, maxLng + lngPadding),
        ),
        100, // increased padding in pixels
      ),
    );
  }

  // ignore: deprecated_member_use
  void _handleKeyPress(RawKeyEvent event) {
    // ignore: deprecated_member_use
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        ResponsiveUtils.isMobile(MediaQuery.of(context).size.width);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _isDisposed = true;
      },
      // ignore: deprecated_member_use
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKeyPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              gmap.GoogleMap(
                initialCameraPosition: gmap.CameraPosition(
                  target: widget.markers.first.position,
                  zoom: 15,
                ),
                mapType: gmap.MapType.satellite,
                markers: _areMarkersReady ? _markers : {},
                polygons: _polygons,
                onMapCreated: _onMapCreated,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                onTap: (_) {
                  setState(() {
                    _selectedLocation = null;
                    _selectedImageUrl = null;
                  });
                },
              ),
              if (_isMapLoading)
                Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_mapError != null)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _mapError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isMapLoading = true;
                              _mapError = null;
                            });
                            _setupMarkers();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedLocation != null && _selectedImageUrl != null)
                Positioned(
                  left: isMobile ? 35 : 55,
                  top: isMobile ? 35 : 55,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: CustomInfoWindow(
                      key: ValueKey(_selectedImageUrl),
                      imageUrl: _selectedImageUrl!,
                      coordinates: _selectedLocation!,
                      onClose: () {
                        setState(() {
                          _selectedLocation = null;
                          _selectedImageUrl = null;
                        });
                      },
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Add a small delay before disposing the controller
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        _mapController?.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    });
    super.dispose();
  }
}
