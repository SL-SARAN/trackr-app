import 'dart:io';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../domain/entities/enums.dart';

class CsvExportService {
  /// Generates a CSV string from a list of expenses.
  /// Returns the full file path if written, or throws.
  Future<String> exportExpenses({
    required List<ExpenseEntity> expenses,
    required List<CategoryEntity> categories,
    required String currencySymbol,
    required String directoryPath,
  }) async {
    final catMap = {for (final c in categories) c.id: c.name};
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final buf = StringBuffer();

    // Header
    buf.writeln('Date,Category,Amount ($currencySymbol),Description,Time of Day');

    // Rows
    for (final e in expenses) {
      final date = dateFmt.format(e.date);
      final category = _escapeCsv(catMap[e.categoryId] ?? 'Unknown');
      final amount = e.amount.toStringAsFixed(2);
      final desc = _escapeCsv(e.description ?? '');
      final tag = e.timeOfDayTag.label;
      buf.writeln('$date,$category,$amount,$desc,$tag');
    }

    // Write to file
    final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'trackr_expenses_$now.csv';
    final filePath = '$directoryPath${Platform.pathSeparator}$fileName';

    final file = File(filePath);
    await file.writeAsString(buf.toString());
    return filePath;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
