import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:coffee_mapper_web/models/nursery_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:coffee_mapper_web/utils/table_scroll_behavior.dart';
import 'package:coffee_mapper_web/utils/table_border_handler.dart';
import 'package:coffee_mapper_web/widgets/common/error_boundary.dart';
import 'package:coffee_mapper_web/widgets/common/loading_indicator.dart';

class NurseryTable extends StatefulWidget {
  final List<NurseryData> nurseryData;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const NurseryTable({
    super.key,
    required this.nurseryData,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<NurseryTable> createState() => _NurseryTableState();
}

class _NurseryTableState extends State<NurseryTable> {
  bool _showHeaderBorder = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const LoadingIndicator(message: 'Loading data...');
    }

    if (widget.error != null) {
      return ErrorBoundary(
        message: widget.error!,
        onRetry: widget.onRetry,
      );
    }

    if (widget.nurseryData.isEmpty) {
      return const ErrorBoundary(message: 'No data available');
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ScrollConfiguration(
              behavior: const TableScrollBehavior(),
              child: DataTable2(
                columnSpacing: TableConstants.kColumnSpacing,
                horizontalMargin: TableConstants.kHorizontalMargin,
                border: TableBorderHandler.getTableBorder(),
                minWidth: TableConstants.kMinTableWidth,
                fixedTopRows: 1,
                headingRowHeight: ResponsiveUtils.getRowHeight(
                    screenWidth, TableConstants.kHeaderHeight),
                dataRowHeight: ResponsiveUtils.getRowHeight(
                    screenWidth, TableConstants.kRowHeight),
                headingRowDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                columns: [
                  _buildColumn('Nursery\nDistrict'),
                  _buildColumn('Nursery\nBlock'),
                  _buildColumn('Nursery\nGram Panchayat'),
                  _buildColumn('Nursery\nVillage'),
                  _buildColumn('SHG / SC\nRange Name'),
                  _buildColumn('Seedlings\nRaised'),
                  _buildColumn('Coffee\nVariety'),
                  _buildColumn('Seeds\nQuantity'),
                  _buildColumn('Sowing\nDate'),
                  _buildColumn('Transplanting\nDate'),
                  _buildColumn('First\nPair Leaves'),
                  _buildColumn('Second\nPair Leaves'),
                  _buildColumn('Third\nPair Leaves'),
                  _buildColumn('Fourth\nPair Leaves'),
                  _buildColumn('Fifth\nPair Leaves'),
                  _buildColumn('Sixth\nPair Leaves'),
                ],
                rows: widget.nurseryData
                    .map((data) => _buildDataRow(context, data))
                    .toList(),
              ),
            ),
          ),
          if (_showHeaderBorder)
            TableBorderHandler.buildHeaderBorder(
              ResponsiveUtils.getRowHeight(
                  screenWidth, TableConstants.kHeaderHeight),
            ),
          TableBorderHandler.buildHeaderShadow(
            context,
            ResponsiveUtils.getRowHeight(
                screenWidth, TableConstants.kHeaderHeight - 1),
          ),
        ],
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final isVerticalScroll =
          notification.metrics.axisDirection == AxisDirection.down ||
              notification.metrics.axisDirection == AxisDirection.up;

      if (isVerticalScroll) {
        final showBorder = notification.metrics.pixels > 0;
        if (showBorder != _showHeaderBorder) {
          setState(() => _showHeaderBorder = showBorder);
        }
      }
    }
    return true;
  }

  DataColumn2 _buildColumn(String label) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define custom widths for specific columns
    double columnWidth = 150.0; // default width

    switch (label) {
      case 'Nursery\nDistrict':
      case 'Nursery\nBlock':
        columnWidth = 120.0;
        break;
      case 'Nursery\nGram Panchayat':
      case 'Nursery\nVillage':
        columnWidth = 150.0;
        break;
      case 'SHG / SC\nRange Name':
        columnWidth = 200.0;
        break;
      case 'Seedlings\nRaised':
      case 'Seeds\nQuantity':
        columnWidth = 80.0;
        break;
      case 'Coffee\nVariety':
        columnWidth = 180.0;
        break;
      case 'Sowing\nDate':
      case 'Transplanting\nDate':
        columnWidth = 130.0;
        break;
      case 'First\nPair Leaves':
      case 'Second\nPair Leaves':
      case 'Third\nPair Leaves':
      case 'Fourth\nPair Leaves':
      case 'Fifth\nPair Leaves':
      case 'Sixth\nPair Leaves':
        columnWidth = 110.0;
        break;
    }

    return DataColumn2(
      label: _buildColumnLabel(context, label),
      size: ColumnSize.M,
      fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, columnWidth),
    );
  }

  Widget _buildColumnLabel(BuildContext context, String text) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TableConstants.kHorizontalPadding,
                vertical: TableConstants.kVerticalPadding,
              ),
              child: Text(
                text,
                style: AppTextStyles.tableHeader(context),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableBorderHandler.buildHeaderVerticalDivider(context),
      ],
    );
  }

  DataCell _buildDataCell(BuildContext context, String text) {
    return DataCell(
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final availableWidth =
              constraints.maxWidth - (2 * TableConstants.kHorizontalPadding);

          final textSpan = TextSpan(
            text: text,
            style: AppTextStyles.tableData(context),
          );

          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
            maxLines: 1,
          );

          textPainter.layout(maxWidth: double.infinity);
          final bool isTextTruncated = textPainter.width > availableWidth - 10;

          Widget content = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TableConstants.kHorizontalPadding,
                vertical: TableConstants.kVerticalPadding,
              ),
              child: Text(
                text,
                style: AppTextStyles.tableData(context),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );

          if (isTextTruncated) {
            return Tooltip(
              message: text,
              child: content,
            );
          }
          return content;
        },
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, NurseryData data) {
    return DataRow(
      cells: [
        _buildDataCell(context, data.district),
        _buildDataCell(context, data.block),
        _buildDataCell(context, data.panchayat),
        _buildDataCell(context, data.village),
        _buildDataCell(context, data.rangeName),
        _buildDataCell(context, data.seedlingsQuantity.toString()),
        _buildDataCell(context, data.coffeeVariety),
        _buildDataCell(context, data.seedsQuantity.toString()),
        _buildDataCell(context, data.sowingDate),
        _buildDataCell(context, data.transplantingDate),
        _buildDataCell(context, data.leafPair1),
        _buildDataCell(context, data.leafPair2),
        _buildDataCell(context, data.leafPair3),
        _buildDataCell(context, data.leafPair4),
        _buildDataCell(context, data.leafPair5),
        _buildDataCell(context, data.leafPair6),
      ],
      onSelectChanged: null,
    );
  }
}
