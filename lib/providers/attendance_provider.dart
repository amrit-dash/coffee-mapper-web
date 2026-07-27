import 'dart:async';

import 'package:coffee_mapper_web/models/user_attendance_data.dart';
import 'package:coffee_mapper_web/services/attendance_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AttendanceState {
  final List<UserAttendanceData> data;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DateTime currentMonth;

  AttendanceState({
    this.data = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    required this.currentMonth,
  });

  AttendanceState copyWith({
    List<UserAttendanceData>? data,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DateTime? currentMonth,
  }) {
    return AttendanceState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceService _service;
  StreamSubscription? _subscription;

  AttendanceNotifier(this._service) : super(AttendanceState(currentMonth: DateTime.now()));

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void loadInitialData({DateTime? month}) {
    final targetMonth = month ?? state.currentMonth;
    state = state.copyWith(isLoading: true, error: null, currentMonth: targetMonth);
    
    _subscription?.cancel();
    _subscription = _service.getUsersAttendanceStream(targetMonth).listen(
      (data) {
        state = state.copyWith(
          data: data,
          isLoading: false,
          hasMore: _service.hasMore,
        );
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  void loadMoreData() {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    _service.loadMore();
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
    try {
      await _service.logManualAttendance(
        uid: uid,
        date: date,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        adminUid: adminUid,
        existingCheckInData: existingCheckInData,
        existingCheckOutData: existingCheckOutData,
      );

      final durationInHours = checkOutTime.difference(checkInTime).inMinutes / 60.0;
      final formattedDuration = double.parse(durationInHours.toStringAsFixed(1));
      
      final displayKey = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
      
      final updatedData = state.data.map((user) {
        if (user.uid == uid) {
          final newDurations = Map<String, double?>.from(user.dailyDurations);
          newDurations[displayKey] = formattedDuration;
          
          final newCheckInData = Map<String, Map<String, dynamic>?>.from(user.rawCheckInData);
          newCheckInData[displayKey] = existingCheckInData != null 
              ? Map<String, dynamic>.from(existingCheckInData) 
              : <String, dynamic>{};
          // Not setting time here because it's a Timestamp in firestore but DateTime in Dart, wait, if we read it later we might need Timestamp. But since we just want it to replace the + button, the duration is all that really matters for the UI right now.

          final newCheckOutData = Map<String, Map<String, dynamic>?>.from(user.rawCheckOutData);
          newCheckOutData[displayKey] = existingCheckOutData != null 
              ? Map<String, dynamic>.from(existingCheckOutData) 
              : <String, dynamic>{};
          
          return UserAttendanceData(
            uid: user.uid,
            name: user.name,
            email: user.email,
            lastLogin: user.lastLogin,
            allocatedPanchayats: user.allocatedPanchayats,
            dailyDurations: newDurations,
            rawCheckInData: newCheckInData,
            rawCheckOutData: newCheckOutData,
          );
        }
        return user;
      }).toList();

      state = state.copyWith(data: updatedData);
    } catch (e) {
      state = state.copyWith(error: 'Failed to log attendance: $e');
      throw Exception('Failed to log attendance: $e');
    }
  }
}

final attendanceServiceProvider = Provider((ref) => AttendanceService());

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final service = ref.watch(attendanceServiceProvider);
  return AttendanceNotifier(service);
});