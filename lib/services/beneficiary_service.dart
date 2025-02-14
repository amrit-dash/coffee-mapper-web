import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/farmer_form_data.dart';
import 'package:coffee_mapper_web/utils/archive_utils.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';

class BeneficiaryService {
  static final BeneficiaryService instance = BeneficiaryService._();

  BeneficiaryService._();

  final _log = Logger('BeneficiaryService');

  // Initialize Firestore with persistence enabled
  final FirebaseFirestore _firestore = FirebaseFirestore.instance
    ..settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

  // Cache settings
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration cleanupInterval = Duration(minutes: 1);
  static const int maxCacheItems = 1000;
  final Map<String, List<FarmerFormData>> _cache = {};
  List<FarmerFormData>? _cachedData;
  DateTime? _lastCacheTime;
  final BehaviorSubject<List<FarmerFormData>> _dataSubject =
      BehaviorSubject<List<FarmerFormData>>.seeded([]);
  Timer? _cleanupTimer;

  // Cache monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;

  BeneficiaryService() {
    _startCleanupTimer();
    _initializeDataStream();
  }

  void _initializeDataStream() {
    final query = _firestore
        .collection('farmerApplications')
        .where('status', isEqualTo: 'active')
        .orderBy('submittedOn', descending: true)
        .limit(maxCacheItems);

    // Listen to query snapshots and handle updates
    query.snapshots().listen(
      (snapshot) {
        if (_dataSubject.isClosed) return; // Early return if stream is closed

        try {
          final List<FarmerFormData> data = snapshot.docs
              .map((doc) {
                try {
                  final Map<String, dynamic> docData = doc.data();
                  // Convert submittedOn to DateTime, handling both Timestamp and String formats
                  DateTime submittedOn;
                  if (docData['submittedOn'] is Timestamp) {
                    submittedOn =
                        (docData['submittedOn'] as Timestamp).toDate();
                  } else if (docData['submittedOn'] is String) {
                    submittedOn = DateTime.parse(docData['submittedOn']);
                  } else {
                    submittedOn = DateTime.now();
                  }

                  return FarmerFormData.fromJson({
                    ...docData,
                    'id': doc.id,
                    'district': docData['district'] ?? '',
                    'block': docData['block'] ?? '',
                    'panchayat': docData['panchayat'] ?? '',
                    'village': docData['village'] ?? '',
                    'status': docData['status'] ?? 'active',
                    'submittedOn': Timestamp.fromDate(submittedOn),
                  });
                } catch (e) {
                  _log.warning('Error parsing document ${doc.id}: $e');
                  return null;
                }
              })
              .where((data) => data != null)
              .cast<FarmerFormData>()
              .toList();

          // Update cache in a safe manner
          _cachedData = List<FarmerFormData>.unmodifiable(data);
          _lastCacheTime = DateTime.now();

          // Only emit if there are changes and stream is still active
          if (!_dataSubject.isClosed &&
              (!_dataSubject.hasValue ||
                  !listEquals(_dataSubject.value, data))) {
            _dataSubject.add(List<FarmerFormData>.unmodifiable(data));
          }
        } catch (e) {
          _log.severe('Error processing snapshot: $e');
          // Don't emit error if we have cached data
          if (_cachedData == null || _cachedData!.isEmpty) {
            _dataSubject.addError(e);
          }
        }
      },
      onError: (error) {
        _log.severe('Error in beneficiary data stream: $error');
        // Don't emit error if we have cached data
        if (_cachedData == null || _cachedData!.isEmpty) {
          _dataSubject.addError(error);
        }
      },
      cancelOnError: false, // Don't cancel stream on error
    );
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer =
        Timer.periodic(cleanupInterval, (_) => _performCacheCleanup());
  }

  void _performCacheCleanup() {
    if (_lastCacheTime == null || _cachedData == null) return;

    final age = DateTime.now().difference(_lastCacheTime!);
    if (age >= cacheDuration) {
      _log.info(
          'Cache cleanup: Clearing expired cache (age: ${age.inSeconds}s)');
      clearCache();
    } else if (_cachedData!.length > maxCacheItems) {
      _log.info('Cache cleanup: Trimming cache to size limit');
      _cachedData = _cachedData!.sublist(0, maxCacheItems);
    }
  }

  Stream<List<FarmerFormData>> getBeneficiaryDataStream() {
    return _dataSubject.stream
        .map((list) => List<FarmerFormData>.unmodifiable(list));
  }

  Future<List<FarmerFormData>> getBeneficiaries({
    String? district,
    String? block,
    String? panchayat,
    String? village,
  }) async {
    final cacheKey = _generateCacheKey(district, block, panchayat, village);
    if (_cache.containsKey(cacheKey)) {
      _cacheHits++;
      return _cache[cacheKey]!;
    }
    _cacheMisses++;

    Query query = _firestore
        .collection('farmerApplications')
        .where('status', isEqualTo: 'active')
        .orderBy('submittedOn', descending: true);

    if (district != null) {
      query = query.where('district', isEqualTo: district);
    }
    if (block != null) {
      query = query.where('block', isEqualTo: block);
    }
    if (panchayat != null) {
      query = query.where('panchayat', isEqualTo: panchayat);
    }
    if (village != null) {
      query = query.where('village', isEqualTo: village);
    }

    try {
      final snapshot = await query.get();
      final beneficiaries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FarmerFormData.fromJson({
          ...data,
          'id': doc.id,
          'district': data['district'] ?? '',
          'block': data['block'] ?? '',
          'panchayat': data['panchayat'] ?? '',
          'village': data['village'] ?? '',
          'status': data['status'] ?? 'active',
          'submittedOn': data['submittedOn'] is Timestamp
              ? data['submittedOn']
              : data['submittedOn'] is String
                  ? Timestamp.fromDate(DateTime.parse(data['submittedOn']))
                  : Timestamp.fromDate(DateTime.now()),
        });
      }).toList();

      _cache[cacheKey] = beneficiaries;
      return beneficiaries;
    } catch (e) {
      _log.severe('Error fetching beneficiaries: $e');
      // Return empty list instead of throwing
      return [];
    }
  }

  Future<void> deleteBeneficiary(FarmerFormData data) async {
    if (data.id == null) return;

    try {
      // Use ArchiveUtils to archive the beneficiary
      await ArchiveUtils.archiveBeneficiary(data);

      // Update local cache safely
      if (_cachedData != null) {
        _cachedData = List<FarmerFormData>.from(_cachedData!)
          ..removeWhere((item) => item.id == data.id);

        if (!_dataSubject.isClosed) {
          _dataSubject.add(_cachedData!);
        }
      }
      _clearCache();
    } catch (e) {
      _log.severe('Error archiving beneficiary: $e');
      rethrow;
    }
  }

  String _generateCacheKey(
      String? district, String? block, String? panchayat, String? village) {
    return '$district:$block:$panchayat:$village';
  }

  void _clearCache() {
    _cache.clear();
    clearCache();
  }

  void clearCache() {
    _cachedData = null;
    _lastCacheTime = null;
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  Map<String, dynamic> getCacheStats() {
    return {
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': _cacheHits + _cacheMisses == 0
          ? 0
          : _cacheHits / (_cacheHits + _cacheMisses),
      'currentCacheSize': _cachedData?.length ?? 0,
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

  void dispose() {
    _cleanupTimer?.cancel();
    _dataSubject.close();
    clearCache();
  }
}
