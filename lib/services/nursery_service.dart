import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/nursery_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class NurseryService {
  final _logger = Logger('NurseryService');

  // Initialize Firestore with persistence enabled
  final FirebaseFirestore _firestore = FirebaseFirestore.instance
    ..settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  final String _collection = 'coffeeNursery';

  // Cache settings
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration cleanupInterval = Duration(minutes: 1);
  static const int maxCacheItems = 1000; // Maximum number of items to cache
  List<NurseryData>? _cachedNurseryData;
  DateTime? _lastCacheTime;
  Stream<List<NurseryData>>? _activeStream;
  Timer? _cleanupTimer;

  // Cache monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;

  NurseryService() {
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
    if (_lastCacheTime == null || _cachedNurseryData == null) return;

    final age = DateTime.now().difference(_lastCacheTime!);
    if (age >= cacheDuration) {
      _logger.info(
          'Cache cleanup: Clearing expired cache (age: ${age.inSeconds}s)');
      clearCache();
    } else if (_cachedNurseryData!.length > maxCacheItems) {
      _logger.info('Cache cleanup: Trimming cache to size limit');
      _cachedNurseryData = _cachedNurseryData!.sublist(0, maxCacheItems);
    }
  }

  // Get real-time stream of nursery data with caching
  Stream<List<NurseryData>> getNurseryDataStream() {
    _performCacheCleanup();

    if (_activeStream != null) {
      return _activeStream!;
    }

    final query = _firestore
        .collection(_collection)
        .where('status', isNotEqualTo: 'Archived')
        .orderBy('updatedOn', descending: true)
        .limit(maxCacheItems);

    _activeStream = query.snapshots().map((snapshot) {
      final List<NurseryData> data = [];
      for (var doc in snapshot.docs) {
        try {
          final nurseryData = _convertToNurseryData(doc);
          data.add(nurseryData);
        } catch (e) {
          _logger.severe('Failed to convert document ${doc.id}. Error: $e');
          _logger.severe('Document data: ${doc.data()}');
        }
      }

      if (data.length <= maxCacheItems) {
        _cachedNurseryData = data;
        _lastCacheTime = DateTime.now();
      } else {
        _cachedNurseryData = data.sublist(0, maxCacheItems);
        _lastCacheTime = DateTime.now();
        _logger.warning('Cache trimmed to $maxCacheItems items');
      }

      return data;
    });

    return _activeStream!;
  }

  // Get cached data if available and not expired
  List<NurseryData>? getCachedData() {
    _performCacheCleanup();

    if (_cachedNurseryData != null && _lastCacheTime != null) {
      final age = DateTime.now().difference(_lastCacheTime!);
      if (age < cacheDuration) {
        _cacheHits++;
        return _cachedNurseryData;
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
      'currentCacheSize': _cachedNurseryData?.length ?? 0,
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
    _cachedNurseryData = null;
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

  NurseryData _convertToNurseryData(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return NurseryData.fromMap(data, doc.id);
    } catch (e) {
      _logger.severe(
          'Failed to create NurseryData object for ${doc.id}. Error: $e');
      _logger.severe('Full document data: ${doc.data()}');
      rethrow;
    }
  }

  Future<void> deleteNurseryData(String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await _firestore.collection(_collection).doc(id).update({
        'status': 'Archived',
        'updatedOn': FieldValue.serverTimestamp(),
        'updatedBy': currentUser.email ?? 'Unknown User',
      });

      _logger.info(
          'Successfully archived nursery data with ID: $id by user: ${currentUser.email}');
      clearCache();
    } catch (e) {
      _logger.severe('Error archiving nursery data: $e');
      rethrow;
    }
  }
}
