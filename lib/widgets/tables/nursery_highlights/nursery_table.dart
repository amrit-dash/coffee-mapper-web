import 'package:coffee_mapper_web/models/nursery_data.dart';
import 'package:coffee_mapper_web/utils/area_formatter.dart';
import 'package:coffee_mapper_web/utils/coordinate_extractor.dart';
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

class NurseryTable extends BaseDataTable<NurseryData> {
  const NurseryTable({
    super.key,
    required super.data,
    required super.isLoggedIn,
    super.onDelete,
    super.isLoading = false,
    super.error,
    super.onRetry,
  });

  @override
  NurseryTableState createState() => NurseryTableState();
}

class NurseryTableState extends BaseDataTableState<NurseryData> {
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
      TableColumns.nurseryColumns.map((columnDef) => DataColumn2(
            label: buildColumnLabel(context, columnDef.label),
            size: columnDef.size,
            fixedWidth:
                ResponsiveUtils.getColumnWidth(screenWidth, columnDef.width),
          )),
    );

    return columns;
  }

  @override
  DataRow buildDataRow(BuildContext context, NurseryData data) {
    final cells = <DataCell>[];

    if (widget.isLoggedIn) {
      cells.add(buildDeleteCell(context, data));
    }

    cells.addAll([
      buildDataCell(context, data.regionName),
      buildDataCell(context, data.block),
      buildDataCell(context, data.panchayat),
      buildDataCell(context, data.village),
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
      buildDataCell(context, data.coffeeVariety ?? '-'),
      buildDataCell(context, data.seedsQuantity?.toString() ?? '-'),
      buildDataCell(context, data.seedlingsRaised?.toString() ?? '-'),
      buildDataCell(context, data.sowingDate ?? '-'),
      buildDataCell(context, data.transplantingDate ?? '-'),
      buildDataCell(context, data.firstPairLeaves ?? '-'),
      buildDataCell(context, data.secondPairLeaves ?? '-'),
      buildDataCell(context, data.thirdPairLeaves ?? '-'),
      buildDataCell(context, data.fourthPairLeaves ?? '-'),
      buildDataCell(context, data.fifthPairLeaves ?? '-'),
      buildDataCell(context, data.sixthPairLeaves ?? '-'),
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

              final markers = CoordinateExtractor.extractMarkersFromUrls(
                  data.boundaryImageURLs);

              if (markers.isNotEmpty) {
                BoundaryMapDialog.show(
                  context,
                  markers: markers,
                  polygonPoints: polygonCoordinates,
                );
              } else if (polygonCoordinates.isNotEmpty) {
                // If we have a polygon but no markers, still show the map
                BoundaryMapDialog.show(
                  context,
                  markers: const [],
                  polygonPoints: polygonCoordinates,
                );
              }
            }))
    ]);

    return DataRow(
      cells: cells,
      onSelectChanged: null,
    );
  }

  @override
  void handleDelete(BuildContext context, NurseryData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog<NurseryData>(
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
