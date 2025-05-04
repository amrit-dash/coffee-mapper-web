import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/coffee_data.dart';
import 'package:coffee_mapper_web/utils/archive_utils.dart';
import 'package:logging/logging.dart';

class CoffeeService {
  final _log = Logger('CoffeeService');

  // Initialize Firestore with persistence enabled
  final FirebaseFirestore _firestore = FirebaseFirestore.instance
    ..settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  // Known coffee categories
  static const List<String> coffeeCategories = [
    'Pre Survey Coffee',
    'Bearing Coffee',
    'Non Bearing Coffee',
    'Private Plantation Coffee'
  ];

  // Cache settings
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration cleanupInterval = Duration(minutes: 1);
  static const int maxCacheItems = 1000; // Maximum number of items to cache
  List<CoffeeData>? _cachedCoffeeData;
  DateTime? _lastCacheTime;
  Stream<List<CoffeeData>>? _activeStream;
  Timer? _cleanupTimer;

  // Cache monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;

  CoffeeService() {
    // Start automatic cache cleanup
    _startCleanupTimer();
  }

  // Start the cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer =
        Timer.periodic(cleanupInterval, (_) => _performCacheCleanup());
  }

  // Perform cache cleanup
  void _performCacheCleanup() {
    if (_lastCacheTime == null || _cachedCoffeeData == null) return;

    final age = DateTime.now().difference(_lastCacheTime!);
    if (age >= cacheDuration) {
      _log.info(
          'Cache cleanup: Clearing expired cache (age: ${age.inSeconds}s)');
      clearCache();
    } else if (_cachedCoffeeData!.length > maxCacheItems) {
      _log.info('Cache cleanup: Trimming cache to size limit');
      _cachedCoffeeData = _cachedCoffeeData!.sublist(0, maxCacheItems);
    }
  }

  // Get real-time stream of coffee data with caching
  Stream<List<CoffeeData>> getCoffeeDataStream() {
    _performCacheCleanup(); // Check cache before returning stream

    // Return existing stream if active
    if (_activeStream != null) {
      return _activeStream!;
    }

    // Create the base query
    final query = _firestore
        .collection('savedRegions')
        .where('regionCategory', whereIn: coffeeCategories)
        .orderBy('updatedOn', descending: true)
        .limit(maxCacheItems); // Limit the number of documents

    // Create the stream with caching
    _activeStream = query.snapshots().map((snapshot) {
      // Convert documents to CoffeeData objects
      final List<CoffeeData> data =
          snapshot.docs.map((doc) => _convertToCoffeeData(doc)).toList();

      // Update cache with size limit
      if (data.length <= maxCacheItems) {
        _cachedCoffeeData = data;
        _lastCacheTime = DateTime.now();
      } else {
        // If data exceeds limit, store only the most recent items
        _cachedCoffeeData = data.sublist(0, maxCacheItems);
        _lastCacheTime = DateTime.now();
        _log.warning(
            'Data size exceeds cache limit. Caching only the most recent $maxCacheItems items.');
      }

      return data;
    });

    return _activeStream!;
  }

  // Get cached data if available and not expired
  List<CoffeeData>? getCachedData() {
    _performCacheCleanup(); // Check cache before returning data

    if (_cachedCoffeeData != null && _lastCacheTime != null) {
      final age = DateTime.now().difference(_lastCacheTime!);
      if (age < cacheDuration) {
        _cacheHits++;
        return _cachedCoffeeData;
      }
    }
    _cacheMisses++;
    return null;
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': _cacheHits + _cacheMisses == 0
          ? 0
          : _cacheHits / (_cacheHits + _cacheMisses),
      'currentCacheSize': _cachedCoffeeData?.length ?? 0,
      'maxCacheSize': maxCacheItems,
      'isCacheValid': _lastCacheTime != null
          ? DateTime.now().difference(_lastCacheTime!) < cacheDuration
          : false,
      'cacheAge': _lastCacheTime != null
          ? DateTime.now().difference(_lastCacheTime!).inSeconds
          : null,
      'cleanupInterval': cleanupInterval.inSeconds,
      'nextCleanupIn': _lastCacheTime != null
          ? cleanupInterval.inSeconds -
              (DateTime.now().difference(_lastCacheTime!).inSeconds %
                  cleanupInterval.inSeconds)
          : null,
    };
  }

  // Clear cache manually if needed
  void clearCache() {
    _cachedCoffeeData = null;
    _lastCacheTime = null;
    _activeStream = null;
    // Reset cache statistics
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  // Dispose of streams and cache
  void dispose() {
    _cleanupTimer?.cancel();
    clearCache();
  }

  CoffeeData _convertToCoffeeData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dashboard =
        data['latestDataForDashboard'] as Map<String, dynamic>? ?? {};

    // Handle timestamp conversion for mandatory fields
    final DateTime updatedTimestamp = (data['updatedOn'] as Timestamp).toDate();
    final DateTime savedTimestamp = (data['savedOn'] as Timestamp).toDate();

    String getFormattedTimestamp(DateTime timestamp) {
      final String period = timestamp.hour >= 12 ? 'PM' : 'AM';
      final int hour =
          timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final String minute = timestamp.minute.toString().padLeft(2, '0');
      return '${timestamp.day}-${timestamp.month}-${timestamp.year}, $hour:$minute $period';
    }

    return CoffeeData(
      // Mandatory fields that will always have data
      id: doc.id,
      district: data['district'],
      block: data['block'],
      village: data['village'],
      panchayat: data['panchayat'],
      region: data['regionName'],
      regionCategory: data['regionCategory'],
      status: _convertStatusToString(data['surveyStatus']),
      dateUpdated: getFormattedTimestamp(updatedTimestamp),
      dateSaved: getFormattedTimestamp(savedTimestamp),
      polygonCoordinates: List<String>.from(data['polygonPoints'] as List),

      // Optional fields with default values
      area: (data['area'] ?? 0.0).toDouble(),
      perimeter: (data['perimeter'] ?? 0.0).toDouble(),
      mapImageUrl: data['mapImageUrl'] ?? '',
      boundaryImageURLs: data['boundaryImageURLs'] != null
          ? List<String>.from(data['boundaryImageURLs'] as List)
          : [],
      savedBy: data['savedBy'] ?? '',

      // Dashboard fields with default values
      agencyName: dashboard['agencyName'] ?? '',
      averageHeight: (dashboard['averageHeight'] ?? 0.0).toDouble(),
      averageYield: (dashboard['averageYield'] ?? 0.0).toDouble(),
      beneficiaries: dashboard['beneficiaries'] ?? 0,
      khataNumber: dashboard['khataNumber'] ?? '',
      plotNumber: dashboard['plotNumber'] ?? '',
      shadeType: dashboard['shadeType'] ?? '',
      mediaURLs: dashboard['mediaURLs'] != null
          ? List<String>.from(dashboard['mediaURLs'] as List)
          : [],
      survivalPercentage: (dashboard['survivalPercentage'] ?? 0.0).toDouble(),
      plantVarieties: dashboard['plantVarieties'] != null
          ? List<String>.from(dashboard['plantVarieties'] as List)
          : [],
      plantationYear: dashboard['plantationYear'] ?? 0,
    );
  }

  String _convertStatusToString(dynamic status) {
    if (status == null) return 'Pending';
    if (status is bool) {
      return status ? 'Completed' : 'In Progress';
    }
    return status.toString();
  }

  // Delete coffee data with cache update
  Future<void> deleteCoffeeData(String id) async {
    try {
      await ArchiveUtils.archiveDocument(id);
      clearCache();
    } catch (e) {
      throw Exception('Failed to delete coffee data: $e');
    }
  }
}
