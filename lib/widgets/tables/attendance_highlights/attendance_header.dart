import 'package:coffee_mapper_web/utils/excel_export_utils.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AttendanceHeader extends StatelessWidget {
  final List<List<dynamic>> tableData;
  final List<String> tableHeaders;
  final String reportTitle;

  const AttendanceHeader({
    super.key,
    required this.tableData,
    required this.tableHeaders,
    required this.reportTitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isDesktop = ResponsiveUtils.isDesktop(screenWidth);

    return Container(
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                reportTitle,
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              if (isDesktop) const SizedBox(width: 40),
              if (isDesktop) Expanded(child: _buildExportButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'Download Table Data',
          child: IconButton(
            icon: Icon(
              Icons.downloading_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: isMobile ? 22 : 25,
            ),
            onPressed: () {
              ExcelExportUtils.downloadExcel(
                context: context,
                headers: tableHeaders,
                data: tableData,
                fileName: reportTitle,
                sheetName: 'Attendance',
              );
            },
          ),
        ),
      ],
    );
  }
}