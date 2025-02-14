import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:coffee_mapper_web/services/shade_service.dart';
import 'package:coffee_mapper_web/services/coffee_service.dart';
import 'package:coffee_mapper_web/models/shade_data.dart';
import 'package:coffee_mapper_web/models/coffee_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/dialogs/boundary_images/custom_info_window.dart';
import 'package:coffee_mapper_web/widgets/map/map_header.dart';

class MapOverviewSection extends StatefulWidget {
  const MapOverviewSection({super.key});

  @override
  State<MapOverviewSection> createState() => _MapOverviewSectionState();
}

class _MapOverviewSectionState extends State<MapOverviewSection>
    with SingleTickerProviderStateMixin {
  final ShadeService _shadeService = ShadeService();
  final CoffeeService _coffeeService = CoffeeService();

  // Map controller and state
  gmap.GoogleMapController? _mapController;
  final Set<gmap.Marker> _markers = {};
  final Set<gmap.Polygon> _polygons = {};
  gmap.LatLng? _selectedLocation;
  String? _selectedImageUrl;
  bool _isMapLoading = true;
  bool _isDisposed = false;
  double _currentZoom = 10.0; // Track current zoom level
  static const double _minMarkerInteractionZoom =
      14.0; // Minimum zoom level for marker interaction

  // Animation controller for zoom message
  late AnimationController _messageController;
  bool _showZoomMessage = false;
  gmap.LatLng? _lastCenterPosition;
  double? _lastZoomLevel;

  // Filter state
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;
  Set<String> selectedRegionCategories =
      {}; // Changed to Set for multiple selections

  // Data state
  List<ShadeData> allShadeData = [];
  List<CoffeeData> allCoffeeData = [];
  List<dynamic> filteredData = [];

  // Streams
  late Stream<List<ShadeData>> _shadeDataStream;
  late Stream<List<CoffeeData>> _coffeeDataStream;

  @override
  void initState() {
    super.initState();
    _shadeDataStream = _shadeService.getShadeDataStream();
    _coffeeDataStream = _coffeeService.getCoffeeDataStream();
    _messageController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 2000), // Just the fade out duration
    );
    _messageController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showZoomMessage = false);
      }
    });
    _initializeData();
  }

  void _initializeData() {
    _shadeDataStream.listen((shadeData) {
      if (!mounted) return;
      setState(() {
        allShadeData = shadeData;
        _updateFilteredData();
      });
    });

    _coffeeDataStream.listen((coffeeData) {
      if (!mounted) return;
      setState(() {
        allCoffeeData = coffeeData;
        _updateFilteredData();
      });
    });
  }

  void _updateFilteredData() {
    setState(() {
      filteredData = [
        ...allShadeData.where(_matchesFilters),
        ...allCoffeeData.where(_matchesFilters),
      ];
      _updateMapPolygons();
    });
  }

  bool _matchesFilters(dynamic data) {
    return (selectedDistrict == null ||
            selectedDistrict!.isEmpty ||
            data.district == selectedDistrict) &&
        (selectedBlock == null ||
            selectedBlock!.isEmpty ||
            data.block == selectedBlock) &&
        (selectedPanchayat == null ||
            selectedPanchayat!.isEmpty ||
            data.panchayat == selectedPanchayat) &&
        (selectedVillage == null ||
            selectedVillage!.isEmpty ||
            data.village == selectedVillage) &&
        (selectedRegionCategories.isEmpty ||
            selectedRegionCategories.contains(data.regionCategory));
  }

  List<String> _getUniqueValues(String Function(dynamic) selector) {
    Set<String> values = {};
    for (var data in [...allShadeData, ...allCoffeeData]) {
      String value = selector(data);
      if (value.isNotEmpty) {
        values.add(value);
      }
    }
    return values.toList()..sort();
  }

  List<String> _getFilteredValues(
    String Function(dynamic) selector, {
    String? district,
    String? block,
    String? panchayat,
    String? village,
    bool isRegionCategory = false,
  }) {
    Set<String> values = {};
    for (var data in [...allShadeData, ...allCoffeeData]) {
      // Apply filters hierarchically
      if (district != null && data.district != district) continue;
      if (block != null && data.block != block) continue;
      if (panchayat != null && data.panchayat != panchayat) continue;
      if (village != null && data.village != village) continue;

      String value = selector(data);
      if (value.isNotEmpty) {
        if (isRegionCategory) {
          // For region categories, only add if it's in the predefined list
          if (allRegionCategories.contains(value)) {
            values.add(value);
          }
        } else {
          values.add(value);
        }
      }
    }
    return values.toList()..sort();
  }

  List<String> get allRegionCategories => [
        ...ShadeService.shadeCategories,
        ...CoffeeService.coffeeCategories,
      ];

  void _updateMapPolygons() {
    if (_isDisposed) return;

    setState(() {
      _markers.clear();
      _polygons.clear();

      if (!_hasActiveFilters()) return;

      for (var data in filteredData) {
        // Add polygon
        if (data.polygonCoordinates.isNotEmpty) {
          try {
            List<gmap.LatLng> points =
                _convertToLatLng(data.polygonCoordinates);
            if (points.isNotEmpty) {
              _polygons.add(
                gmap.Polygon(
                  polygonId: gmap.PolygonId(data.id),
                  points: points,
                  strokeColor: Theme.of(context).colorScheme.secondary,
                  fillColor:
                      Theme.of(context).colorScheme.secondary.withAlpha(77),
                  strokeWidth: 2,
                ),
              );

              // Add markers for boundary images
              if (data.boundaryImageURLs.isNotEmpty) {
                // Extract coordinates from image URLs for markers
                for (String url in data.boundaryImageURLs) {
                  try {
                    // Extract filename from the URL
                    final uri = Uri.parse(url);
                    final pathSegments = uri.pathSegments;
                    if (pathSegments.isEmpty) continue;

                    // Get the filename (last segment)
                    final filename = pathSegments.last;

                    // Extract coordinates part (remove extension and token)
                    final coordPart =
                        filename.split('/').last.split('.jpg').first;
                    final coords = coordPart.split('_');

                    if (coords.length == 2) {
                      final lat = double.tryParse(coords[0]);
                      final lng = double.tryParse(coords[1]);
                      if (lat != null && lng != null) {
                        final newLocation = gmap.LatLng(lat, lng);
                        _markers.add(
                          gmap.Marker(
                            markerId:
                                gmap.MarkerId('${data.id}_${_markers.length}'),
                            position: newLocation,
                            icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
                              gmap.BitmapDescriptor.hueOrange,
                            ),
                            onTap: () {
                              if (_currentZoom >= _minMarkerInteractionZoom) {
                                setState(() {
                                  _selectedLocation = null;
                                  _selectedImageUrl = null;

                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    if (mounted) {
                                      setState(() {
                                        _selectedLocation = newLocation;
                                        _selectedImageUrl = url;
                                      });
                                    }
                                  });
                                });
                              } else {
                                setState(() {
                                  // Reset the animation state
                                  _messageController.reset();
                                  _showZoomMessage = true;
                                });

                                // Start the fade out after 2 seconds
                                Future.delayed(
                                    const Duration(milliseconds: 2000), () {
                                  if (mounted && _showZoomMessage) {
                                    _messageController.forward(from: 0);
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Continue to next coordinate instead of throwing
                  }
                }
              }
            }
          } catch (e) {
            // Continue to next polygon instead of throwing
          }
        }
      }

      if (_polygons.isNotEmpty) {
        _fitMapBounds();
      }
    });
  }

  List<gmap.LatLng> _convertToLatLng(List<String> coordinates) {
    List<gmap.LatLng> points = [];

    for (String coord in coordinates) {
      try {
        // Remove any whitespace and split by comma
        List<String> parts = coord.trim().split(',');

        if (parts.length == 2) {
          // Parse and validate each part
          double? lat = double.tryParse(parts[0].trim());
          double? lng = double.tryParse(parts[1].trim());

          if (lat != null &&
              lng != null &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180) {
            points.add(gmap.LatLng(lat, lng));
          }
        }
      } catch (e) {
        // Continue to next coordinate instead of throwing
      }
    }

    return points;
  }

  void _fitMapBounds() {
    if (_mapController == null || _polygons.isEmpty || _isDisposed) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var polygon in _polygons) {
      for (var point in polygon.points) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }
    }

    final paddingFactor = _polygons.length > 5 ? 0.1 : 0.2;
    final latPadding = (maxLat - minLat) * paddingFactor;
    final lngPadding = (maxLng - minLng) * paddingFactor;

    final targetBounds = gmap.LatLngBounds(
      southwest: gmap.LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: gmap.LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    // If we have a last position, animate directly to new bounds
    if (_lastCenterPosition != null && _lastZoomLevel != null) {
      _mapController!.animateCamera(
        gmap.CameraUpdate.newLatLngBounds(
          targetBounds,
          50,
        ),
      );
    } else {
      // First time or after reset, use the two-step animation
      _mapController!.moveCamera(
        gmap.CameraUpdate.newCameraPosition(
          gmap.CameraPosition(
            target: gmap.LatLng(
              (minLat + maxLat) / 2,
              (minLng + maxLng) / 2,
            ),
            zoom: 8,
          ),
        ),
      );

      Future.delayed(const Duration(milliseconds: 150), () {
        if (_isDisposed || _mapController == null) return;
        _mapController!.animateCamera(
          gmap.CameraUpdate.newLatLngBounds(
            targetBounds,
            50,
          ),
        );
      });
    }
  }

  void _onMapCreated(gmap.GoogleMapController controller) {
    if (_isDisposed) return;

    setState(() {
      _mapController = controller;
      _isMapLoading = false;
      if (_polygons.isNotEmpty) {
        _fitMapBounds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    // Make map height larger and responsive
    final mapHeight = isMobile
        ? screenHeight * 0.85 // 70% of screen height on mobile
        : isTablet
            ? screenHeight * 0.78 // 65% of screen height on tablet
            : screenHeight * 0.7; // 60% of screen height on desktop

    // Get filtered lists based on current selections
    final districts = _getUniqueValues((data) => data.district);
    final blocks = _getFilteredValues(
      (data) => data.block,
      district: selectedDistrict,
    );
    final panchayats = _getFilteredValues(
      (data) => data.panchayat,
      district: selectedDistrict,
      block: selectedBlock,
    );
    final villages = _getFilteredValues(
      (data) => data.village,
      district: selectedDistrict,
      block: selectedBlock,
      panchayat: selectedPanchayat,
    );

    // Get filtered region categories based on all location filters
    final filteredRegionCategories = _getFilteredValues(
      (data) => data.regionCategory,
      district: selectedDistrict,
      block: selectedBlock,
      panchayat: selectedPanchayat,
      village: selectedVillage,
      isRegionCategory: true,
    );

    return Column(
      children: [
        MapHeader(
          districts: districts,
          blocks: blocks,
          panchayats: panchayats,
          villages: villages,
          regionCategories: filteredRegionCategories,
          selectedRegionCategories:
              selectedRegionCategories, // Pass selected categories
          onDistrictChanged: (value) => setState(() {
            selectedDistrict = value.isEmpty ? null : value;
            selectedBlock = null;
            selectedPanchayat = null;
            selectedVillage = null;
            selectedRegionCategories
                .clear(); // Clear region categories when district changes
            _updateFilteredData();
          }),
          onBlockChanged: (value) => setState(() {
            selectedBlock = value.isEmpty ? null : value;
            selectedPanchayat = null;
            selectedVillage = null;
            selectedRegionCategories
                .clear(); // Clear region categories when block changes
            _updateFilteredData();
          }),
          onPanchayatChanged: (value) => setState(() {
            selectedPanchayat = value.isEmpty ? null : value;
            selectedVillage = null;
            selectedRegionCategories
                .clear(); // Clear region categories when panchayat changes
            _updateFilteredData();
          }),
          onVillageChanged: (value) => setState(() {
            selectedVillage = value.isEmpty ? null : value;
            selectedRegionCategories
                .clear(); // Clear region categories when village changes
            _updateFilteredData();
          }),
          onRegionCategoriesChanged: (categories) => setState(() {
            // Updated to handle multiple selections
            selectedRegionCategories = categories;
            _updateFilteredData();
          }),
        ),
        const SizedBox(height: 16),
        Container(
          height: mapHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              gmap.GoogleMap(
                initialCameraPosition: const gmap.CameraPosition(
                  target: gmap.LatLng(19.0, 82.0), // Default to Koraput region
                  zoom: 10,
                ),
                mapType: gmap.MapType.satellite,
                markers: _hasActiveFilters() ? _markers : {},
                polygons: _hasActiveFilters() ? _polygons : {},
                onMapCreated: _onMapCreated,
                onCameraMove: (position) {
                  _currentZoom = position.zoom;
                  _lastCenterPosition = position.target;
                  _lastZoomLevel = position.zoom;
                },
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
              if (!_isMapLoading && !_hasActiveFilters())
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Select filters to view regions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              if (_selectedLocation != null && _selectedImageUrl != null)
                Positioned(
                  left: isMobile ? 35 : 55,
                  top: isMobile ? 35 : 55,
                  child: CustomInfoWindow(
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
              if (_showZoomMessage)
                FadeTransition(
                  opacity: Tween<double>(
                    begin: 1.0,
                    end: 0.0,
                  ).animate(CurvedAnimation(
                    parent: _messageController,
                    curve: Curves.easeInOut,
                  )),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withAlpha(230),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Please zoom in to see Marker Image',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.error,
                          fontFamily: 'Gilroy-SemiBold',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return (selectedDistrict?.isNotEmpty ?? false) ||
        (selectedBlock?.isNotEmpty ?? false) ||
        (selectedPanchayat?.isNotEmpty ?? false) ||
        (selectedVillage?.isNotEmpty ?? false) ||
        selectedRegionCategories.isNotEmpty;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _isDisposed = true;
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
