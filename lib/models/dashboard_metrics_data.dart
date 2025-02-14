import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardMetricsData {
  final double bearingArea;
  final double nonBearingArea;
  final int totalFarmers;
  final String chart1URL;
  final String chart2URL;

  DashboardMetricsData({
    required this.bearingArea,
    required this.nonBearingArea,
    required this.totalFarmers,
    required this.chart1URL,
    required this.chart2URL,
  });

  double get totalArea => bearingArea + nonBearingArea;

  factory DashboardMetricsData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final metricsData = data['metricsData'] as Map<String, dynamic>;
    
    return DashboardMetricsData(
      bearingArea: (metricsData['bearingArea'] as num).toDouble(),
      nonBearingArea: (metricsData['nonBearingArea'] as num).toDouble(),
      totalFarmers: metricsData['totalFarmers'] as int,
      chart1URL: data['chart1URL'] as String,
      chart2URL: data['chart2URL'] as String,
    );
  }

  // Static fallback data
  static DashboardMetricsData get fallbackData => DashboardMetricsData(
    bearingArea: 2988,
    nonBearingArea: 1199.8,
    totalFarmers: 5827,
    chart1URL: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmzXfoTpJ__dBoeS7V533azEHZ3SPsy_ccHsjfUHPSaRcsgOuxGS00M6JBTRMlI9fl_mhxqYBWGseE/pubchart?oid=512820604&format=image',
    chart2URL: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmzXfoTpJ__dBoeS7V533azEHZ3SPsy_ccHsjfUHPSaRcsgOuxGS00M6JBTRMlI9fl_mhxqYBWGseE/pubchart?oid=2011250957&format=image',
  );
} 