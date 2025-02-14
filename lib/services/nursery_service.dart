import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/nursery_data.dart';

class NurseryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NurseryData>> getNurseryDataStream() {
    return _firestore
        .collection('nurseryDetails')
        .where('status', isEqualTo: 'Active')  // Only fetch active records
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NurseryData.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
} 