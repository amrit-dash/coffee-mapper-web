import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:coffee_mapper_web/models/coffee_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/utils/table_scroll_behavior.dart';
import 'package:coffee_mapper_web/utils/table_border_handler.dart';
import 'package:coffee_mapper_web/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:coffee_mapper_web/widgets/common/error_boundary.dart';
import 'package:coffee_mapper_web/widgets/common/loading_indicator.dart';
import 'package:coffee_mapper_web/widgets/dialogs/media_carousel_dialog/media_carousel_dialog.dart';
import 'package:coffee_mapper_web/widgets/dialogs/boundary_images/boundary_map_dialog.dart';
import 'package:coffee_mapper_web/utils/area_formatter.dart';

class CoffeeTable extends StatefulWidget {
  final List<CoffeeData> coffeeData;
  final bool isLoggedIn;
  final Function(CoffeeData)? onDelete;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const CoffeeTable({
    super.key,
    required this.coffeeData,
    this.isLoggedIn = false,
    this.onDelete,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  State<CoffeeTable> createState() => _CoffeeTableState();
}

class _CoffeeTableState extends State<CoffeeTable> {
  bool _showHeaderBorder = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (_isDeleting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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

    if (widget.coffeeData.isEmpty) {
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
                  if (widget.isLoggedIn)
                    DataColumn2(
                      label: _buildColumnLabel(
                          context, TableColumns.deleteColumn.label),
                      size: TableColumns.deleteColumn.size,
                      fixedWidth: ResponsiveUtils.getColumnWidth(
                          screenWidth, TableColumns.deleteColumn.width),
                    ),
                  ...TableColumns.coffeeColumns.map((def) => DataColumn2(
                        label: _buildColumnLabel(context, def.label),
                        size: def.size,
                        fixedWidth: ResponsiveUtils.getColumnWidth(
                            screenWidth, def.width),
                      )),
                ],
                rows: widget.coffeeData
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

  // Optimized text styles
  TextStyle _getDataTextStyle(BuildContext context) {
    return AppTextStyles.tableData(context);
  }

  TextStyle _getHeaderTextStyle(BuildContext context) {
    return AppTextStyles.tableHeader(context);
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
                style: _getHeaderTextStyle(context),
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

          // Create a TextPainter to measure the text
          final textSpan = TextSpan(
            text: text,
            style: _getDataTextStyle(context),
          );

          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
            maxLines: 1,
          );

          // Layout with the available width
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
                style: _getDataTextStyle(context),
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

  Widget _buildStatusCell(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Theme.of(context).colorScheme.primary;
        textColor = Colors.white;
        break;
      case 'in progress':
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
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(TableConstants.kStatusBorderRadius),
        ),
        child: Text(
          status,
          style: AppTextStyles.statusText(context).copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildViewButton(
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

  DataRow _buildDataRow(BuildContext context, CoffeeData data) {
    List<DataCell> cells = [];

    // Add delete button if logged in
    if (widget.isLoggedIn) {
      cells.add(DataCell(
        Center(
          child: Tooltip(
            message: 'Delete Coffee',
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                  maxHeight: TableConstants.kDeleteButtonMaxHeight),
              icon: const Icon(
                Icons.remove_circle_outline,
                size: TableConstants.kDeleteIconSize,
              ),
              onPressed: () => _showDeleteDialog(context, data),
            ),
          ),
        ),
      ));
    }

    // Add data cells based on column definitions
    cells.addAll([
      _buildDataCell(context, data.region),
      _buildDataCell(context, data.regionCategory),
      _buildDataCell(
          context, TableConstants.formatNumber(data.perimeter, suffix: ' m')),
      DataCell(
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final formattedArea = AreaFormatter.formatArea(data.area);
            final tooltip = AreaFormatter.getAreaTooltip(data.area);

            return Tooltip(
              message: tooltip,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TableConstants.kHorizontalPadding,
                    vertical: TableConstants.kVerticalPadding,
                  ),
                  child: Text(
                    formattedArea,
                    style: _getDataTextStyle(context),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      _buildDataCell(context, data.shadeType),
      _buildDataCell(
          context, TableConstants.formatNumber(data.plantationYear.toDouble())),
      _buildDataCell(context, data.plantVarieties.join(', ')),
      _buildDataCell(context,
          TableConstants.formatNumber(data.averageHeight, suffix: ' ft')),
      _buildDataCell(context,
          TableConstants.formatNumber(data.averageYield, suffix: ' kg/ha')),
      _buildDataCell(
          context, TableConstants.formatNumber(data.beneficiaries.toDouble())),
      _buildDataCell(context,
          TableConstants.formatNumber(data.survivalPercentage, suffix: ' %')),
      _buildDataCell(context, data.plotNumber),
      _buildDataCell(context, data.khataNumber),
      _buildDataCell(context, data.agencyName),
      _buildDataCell(context, data.savedBy),
      _buildDataCell(context, data.dateUpdated),
      data.mediaURLs.isEmpty
          ? DataCell(
              Center(
                child: Text(
                  '',
                  style: AppTextStyles.viewButtonText(context).copyWith(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            )
          : DataCell(_buildViewButton(context, 'View', () {
              MediaCarouselDialog.show(context, data.mediaURLs);
            })),
      data.boundaryImageURLs.isEmpty
          ? DataCell(
              Center(
                child: Text(
                  '-',
                  style: AppTextStyles.viewButtonText(context).copyWith(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            )
          : DataCell(_buildViewButton(context, 'View', () {
              // Extract polygon coordinates for the boundary
              final polygonCoordinates = data.polygonCoordinates
                  .map((coord) {
                    final parts = coord.split(',');
                    if (parts.length == 2) {
                      final lat = double.tryParse(parts[0]);
                      final lng = double.tryParse(parts[1]);
                      if (lat != null && lng != null) {
                        return gmap.LatLng(lat, lng);
                      }
                    }
                    return null;
                  })
                  .whereType<gmap.LatLng>()
                  .toList();

              // Extract coordinates from image URLs for markers
              final markers = data.boundaryImageURLs
                  .map((url) {
                    // Extract filename from the URL
                    final uri = Uri.parse(url);
                    final pathSegments = uri.pathSegments;
                    if (pathSegments.isEmpty) return null;

                    // Get the filename (last segment)
                    final filename = pathSegments.last;

                    // Extract coordinates part (remove extension and token)
                    final coordPart =
                        filename.split('/').last.split('.jpg').first;
                    final coords = coordPart.split('_');

                    if (coords.length == 2) {
                      final lat = double.tryParse(coords[0]);
                      final lng = double.tryParse(coords[1]);
                      if (lat != null && lng != null) {
                        return MarkerData(
                          imageUrl: url,
                          position: gmap.LatLng(lat, lng),
                        );
                      }
                    }
                    return null;
                  })
                  .whereType<MarkerData>()
                  .toList();

              if (markers.isNotEmpty) {
                BoundaryMapDialog.show(
                  context,
                  markers: markers,
                  polygonPoints: polygonCoordinates,
                );
              }
            })),
      DataCell(_buildStatusCell(context, data.status)),
    ]);

    return DataRow(
      cells: cells,
      onSelectChanged: null,
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, CoffeeData data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog<CoffeeData>(
          data: data,
          onDelete: (data) async {
            setState(() {
              _isDeleting = true;
            });

            if (widget.onDelete != null) {
              await widget.onDelete!(data);
            }

            setState(() {
              _isDeleting = false;
            });
          },
        );
      },
    );
  }
}
