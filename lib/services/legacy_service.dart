import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/legacy_data.dart';

class LegacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LegacyData>> getLegacyDataStream() {
    return _firestore
        .collection('legacyApplications')
        .orderBy('status', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LegacyData.fromFirestore(doc)).toList();
    });
  }

  Future<void> deleteLegacyData(String id) async {
    await _firestore.collection('legacyApplications').doc(id).delete();
  }
}
