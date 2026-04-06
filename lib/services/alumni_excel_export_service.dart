import 'package:excel/excel.dart';

import '../models/alumni_model.dart';

/// One exportable column (Sl. No. + member fields; document ID is not offered).
///
/// [columnWidth] is Excel column width (character units, same as in the `excel` package).
class AlumniExcelColumn {
  AlumniExcelColumn({
    required this.id,
    required this.headerLabel,
    required this.columnWidth,
    required CellValue Function(AlumniModel a, int serialOneBased) cellBuilder,
  }) : _cellBuilder = cellBuilder;

  final String id;
  final String headerLabel;
  /// Excel column width (~average character count visible without clipping).
  final double columnWidth;
  final CellValue Function(AlumniModel a, int serialOneBased) _cellBuilder;

  CellValue cellFor(AlumniModel a, int serialOneBased) =>
      _cellBuilder(a, serialOneBased);
}

/// Builds an `.xlsx` workbook of alumni (sorted by name) with optional columns.
class AlumniExcelExportService {
  AlumniExcelExportService._();

  /// Ordered definitions; [selectedIds] must use this order when filtering.
  static final List<AlumniExcelColumn> allColumns = [
    AlumniExcelColumn(
      id: 'serial',
      headerLabel: 'Sl. No.',
      columnWidth: 10,
      cellBuilder: (_, serial) => IntCellValue(serial),
    ),
    AlumniExcelColumn(
      id: 'memberName',
      headerLabel: 'Member Name',
      columnWidth: 34,
      cellBuilder: (a, _) => TextCellValue(a.name),
    ),
    AlumniExcelColumn(
      id: 'email',
      headerLabel: 'Email',
      columnWidth: 38,
      cellBuilder: (a, _) => TextCellValue(a.email),
    ),
    AlumniExcelColumn(
      id: 'createdAt',
      headerLabel: 'Created At',
      columnWidth: 14,
      cellBuilder: (a, _) => TextCellValue(a.createdAt ?? ''),
    ),
    AlumniExcelColumn(
      id: 'photoUrl',
      headerLabel: 'Photo URL',
      columnWidth: 56,
      cellBuilder: (a, _) => TextCellValue(a.photoUrl ?? ''),
    ),
    AlumniExcelColumn(
      id: 'year',
      headerLabel: 'Year',
      columnWidth: 12,
      cellBuilder: (a, _) => TextCellValue(a.year ?? ''),
    ),
    AlumniExcelColumn(
      id: 'branchName',
      headerLabel: 'Branch Name',
      columnWidth: 28,
      cellBuilder: (a, _) => TextCellValue(a.branchName ?? ''),
    ),
    AlumniExcelColumn(
      id: 'companyName',
      headerLabel: 'Company Name',
      columnWidth: 32,
      cellBuilder: (a, _) => TextCellValue(a.companyName ?? ''),
    ),
    AlumniExcelColumn(
      id: 'position',
      headerLabel: 'Position',
      columnWidth: 28,
      cellBuilder: (a, _) => TextCellValue(a.position ?? ''),
    ),
    AlumniExcelColumn(
      id: 'contactNumber',
      headerLabel: 'Contact Number',
      columnWidth: 18,
      cellBuilder: (a, _) => TextCellValue(a.contactNumber ?? ''),
    ),
    AlumniExcelColumn(
      id: 'whatsappNumber',
      headerLabel: 'Whatsapp Number',
      columnWidth: 18,
      cellBuilder: (a, _) => TextCellValue(a.whatsappNumber ?? ''),
    ),
    AlumniExcelColumn(
      id: 'bloodGroup',
      headerLabel: 'Blood Group',
      columnWidth: 14,
      cellBuilder: (a, _) => TextCellValue(a.bloodGroup ?? ''),
    ),
    AlumniExcelColumn(
      id: 'spouseName',
      headerLabel: 'Spouse Name',
      columnWidth: 28,
      cellBuilder: (a, _) => TextCellValue(a.spouseName ?? ''),
    ),
    AlumniExcelColumn(
      id: 'spouseIsMember',
      headerLabel: 'Spouse Is Member',
      columnWidth: 18,
      cellBuilder: (a, _) => TextCellValue(a.spouseIsMember ?? ''),
    ),
    AlumniExcelColumn(
      id: 'socialMediaLink',
      headerLabel: 'Social Media Link',
      columnWidth: 50,
      cellBuilder: (a, _) => TextCellValue(a.socialMediaLink ?? ''),
    ),
    AlumniExcelColumn(
      id: 'numericUid',
      headerLabel: 'UID (numeric)',
      columnWidth: 14,
      cellBuilder: (a, _) => a.numericUid != null
          ? IntCellValue(a.numericUid!)
          : TextCellValue(''),
    ),
    AlumniExcelColumn(
      id: 'efNumber',
      headerLabel: 'EF Number',
      columnWidth: 16,
      cellBuilder: (a, _) => TextCellValue(a.efNumber ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child1Name',
      headerLabel: 'Child 1 Name',
      columnWidth: 22,
      cellBuilder: (a, _) => TextCellValue(a.child1Name ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child1Dob',
      headerLabel: 'Child 1 DOB',
      columnWidth: 16,
      cellBuilder: (a, _) => TextCellValue(a.child1Dob ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child2Name',
      headerLabel: 'Child 2 Name',
      columnWidth: 22,
      cellBuilder: (a, _) => TextCellValue(a.child2Name ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child2Dob',
      headerLabel: 'Child 2 DOB',
      columnWidth: 16,
      cellBuilder: (a, _) => TextCellValue(a.child2Dob ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child3Name',
      headerLabel: 'Child 3 Name',
      columnWidth: 22,
      cellBuilder: (a, _) => TextCellValue(a.child3Name ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child3Dob',
      headerLabel: 'Child 3 DOB',
      columnWidth: 16,
      cellBuilder: (a, _) => TextCellValue(a.child3Dob ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child4Name',
      headerLabel: 'Child 4 Name',
      columnWidth: 22,
      cellBuilder: (a, _) => TextCellValue(a.child4Name ?? ''),
    ),
    AlumniExcelColumn(
      id: 'child4Dob',
      headerLabel: 'Child 4 DOB',
      columnWidth: 16,
      cellBuilder: (a, _) => TextCellValue(a.child4Dob ?? ''),
    ),
  ];

  static List<int> buildWorkbookBytes(
    List<AlumniModel> alumni,
    Set<String> selectedIds,
  ) {
    if (selectedIds.isEmpty) {
      throw ArgumentError('At least one column must be selected');
    }

    final active = allColumns.where((c) => selectedIds.contains(c.id)).toList();
    if (active.isEmpty) {
      throw ArgumentError('No matching columns for selection');
    }

    final sorted = List<AlumniModel>.from(alumni)
      ..sort((a, b) => a.name.compareTo(b.name));

    final excel = Excel.createExcel();
    final defaultName = excel.getDefaultSheet() ?? excel.tables.keys.first;
    const sheetName = 'Alumni Directory';
    excel.rename(defaultName, sheetName);
    final sheet = excel[sheetName];

    sheet.appendRow(
      active.map((c) => TextCellValue(c.headerLabel)).toList(),
    );

    for (var i = 0; i < sorted.length; i++) {
      final serial = i + 1;
      final a = sorted[i];
      sheet.appendRow(
        active.map((c) => c.cellFor(a, serial)).toList(),
      );
    }

    for (var c = 0; c < active.length; c++) {
      sheet.setColumnWidth(c, active[c].columnWidth);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Failed to encode Excel file');
    }
    return bytes;
  }
}
