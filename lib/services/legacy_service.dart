import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/legacy_data.dart';
import 'package:rxdart/rxdart.dart';

class LegacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final BehaviorSubject<int> _limitSubject = BehaviorSubject.seeded(15);
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  void loadMore() {
    if (_hasMore && !_isLoadingMore) {
      _isLoadingMore = true;
      _limitSubject.add(_limitSubject.value + 15);
    }
  }

  Stream<List<LegacyData>> getLegacyDataStream() {
    return _limitSubject.switchMap((limit) {
      return _firestore
          .collection('legacyApplications')
          .orderBy('status', descending: false)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        _isLoadingMore = false;
        if (snapshot.docs.length < limit) {
          _hasMore = false;
        } else {
          _hasMore = true;
        }
        return snapshot.docs.map((doc) => LegacyData.fromFirestore(doc)).toList();
      });
    });
  }
  
  void dispose() {
    _limitSubject.close();
  }

  Future<void> deleteLegacyData(String id) async {
    await _firestore.collection('legacyApplications').doc(id).delete();
  }
}
