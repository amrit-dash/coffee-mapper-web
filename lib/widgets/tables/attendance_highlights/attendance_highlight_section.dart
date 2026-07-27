import 'package:coffee_mapper_web/providers/attendance_provider.dart';
import 'package:coffee_mapper_web/widgets/tables/attendance_highlights/attendance_header.dart';
import 'package:coffee_mapper_web/widgets/tables/attendance_highlights/attendance_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceHighlightSection extends ConsumerStatefulWidget {
  const AttendanceHighlightSection({super.key});

  @override
  ConsumerState<AttendanceHighlightSection> createState() =>
      _AttendanceHighlightSectionState();
}

class _AttendanceHighlightSectionState
    extends ConsumerState<AttendanceHighlightSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(attendanceProvider.notifier).loadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    final daysInMonth = DateUtils.getDaysInMonth(
        state.currentMonth.year, state.currentMonth.month);

    final monthName = DateFormat('MMMM').format(state.currentMonth);
    final yearStr = state.currentMonth.year.toString();
    final reportTitle = 'User Attendance Report - $monthName, $yearStr';

    final tableHeaders = ['User Name', 'User Email', 'Last Login At', 'Assigned Panchayats'];
    for (int i = 1; i <= daysInMonth; i++) {
      tableHeaders.add(
          '${i.toString().padLeft(2, '0')}-${state.currentMonth.month.toString().padLeft(2, '0')}');
    }

    final tableData = state.data.map((user) {
      final panchayats = user.allocatedPanchayats;
      final panchayatExport = panchayats.isEmpty
          ? '-'
          : (panchayats.contains('ALL') ? 'All Panchayats' : panchayats.join(', '));
      final row = [user.name, user.email, user.lastLogin, panchayatExport];
      for (int i = 1; i <= daysInMonth; i++) {
        final displayKey =
            '${i.toString().padLeft(2, '0')}-${state.currentMonth.month.toString().padLeft(2, '0')}';
        final duration = user.dailyDurations[displayKey];
        row.add(duration != null ? '$duration hr' : '-');
      }
      return row;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          AttendanceHeader(
            tableData: tableData,
            tableHeaders: tableHeaders,
            reportTitle: reportTitle,
          ),
          Expanded(
            child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(35, 0, 0, 0), // ~0.1 opacity
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: Color.fromARGB(35, 0, 0, 0), // ~0.1 opacity
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, authSnapshot) {
                  final isLoggedIn = authSnapshot.hasData;
                  return AttendanceTable(
                    data: state.data,
                    isLoggedIn: isLoggedIn,
                    isLoading: state.isLoading && state.data.isEmpty,
                    error: state.error,
                    onRetry: () =>
                        ref.read(attendanceProvider.notifier).loadInitialData(),
                    hasMore: state.hasMore,
                    onLoadMore: () =>
                        ref.read(attendanceProvider.notifier).loadMoreData(),
                    currentMonth: state.currentMonth,
                    onManualAttendance: (user, day, checkIn, checkOut, existingCheckIn, existingCheckOut) async {
                      final targetDate = DateTime(state.currentMonth.year, state.currentMonth.month, day);
                      final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
                      await ref.read(attendanceProvider.notifier).logManualAttendance(
                        uid: user.uid,
                        date: targetDate,
                        checkInTime: checkIn,
                        checkOutTime: checkOut,
                        adminUid: adminUid,
                        existingCheckInData: existingCheckIn,
                        existingCheckOutData: existingCheckOut,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
  }
}