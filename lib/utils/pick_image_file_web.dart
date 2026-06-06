import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:qget_portal/utils/pick_image_file_result.dart';

Future<PickedImageFileResult?> pickImageFile() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false
    ..style.display = 'none';

  html.document.body?.children.add(input);

  try {
    input.click();
    await input.onChange.first.timeout(const Duration(minutes: 2));

    final file = input.files?.first;
    if (file == null) return null;
    return PickedImageFileResult(name: file.name);
  } on TimeoutException {
    return null;
  } finally {
    input.remove();
  }
}
