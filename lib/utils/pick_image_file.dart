import 'package:qget_portal/utils/pick_image_file_result.dart';
import 'package:qget_portal/utils/pick_image_file_stub.dart'
    if (dart.library.html) 'package:qget_portal/utils/pick_image_file_web.dart'
    if (dart.library.io) 'package:qget_portal/utils/pick_image_file_io.dart'
    as picker;

export 'package:qget_portal/utils/pick_image_file_result.dart';

Future<PickedImageFileResult?> pickImageFile() => picker.pickImageFile();
