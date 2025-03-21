import 'package:cloud_firestore/cloud_firestore.dart';

class LegacyData {
  final String id;
  final double area;
  final String block;
  final String careOfName;
  final String name;
  final String panchayat;
  final String status;
  final String village;
  final int year;

  LegacyData({
    required this.id,
    required this.area,
    required this.block,
    required this.careOfName,
    required this.name,
    required this.panchayat,
    required this.status,
    required this.village,
    required this.year,
  });

  factory LegacyData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LegacyData(
      id: doc.id,
      area: data['area'] ?? 0,
      block: data['block'] ?? '',
      careOfName: data['careOfName'] ?? '',
      name: data['name'] ?? '',
      panchayat: data['panchayat'] ?? '',
      status: data['status'] ?? '',
      village: data['village'] ?? '',
      year: data['year'] ?? 0,
    );
  }
}
