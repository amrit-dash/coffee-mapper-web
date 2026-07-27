import 'package:coffee_mapper_web/models/user_attendance_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/widgets/tables/base/base_data_table.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceTable extends BaseDataTable<UserAttendanceData> {
  final DateTime currentMonth;
  final Function(UserAttendanceData, int, DateTime, DateTime,
      Map<String, dynamic>?, Map<String, dynamic>?) onManualAttendance;

  AttendanceTable({
    super.key,
    required super.data,
    required super.isLoggedIn,
    super.onDelete,
    super.isLoading = false,
    super.error,
    super.onRetry,
    super.onLoadMore,
    super.hasMore = false,
    required this.currentMonth,
    required this.onManualAttendance,
  }) : super(
          minWidth: 900 +
              (DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month) *
                  120.0),
        );

  @override
  AttendanceTableState createState() => AttendanceTableState();
}

class AttendanceTableState extends BaseDataTableState<UserAttendanceData> {
  @override
  List<DataColumn2> buildColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final widgetAsAttendanceTable = widget as AttendanceTable;
    final columns = <DataColumn2>[];

    // User Name
    columns.add(DataColumn2(
      label: buildColumnLabel(context, 'User Name'),
      size: ColumnSize.L,
      fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, 200),
    ));

    // User Email
    columns.add(DataColumn2(
      label: buildColumnLabel(context, 'User Email'),
      size: ColumnSize.L,
      fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, 250),
    ));

    // Last Login At
    columns.add(DataColumn2(
      label: buildColumnLabel(context, 'Last Login At'),
      size: ColumnSize.M,
      fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, 180),
    ));

    // Assigned Panchayats
    columns.add(DataColumn2(
      label: buildColumnLabel(context, 'Assigned Panchayats'),
      size: ColumnSize.M,
      fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, 180),
    ));

    final daysInMonth = DateUtils.getDaysInMonth(
        widgetAsAttendanceTable.currentMonth.year,
        widgetAsAttendanceTable.currentMonth.month);

    for (int i = 1; i <= daysInMonth; i++) {
      final dateLabel =
          '${i.toString().padLeft(2, '0')}-${widgetAsAttendanceTable.currentMonth.month.toString().padLeft(2, '0')}';
      columns.add(DataColumn2(
        label: buildColumnLabel(context, dateLabel),
        size: ColumnSize.S,
        fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, 100),
      ));
    }

    return columns;
  }

  String _formatLastLogin(String lastLoginStr) {
    if (lastLoginStr.isEmpty ||
        lastLoginStr.toLowerCase() == 'unknown' ||
        lastLoginStr == 'null') {
      return '-';
    }

    try {
      final cleanStr = lastLoginStr.replaceAll(',', '').replaceAll('/', '-');
      final format = DateFormat('dd-MM-yyyy HH:mm:ss');
      final date = format.parse(cleanStr);

      return DateFormat('hh:mm a, dd-MM-yyyy').format(date);
    } catch (e) {
      return lastLoginStr;
    }
  }

  @override
  DataRow buildDataRow(BuildContext context, UserAttendanceData data) {
    final widgetAsAttendanceTable = widget as AttendanceTable;
    final cells = <DataCell>[];

    cells.addAll([
      buildDataCell(context, data.name),
      buildDataCell(context, data.email),
      buildDataCell(context, _formatLastLogin(data.lastLogin)),
      _buildPanchayatCell(context, data.allocatedPanchayats),
    ]);

    final daysInMonth = DateUtils.getDaysInMonth(
        widgetAsAttendanceTable.currentMonth.year,
        widgetAsAttendanceTable.currentMonth.month);

    for (int i = 1; i <= daysInMonth; i++) {
      final displayKey =
          '${i.toString().padLeft(2, '0')}-${widgetAsAttendanceTable.currentMonth.month.toString().padLeft(2, '0')}';
      final duration = data.dailyDurations[displayKey];

      final columnDate = DateTime(widgetAsAttendanceTable.currentMonth.year,
          widgetAsAttendanceTable.currentMonth.month, i);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (duration != null) {
        cells.add(buildDataCell(context, '$duration hr'));
      } else if (columnDate.isAfter(today)) {
        cells.add(DataCell(
          Center(
            child: Text(
              '-',
              style: AppTextStyles.tableData(context),
            ),
          ),
        ));
      } else {
        cells.add(DataCell(
          Center(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _showManualAttendanceDialog(context, data, i),
                tooltip: 'Mark Manual Attendance',
              ),
            ),
          ),
        ));
      }
    }

    return DataRow(
      cells: cells,
      onSelectChanged: null,
    );
  }

  @override
  void handleDelete(BuildContext context, UserAttendanceData data) {
    // No deletion required for attendance records from this table view.
  }

  DataCell _buildPanchayatCell(
      BuildContext context, List<String> panchayats) {
    if (panchayats.isEmpty) {
      return buildDataCell(context, '-');
    }

    if (panchayats.contains('ALL')) {
      return DataCell(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text(
              'All Panchayats',
              style: AppTextStyles.tableData(context).copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      );
    }

    final primary = Theme.of(context).colorScheme.primary;
    final first = panchayats.first;
    final extraCount = panchayats.length - 1;

    final cellContent = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                first,
                style: AppTextStyles.tableData(context),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (extraCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$extraCount',
                  style: AppTextStyles.tableData(context).copyWith(
                    color: primary,
                    fontFamily: 'Gilroy-SemiBold',
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (extraCount == 0) {
      return DataCell(cellContent);
    }

    return DataCell(
      Tooltip(
        message: panchayats.join('\n'),
        waitDuration: const Duration(milliseconds: 300),
        child: cellContent,
      ),
    );
  }

  void _showManualAttendanceDialog(
      BuildContext context, UserAttendanceData data, int day) {
    final widgetAsAttendanceTable = widget as AttendanceTable;
    final displayKey =
        '${day.toString().padLeft(2, '0')}-${widgetAsAttendanceTable.currentMonth.month.toString().padLeft(2, '0')}';
    final existingCheckIn = data.rawCheckInData[displayKey];
    final existingCheckOut = data.rawCheckOutData[displayKey];

    DateTime? checkInTime;
    if (existingCheckIn != null && existingCheckIn['time'] != null) {
      checkInTime = existingCheckIn['time'].toDate();
    }

    DateTime? checkOutTime;
    if (existingCheckOut != null && existingCheckOut['time'] != null) {
      checkOutTime = existingCheckOut['time'].toDate();
    }

    showDialog(
      context: context,
      builder: (context) => _ManualAttendanceDialog(
          user: data,
          day: day,
          month: widgetAsAttendanceTable.currentMonth,
          existingCheckInTime: checkInTime,
          existingCheckOutTime: checkOutTime,
          existingCheckInData: existingCheckIn,
          existingCheckOutData: existingCheckOut,
          onSave: (checkIn, checkOut) {
            return widgetAsAttendanceTable.onManualAttendance(data, day,
                checkIn, checkOut, existingCheckIn, existingCheckOut);
          }),
    );
  }
}

class _ManualAttendanceDialog extends StatefulWidget {
  final UserAttendanceData user;
  final int day;
  final DateTime month;
  final DateTime? existingCheckInTime;
  final DateTime? existingCheckOutTime;
  final Map<String, dynamic>? existingCheckInData;
  final Map<String, dynamic>? existingCheckOutData;
  final Future<void> Function(DateTime, DateTime) onSave;

  const _ManualAttendanceDialog({
    required this.user,
    required this.day,
    required this.month,
    this.existingCheckInTime,
    this.existingCheckOutTime,
    this.existingCheckInData,
    this.existingCheckOutData,
    required this.onSave,
  });

  @override
  State<_ManualAttendanceDialog> createState() =>
      _ManualAttendanceDialogState();
}

class _ManualAttendanceDialogState extends State<_ManualAttendanceDialog> {
  late DateTime? _checkInTime;
  late DateTime? _checkOutTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInTime = widget.existingCheckInTime;
    _checkOutTime = widget.existingCheckOutTime;
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    if (isCheckIn && widget.existingCheckInTime != null) {
      return;
    }

    final initialTime = TimeOfDay.fromDateTime(
      isCheckIn
          ? (_checkInTime ??
              DateTime(widget.month.year, widget.month.month, widget.day, 9, 0))
          : (_checkOutTime ??
              DateTime(
                  widget.month.year, widget.month.month, widget.day, 17, 0)),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        final primary = Theme.of(context).colorScheme.primary; 
        final secondary = Theme.of(context).colorScheme.secondary;
        final cardColor = Theme.of(context).cardColor; 
        final highlight = Theme.of(context).highlightColor;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: secondary,
              surfaceContainerHighest: primary.withValues(alpha: 0.05),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: cardColor,
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary.withValues(alpha: 0.15);
                }
                return primary.withValues(alpha: 0.05);
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary;
                }
                return secondary;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary;
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return secondary;
              }),
              dayPeriodBorderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
              dialBackgroundColor: primary.withValues(alpha: 0.05),
              dialHandColor: primary,
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return secondary;
              }),
              entryModeIconColor: secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: secondary.withValues(alpha: 0.7),
                textStyle: const TextStyle(fontFamily: 'Gilroy-Medium', fontSize: 15),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: highlight,
                textStyle: const TextStyle(fontFamily: 'Gilroy-SemiBold', fontSize: 15),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final newDateTime = DateTime(
          widget.month.year,
          widget.month.month,
          widget.day,
          picked.hour,
          picked.minute,
        );
        if (isCheckIn) {
          _checkInTime = newDateTime;
        } else {
          _checkOutTime = newDateTime;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_checkInTime == null || _checkOutTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).cardColor),
              const SizedBox(width: 8),
              const Text('Please select both Check-In and Check-Out times.'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_checkOutTime!.isBefore(_checkInTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).cardColor),
              const SizedBox(width: 8),
              const Text('Check-Out time cannot be before Check-In time.'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(_checkInTime!, _checkOutTime!);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Theme.of(context).cardColor),
                const SizedBox(width: 8),
                const Text('Attendance updated successfully'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).cardColor),
                const SizedBox(width: 8),
                const Text('Failed to save attendance. Please try again.'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 4,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontFamily: 'Gilroy-SemiBold',
                    color: Theme.of(context).highlightColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24, color: Theme.of(context).colorScheme.secondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'User : ',
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Theme.of(context).highlightColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.user.name,
                  style: TextStyle(
                    fontFamily: 'Gilroy-SemiBold',
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Date : ',
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    color: Theme.of(context).highlightColor,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${widget.day.toString().padLeft(2, '0')}-${widget.month.month.toString().padLeft(2, '0')}-${widget.month.year}',
                  style: TextStyle(
                    fontFamily: 'Gilroy-SemiBold',
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildCompactTimeSelector(
                    context: context,
                    title: 'Check In',
                    time: _checkInTime,
                    isLocked: widget.existingCheckInTime != null,
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactTimeSelector(
                    context: context,
                    title: 'Check Out',
                    time: _checkOutTime,
                    isLocked: false,
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).cardColor,
                        ),
                      )
                    : const Text(
                        'Confirm Attendance',
                        style: TextStyle(
                          fontFamily: 'Gilroy-SemiBold',
                          fontSize: 16,
                          letterSpacing: 0.9,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTimeSelector({
    required BuildContext context,
    required String title,
    required DateTime? time,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('hh:mm a');
    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: isLocked ? 0.05 : 0.0),
          border: Border.all(
            color: Theme.of(context).highlightColor.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: 13,
                    color: Theme.of(context).highlightColor.withValues(alpha: 0.8),
                  ),
                ),
                Icon(
                  isLocked ? Icons.lock_outline : Icons.access_time,
                  size: 16,
                  color: Theme.of(context).highlightColor.withValues(alpha: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              time != null ? dateFormat.format(time) : '--:--',
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
