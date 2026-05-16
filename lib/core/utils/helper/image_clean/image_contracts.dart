import 'dart:io';

import 'package:image_picker/image_picker.dart';

abstract class ImagePickerGateway {
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
  });
}

abstract class PermissionService {
  Future<bool> checkAndRequestPermissions(ImageSource source);
}

abstract class ImageUploadGateway {
  Future<String> uploadImage(File imageFile);
}
