import 'dart:js_interop';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ExcelExportUtils {
  static Future<Uint8List> exportToExcel({
    required List<String> headers,
    required List<List<dynamic>> data,
    required String sheetName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    // Remove the default sheet if it exists and is not the one we want
    if (excel.getDefaultSheet() != sheetName) {
      excel.delete('Sheet1');
    }

    // Add headers
    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    // Add data rows (convert everything to string)
    for (var row = 0; row < data.length; row++) {
      for (var col = 0; col < data[row].length; col++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        final value = data[row][col];
        cell.value = TextCellValue(value?.toString() ?? '');
      }
    }

    // Auto-size columns
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to generate Excel file');
    return Uint8List.fromList(bytes);
  }

  static Future<void> downloadExcel({
    required BuildContext context,
    required List<String> headers,
    required List<List<dynamic>> data,
    required String fileName,
    required String sheetName,
  }) async {
    try {
      final bytes = await exportToExcel(
        headers: headers,
        data: data,
        sheetName: sheetName,
      );

      // Create a blob and download the file
      final blob = web.Blob([bytes.toJS].toJS);
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.setAttribute('download', '$fileName.xlsx');
      anchor.click();
      web.URL.revokeObjectURL(url);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName.xlsx downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
