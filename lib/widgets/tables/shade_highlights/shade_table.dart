import 'package:coffee_mapper_web/models/shade_data.dart';
import 'package:coffee_mapper_web/utils/area_formatter.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';
import 'package:coffee_mapper_web/widgets/dialogs/boundary_images/boundary_map_dialog.dart';
import 'package:coffee_mapper_web/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:coffee_mapper_web/widgets/dialogs/media_carousel_dialog/media_carousel_dialog.dart';
import 'package:coffee_mapper_web/widgets/tables/base/base_data_table.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class ShadeTable extends BaseDataTable<ShadeData> {
  const ShadeTable({
    super.key,
    required super.data,
    required super.isLoggedIn,
    super.onDelete,
    super.isLoading = false,
    super.error,
    super.onRetry,
  });

  @override
  ShadeTableState createState() => ShadeTableState();
}

class ShadeTableState extends BaseDataTableState<ShadeData> {
  @override
  List<DataColumn2> buildColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = <DataColumn2>[];

    if (widget.isLoggedIn) {
      columns.add(DataColumn2(
        label: buildColumnLabel(context, TableColumns.deleteColumn.label),
        size: TableColumns.deleteColumn.size,
        fixedWidth: ResponsiveUtils.getColumnWidth(
            screenWidth, TableColumns.deleteColumn.width),
      ));
    }

    columns.addAll(
      TableColumns.shadeColumns.map((columnDef) => DataColumn2(
            label: buildColumnLabel(context, columnDef.label),
            size: columnDef.size,
            fixedWidth:
                ResponsiveUtils.getColumnWidth(screenWidth, columnDef.width),
          )),
    );

    return columns;
  }

  @override
  DataRow buildDataRow(BuildContext context, ShadeData data) {
    final cells = <DataCell>[];

    if (widget.isLoggedIn) {
      cells.add(buildDeleteCell(context, data));
    }

    cells.addAll([
      buildDataCell(context, data.region),
      buildDataCell(context, data.regionCategory),
      buildDataCell(
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
                    style: AppTextStyles.tableData(context),
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
      buildDataCell(
          context, TableConstants.formatNumber(data.plantationYear.toDouble())),
      buildDataCell(context, data.shadeType),
      buildDataCell(context,
          TableConstants.formatNumber(data.averageHeight, suffix: ' ft')),
      buildDataCell(
          context, TableConstants.formatNumber(data.beneficiaries.toDouble())),
      buildDataCell(context,
          TableConstants.formatNumber(data.survivalPercentage, suffix: ' %')),
      buildDataCell(context, data.plotNumber),
      buildDataCell(context, data.khataNumber),
      buildDataCell(context, data.agencyName),
      buildDataCell(context, data.savedBy),
      buildDataCell(context, data.dateUpdated),
      data.mediaURLs.isEmpty
          ? DataCell(Center(
              child: Text('',
                  style: AppTextStyles.viewButtonText(context).copyWith(
                      color: Theme.of(context).scaffoldBackgroundColor))))
          : DataCell(buildViewButton(context, 'View', () {
              MediaCarouselDialog.show(context, data.mediaURLs);
            })),
      data.boundaryImageURLs.isEmpty
          ? DataCell(Center(
              child: Text('-',
                  style: AppTextStyles.viewButtonText(context).copyWith(
                      color: Theme.of(context).scaffoldBackgroundColor))))
          : DataCell(buildViewButton(context, 'View', () {
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

              final markers = data.boundaryImageURLs
                  .map((url) {
                    final uri = Uri.parse(url);
                    final pathSegments = uri.pathSegments;
                    if (pathSegments.isEmpty) return null;

                    final filename = pathSegments.last;
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

  @override
  void handleDelete(BuildContext context, ShadeData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog<ShadeData>(
          data: data,
          onDelete: (data) async {
            setState(() {
              isDeleting = true;
            });

            if (widget.onDelete != null) {
              await widget.onDelete!(data);
            }

            setState(() {
              isDeleting = false;
            });
          },
        );
      },
    );
  }
}
