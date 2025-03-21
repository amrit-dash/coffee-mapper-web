import 'package:coffee_mapper_web/models/legacy_data.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/widgets/tables/base/base_data_table.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../widgets/dialogs/delete_confirmation_dialog.dart';

class LegacyTable extends BaseDataTable<LegacyData> {
  const LegacyTable({
    super.key,
    required super.data,
    required super.isLoggedIn,
    super.onDelete,
    super.isLoading = false,
    super.error,
    super.onRetry,
  });

  @override
  LegacyTableState createState() => LegacyTableState();
}

class LegacyTableState extends BaseDataTableState<LegacyData> {
  @override
  List<DataColumn2> buildColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = <DataColumn2>[];

    columns.addAll(TableColumns.legacyColumns.map((col) {
      return DataColumn2(
        label: buildColumnLabel(context, col.label),
        size: col.size,
        fixedWidth: ResponsiveUtils.getColumnWidth(screenWidth, col.width),
      );
    }));

    return columns;
  }

  @override
  DataRow2 buildDataRow(BuildContext context, LegacyData data) {
    final cells = <DataCell>[];

    cells.addAll([
      buildDataCell(context, data.name),
      buildDataCell(context, data.careOfName),
      buildDataCell(context, '${data.area} ha'),
      buildDataCell(context, data.block),
      buildDataCell(context, data.panchayat),
      buildDataCell(context, data.village),
      buildDataCell(context, data.year.toString()),
    ]);

    return DataRow2(cells: cells);
  }

  @override
  void handleDelete(BuildContext context, LegacyData data) {
    if (widget.onDelete == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog<LegacyData>(
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
}
