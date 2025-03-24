import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_border_handler.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:coffee_mapper_web/utils/table_scroll_behavior.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/widgets/common/error_boundary.dart';
import 'package:coffee_mapper_web/widgets/common/loading_indicator.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

abstract class BaseDataTable<T> extends StatefulWidget {
  final List<T> data;
  final bool isLoggedIn;
  final Function(T)? onDelete;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const BaseDataTable({
    super.key,
    required this.data,
    this.isLoggedIn = false,
    this.onDelete,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  BaseDataTableState<T> createState();
}

abstract class BaseDataTableState<T> extends State<BaseDataTable<T>> {
  bool _showHeaderBorder = false;
  @protected
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isLoading) {
      return const LoadingIndicator(message: 'Loading data...');
    }

    if (widget.error != null) {
      return ErrorBoundary(
        message: widget.error!,
        onRetry: widget.onRetry,
      );
    }

    if (widget.data.isEmpty) {
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
                columns: buildColumns(context),
                rows: widget.data
                    .map((data) => buildDataRow(context, data))
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

  List<DataColumn2> buildColumns(BuildContext context);
  DataRow buildDataRow(BuildContext context, T data);

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

  Widget buildColumnLabel(BuildContext context, String text) {
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

  DataCell buildDataCell(BuildContext context, String text) {
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

  Widget buildViewButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.viewButtonText(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildStatusCell(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
        backgroundColor = Theme.of(context).colorScheme.primary;
        textColor = Colors.white;
        break;
      case 'archived':
      case 'in progress':
        status = (status == 'Archived') ? 'Inactive' : status;
        backgroundColor = Theme.of(context).colorScheme.tertiary;
        textColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TableConstants.kHorizontalPadding,
          vertical: TableConstants.kVerticalPadding,
        ),
        width: 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(TableConstants.kStatusBorderRadius),
        ),
        child: Text(
          status,
          style: AppTextStyles.statusText(context).copyWith(
              color: textColor, fontFamily: 'Gilroy-SemiBold', fontSize: 11.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell buildDeleteCell(BuildContext context, T data) {
    return DataCell(
      Center(
        child: Tooltip(
          message: 'Delete',
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
                maxHeight: TableConstants.kDeleteButtonMaxHeight),
            icon: const Icon(
              Icons.remove_circle_outline,
              size: TableConstants.kDeleteIconSize,
            ),
            onPressed: () => handleDelete(context, data),
          ),
        ),
      ),
    );
  }

  void handleDelete(BuildContext context, T data);
}
