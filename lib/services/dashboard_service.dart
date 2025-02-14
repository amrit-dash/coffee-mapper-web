import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/dashboard_metrics_data.dart';
import 'package:logging/logging.dart';

class DashboardService {
  static final _logger = Logger('DashboardService');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardMetricsData? _cachedMetricsData;

  Future<DashboardMetricsData> getDashboardMetrics() async {
    try {
      // Return cached data if available
      if (_cachedMetricsData != null) {
        return _cachedMetricsData!;
      }

      // Fetch data from Firestore
      final doc =
          await _firestore.collection('appData').doc('dashboardData').get();

      if (!doc.exists) {
        _logger.warning(
            'Dashboard metrics document not found, using fallback data');
        return DashboardMetricsData.fallbackData;
      }

      // Parse and cache the data
      _cachedMetricsData = DashboardMetricsData.fromFirestore(doc);
      return _cachedMetricsData!;
    } catch (e, stackTrace) {
      _logger.severe(
        'Error fetching dashboard metrics',
        e,
        stackTrace,
      );
      return DashboardMetricsData.fallbackData;
    }
  }

  // Clear cache when needed (e.g., on logout or manual refresh)
  void clearCache() {
    _cachedMetricsData = null;
  }
}
