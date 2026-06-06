import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

import 'package:qget_portal/models/alumni_model.dart';
import 'package:qget_portal/utils/alumni_created_at_parse.dart';

class AlumniExcelExportService {
  AlumniExcelExportService._();

  /// Column order aligned with RTDB / admin roster fields.
  static List<String> get _headers => [
        'Member_Name',
        'Email',
        'Year',
        'Branch_Name',
        'Company_Name',
        'Position',
        'Contact_Number',
        'Whatsapp_Number',
        'Blood_Group',
        'Spouse_Name',
        'Spouse_Is_Member',
        'Social_Media_Link',
        'UID',
        'EF_Number',
        'ImageName',
        'ImgURL',
        'Child1_Name',
        'Child1_DOB',
        'Child2_Name',
        'Child2_DOB',
        'Child3_Name',
        'Child3_DOB',
        'Child4_Name',
        'Child4_DOB',
        'CreatedAt',
        'createdAt_ms',
        'updatedAt_ms',
      ];

  static List<String> _rowValues(AlumniModel m) => [
        m.memberName,
        m.email,
        m.year,
        m.branchName,
        m.companyName,
        m.position,
        m.contactNumber,
        m.whatsappNumber,
        m.bloodGroup,
        m.spouseName,
        m.spouseIsMember,
        m.socialMediaLink,
        m.uidField,
        m.efNumber,
        m.imageName,
        m.imgUrl,
        m.child1Name,
        m.child1Dob,
        m.child2Name,
        m.child2Dob,
        m.child3Name,
        m.child3Dob,
        m.child4Name,
        m.child4Dob,
        m.createdAt,
        m.createdAtMillis?.toString() ?? '',
        m.updatedAtMillis?.toString() ?? '',
      ];

  static Future<void> exportMembers(List<AlumniModel> members) async {
    final excel = Excel.createExcel();
    final sheet = excel['Alumni'];
    excel.delete('Sheet1');

    for (var c = 0; c < _headers.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
          .value = TextCellValue(_headers[c]);
    }

    members.sort((a, b) {
      final ma = a.createdAtMillis;
      final mb = b.createdAtMillis;
      if (ma != null && mb != null) {
        return mb.compareTo(ma);
      }
      if (ma != null) return -1;
      if (mb != null) return 1;
      final ta = parseAlumniCreatedAt(a.createdAt);
      final tb = parseAlumniCreatedAt(b.createdAt);
      if (ta == null && tb == null) {
        return a.memberName.compareTo(b.memberName);
      }
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });

    for (var r = 0; r < members.length; r++) {
      final m = members[r];
      final row = r + 1;
      final values = _rowValues(m);
      for (var c = 0; c < values.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
            .value = TextCellValue(values[c]);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final name =
        'alumni_export_${DateTime.now().toIso8601String().split('T').first}';

    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: '$name.xlsx',
        bytes: data,
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    } else {
      await FileSaver.instance.saveAs(
        name: name,
        bytes: data,
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}
