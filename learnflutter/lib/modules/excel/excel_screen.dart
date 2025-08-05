import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:expressions/expressions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AutoFormulaExcelViewer extends StatefulWidget {
  const AutoFormulaExcelViewer({super.key});

  @override
  State<AutoFormulaExcelViewer> createState() => _AutoFormulaExcelViewerState();
}

class _AutoFormulaExcelViewerState extends State<AutoFormulaExcelViewer> {
  List<List<String>> displayTable = [];
  Map<String, dynamic> cellMap = {}; // A1 -> value

  @override
  void initState() {
    super.initState();
    pickExcelAndCompute(); // tự load file khi vào
  }

  Future<void> pickExcelAndCompute() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) return;

    Uint8List bytes = result.files.first.bytes ?? await File(result.files.first.path!).readAsBytes();

    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) return;

    final rows = sheet.rows.length;
    final cols = sheet.rows.fold<int>(
      0,
      (prev, row) => row.length > prev ? row.length : prev,
    );

    // 1. Build A1 → value map
    cellMap.clear();
    for (int row = 0; row < rows; row++) {
      final currentRow = sheet.rows[row];
      for (int col = 0; col < currentRow.length; col++) {
        final cell = currentRow[col];
        final ref = _cellRef(col, row);
        cellMap[ref] = cell?.value;
      }
    }

    // 2. Build table display
    List<List<String>> newTable = [];

    for (int row = 0; row < rows; row++) {
      final currentRow = sheet.rows[row];
      List<String> rowValues = [];

      for (int col = 0; col < cols; col++) {
        final ref = _cellRef(col, row);
        String value = '';

        final cell = (col < currentRow.length) ? currentRow[col] : null;
        if (cell != null && cell.value is String && cell.value.toString().startsWith('=')) {
          value = _evaluateFormula(cell.value.toString()) ?? 'ERR';
        } else {
          value = cell?.value?.toString() ?? '';
        }

        rowValues.add(value);
      }

      newTable.add(rowValues);
    }

    setState(() {
      displayTable = newTable;
    });
  }

  /// Evaluate Excel-like expression using expressions package
  String? _evaluateFormula(String formula) {
    try {
      final expressionStr = formula.substring(1); // remove '='
      final expression = Expression.parse(expressionStr);

      final evaluator = const ExpressionEvaluator();
      final context = Map<String, dynamic>.fromEntries(
        cellMap.entries.map((e) => MapEntry(e.key, _toNumberOrString(e.value))),
      );

      final result = evaluator.eval(expression, context);
      return result?.toString();
    } catch (e) {
      return null;
    }
  }

  dynamic _toNumberOrString(dynamic val) {
    if (val == null) return 0;
    final asStr = val.toString();
    return double.tryParse(asStr) ?? asStr;
  }

  String _cellRef(int col, int row) {
    String colLetter = '';
    int n = col;
    do {
      colLetter = String.fromCharCode((n % 26) + 65) + colLetter;
      n = (n ~/ 26) - 1;
    } while (n >= 0);
    return '$colLetter${row + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Viewer (with formulas)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: pickExcelAndCompute,
          )
        ],
      ),
      body: displayTable.isEmpty
          ? const Center(child: Text('No Excel loaded.'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: List.generate(
                  displayTable.first.length,
                  (index) => DataColumn(label: Text(''), onSort: (columnIndex, ascending) {}, tooltip: 'gi do', headingRowAlignment: MainAxisAlignment.start),
                ),
                rows: displayTable.map((row) {
                  return DataRow(
                    cells: row.map((value) {
                      return DataCell(
                        Text(value),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
