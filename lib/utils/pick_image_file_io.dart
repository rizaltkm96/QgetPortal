import 'package:file_selector/file_selector.dart';

import 'package:qget_portal/utils/pick_image_file_result.dart';

Future<PickedImageFileResult?> pickImageFile() async {
  const imageTypes = XTypeGroup(
    label: 'Images',
    mimeTypes: <String>[
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
    ],
  );
  final picked = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypes]);
  if (picked == null) return null;
  return PickedImageFileResult(name: picked.name);
}
