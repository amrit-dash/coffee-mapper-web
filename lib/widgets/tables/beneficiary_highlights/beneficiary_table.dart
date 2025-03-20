import 'package:coffee_mapper_web/models/farmer_form_data.dart';
import 'package:coffee_mapper_web/services/pdf_service.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_border_handler.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:coffee_mapper_web/utils/table_scroll_behavior.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/widgets/common/error_boundary.dart';
import 'package:coffee_mapper_web/widgets/common/loading_indicator.dart';
import 'package:coffee_mapper_web/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class BeneficiaryTable extends StatefulWidget {
  final List<FarmerFormData> beneficiaryData;
  final bool isLoggedIn;
  final Function(FarmerFormData)? onDelete;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const BeneficiaryTable({
    super.key,
    required this.beneficiaryData,
    this.isLoggedIn = false,
    this.onDelete,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<BeneficiaryTable> createState() => _BeneficiaryTableState();
}

class _BeneficiaryTableState extends State<BeneficiaryTable> {
  bool _showHeaderBorder = false;
  final _pdfService = PdfService();

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

    if (widget.beneficiaryData.isEmpty) {
      return const ErrorBoundary(message: 'No data available');
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final columns = widget.isLoggedIn
        ? TableColumns.beneficiaryAdminColumns
        : TableColumns.beneficiaryColumns;

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
                minWidth: TableConstants.kMinTableWidth + 1000,
                fixedTopRows: 1,
                headingRowHeight: ResponsiveUtils.getRowHeight(
                    screenWidth, TableConstants.kHeaderHeight),
                dataRowHeight: ResponsiveUtils.getRowHeight(
                    screenWidth, TableConstants.kRowHeight),
                headingRowDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                columns: [
                  if (widget.isLoggedIn)
                    DataColumn2(
                      label: _buildColumnLabel(
                          context, TableColumns.deleteColumn.label),
                      size: TableColumns.deleteColumn.size,
                      fixedWidth: ResponsiveUtils.getColumnWidth(
                          screenWidth, TableColumns.deleteColumn.width),
                    ),
                  ...columns.map((col) => DataColumn2(
                        label: _buildColumnLabel(context, col.label),
                        size: col.size,
                        fixedWidth: ResponsiveUtils.getColumnWidth(
                            screenWidth, col.width),
                      )),
                  DataColumn2(
                    label: _buildColumnLabel(
                        context, TableColumns.downloadColumn.label),
                    size: TableColumns.downloadColumn.size,
                    fixedWidth: ResponsiveUtils.getColumnWidth(
                        screenWidth, TableColumns.downloadColumn.width),
                  ),
                ],
                rows: widget.beneficiaryData
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

  DataCell _buildDataCell(BuildContext context, String text, {String? suffix}) {
    return DataCell(
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final availableWidth =
              constraints.maxWidth - (2 * TableConstants.kHorizontalPadding);

          final textSpan = TextSpan(
            text: text + (suffix != null ? ' $suffix' : ''),
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
                text + (suffix != null ? ' $suffix' : ''),
                style: AppTextStyles.tableData(context),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );

          if (isTextTruncated) {
            return Tooltip(
              message: text + (suffix != null ? ' $suffix' : ''),
              child: content,
            );
          }
          return content;
        },
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, FarmerFormData data) {
    final cells = widget.isLoggedIn
        ? _buildAdminCells(context, data)
        : _buildPublicCells(context, data);

    return DataRow(
      cells: [
        if (widget.isLoggedIn)
          DataCell(
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: TableConstants.kDeleteIconSize,
                ),
                onPressed: () => _showDeleteConfirmation(context, data),
                constraints: const BoxConstraints(
                  maxHeight: TableConstants.kDeleteButtonMaxHeight,
                ),
                padding: EdgeInsets.zero,
                tooltip: 'Delete Entry',
              ),
            ),
          ),
        ...cells,
        DataCell(
          Center(
            child: IconButton(
              icon: Icon(
                Icons.download,
                color: Theme.of(context).colorScheme.primary,
                size: TableConstants.kDeleteIconSize,
              ),
              onPressed: () => _handleDownload(context, data),
              constraints: const BoxConstraints(
                maxHeight: TableConstants.kDeleteButtonMaxHeight,
              ),
              padding: EdgeInsets.all(5),
              tooltip: 'Download Application',
            ),
          ),
        ),
      ],
    );
  }

  List<DataCell> _buildPublicCells(BuildContext context, FarmerFormData data) {
    final submittedDate = data.submittedOn != null
        ? '${data.submittedOn!.day}-${data.submittedOn!.month}-${data.submittedOn!.year}'
        : '';
    final columns = TableColumns.beneficiaryColumns;

    return [
      _buildDataCell(context, data.ticketId?.toString() ?? ''),
      _buildDataCell(context, data.name ?? ''),
      _buildDataCell(context, data.careOfName ?? ''),
      _buildDataCell(context, data.village ?? ''),
      _buildDataCell(context, data.post ?? ''),
      _buildDataCell(context, data.policeStation ?? ''),
      _buildDataCell(context, data.landSize?.toString() ?? '',
          suffix: columns[6].suffix),
      _buildDataCell(context, data.landCategory ?? ''),
      _buildDataCell(context, submittedDate),
    ];
  }

  List<DataCell> _buildAdminCells(BuildContext context, FarmerFormData data) {
    final submittedDate = data.submittedOn != null
        ? '${data.submittedOn!.day}-${data.submittedOn!.month}-${data.submittedOn!.year}'
        : '';
    final columns = TableColumns.beneficiaryAdminColumns;

    return [
      _buildDataCell(context, data.ticketId?.toString() ?? ''),
      _buildDataCell(context, data.name ?? ''),
      _buildDataCell(context, data.careOfName ?? ''),
      _buildDataCell(context, data.classType ?? ''),
      _buildDataCell(context, data.village ?? ''),
      _buildDataCell(context, data.post ?? ''),
      _buildDataCell(context, data.policeStation ?? ''),
      _buildDataCell(context, data.mobileNumber ?? ''),
      _buildDataCell(context, data.landSize?.toString() ?? '',
          suffix: columns[8].suffix),
      _buildDataCell(context, data.landCategory ?? ''),
      _buildDataCell(context, data.khataNumber ?? ''),
      _buildDataCell(context, data.plotNumber ?? ''),
      _buildDataCell(context, data.mauja ?? ''),
      _buildDataCell(context, data.aadharNumber ?? ''),
      _buildDataCell(context, data.bankAccountNumber ?? ''),
      _buildDataCell(context, data.bankName ?? ''),
      _buildDataCell(context, data.bankBranch ?? ''),
      _buildDataCell(context, data.bankIFSC ?? ''),
      _buildDataCell(context, submittedDate),
    ];
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, FarmerFormData data) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog<FarmerFormData>(
          data: data,
          onDelete: (data) async {
            if (widget.onDelete != null) {
              await widget.onDelete!(data);
            }
          },
        );
      },
    );
  }

  Future<void> _handleDownload(
      BuildContext context, FarmerFormData data) async {
    try {
      await _pdfService.generateBeneficiaryPdf(data);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
