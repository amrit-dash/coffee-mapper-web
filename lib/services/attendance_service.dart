import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/user_attendance_data.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final BehaviorSubject<int> _limitSubject = BehaviorSubject.seeded(30);
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  bool get hasMore => _hasMore;

  void loadMore() {
    if (_hasMore && !_isLoadingMore) {
      _isLoadingMore = true;
      _limitSubject.add(_limitSubject.value + 30);
    }
  }

  void dispose() {
    _limitSubject.close();
  }

  Stream<List<UserAttendanceData>> getUsersAttendanceStream(DateTime month) {
    return _limitSubject.switchMap((limit) {
      return _firestore
          .collection('users')
          .where('role', isEqualTo: 'USER')
          .where('active', isEqualTo: true)
          .limit(limit)
          .snapshots()
          .switchMap((snapshot) {
        if (snapshot.docs.isEmpty) {
          _isLoadingMore = false;
          _hasMore = false;
          return Stream.value([]);
        }

        _isLoadingMore = false;
        _hasMore = snapshot.docs.length >= limit;

        final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
        final monthStr = month.month.toString().padLeft(2, '0');
        final yearStr = month.year.toString();

        final userStreams = snapshot.docs.map((userDoc) {
          final userData = userDoc.data();
          final uid = userDoc.id;
          final name = userData['name'] ?? 'Unknown';
          final email = userData['email'] ?? 'Unknown';
          final lastLogin = userData['lastLogin'] ?? 'Unknown';
          final allocatedPanchayat = userData['allocatedPanchayat'] ?? 'N/A';

          return _firestore
              .collection('users')
              .doc(uid)
              .collection('attendance')
              .where('dateString', isGreaterThanOrEqualTo: '$yearStr-$monthStr-01')
              .where('dateString', isLessThanOrEqualTo: '$yearStr-$monthStr-$daysInMonth')
              .snapshots()
              .map((attSnapshot) {
            final attendanceData = <String, Map<String, dynamic>>{};
            for (var doc in attSnapshot.docs) {
              attendanceData[doc.id] = doc.data();
            }

            final dailyDurations = <String, double?>{};
            final rawCheckInData = <String, Map<String, dynamic>?>{};
            final rawCheckOutData = <String, Map<String, dynamic>?>{};

            for (int i = 1; i <= daysInMonth; i++) {
              final dayStr = i.toString().padLeft(2, '0');
              final dateKey = '$yearStr-$monthStr-$dayStr';
              final displayKey = '$dayStr-$monthStr';

              if (attendanceData.containsKey(dateKey)) {
                final data = attendanceData[dateKey]!;
                dailyDurations[displayKey] = (data['duration'] as num?)?.toDouble();
                rawCheckInData[displayKey] = data['checkInData'] as Map<String, dynamic>?;
                rawCheckOutData[displayKey] = data['checkOutData'] as Map<String, dynamic>?;
              } else {
                dailyDurations[displayKey] = null;
                rawCheckInData[displayKey] = null;
                rawCheckOutData[displayKey] = null;
              }
            }

            return UserAttendanceData(
              uid: uid,
              name: name,
              email: email,
              lastLogin: lastLogin,
              allocatedPanchayat: allocatedPanchayat,
              dailyDurations: dailyDurations,
              rawCheckInData: rawCheckInData,
              rawCheckOutData: rawCheckOutData,
            );
          });
        });

        return Rx.combineLatestList(userStreams);
      });
    });
  }

  Future<void> logManualAttendance({
    required String uid,
    required DateTime date,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    required String adminUid,
    Map<String, dynamic>? existingCheckInData,
    Map<String, dynamic>? existingCheckOutData,
  }) async {
    final yearStr = date.year.toString();
    final monthStr = date.month.toString().padLeft(2, '0');
    final dayStr = date.day.toString().padLeft(2, '0');
    final dateString = '$yearStr-$monthStr-$dayStr';

    final durationInHours = checkOutTime.difference(checkInTime).inMinutes / 60.0;
    final formattedDuration = double.parse(durationInHours.toStringAsFixed(1));

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .doc(dateString);

    final newCheckInData = existingCheckInData != null 
        ? Map<String, dynamic>.from(existingCheckInData)
        : <String, dynamic>{};
    newCheckInData['time'] = Timestamp.fromDate(checkInTime);

    final newCheckOutData = existingCheckOutData != null 
        ? Map<String, dynamic>.from(existingCheckOutData)
        : <String, dynamic>{};
    newCheckOutData['time'] = Timestamp.fromDate(checkOutTime);

    await docRef.set({
      'dateString': dateString,
      'duration': formattedDuration,
      'markedBy': adminUid,
      'manuallyMarked': true,
      'checkInData': newCheckInData,
      'checkOutData': newCheckOutData,
    }, SetOptions(merge: true));
  }
}