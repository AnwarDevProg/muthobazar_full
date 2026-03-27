// Image Helper
// ------------
// Handles profile image picking and compression.

import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 720,
      minHeight: 720,
      format: CompressFormat.jpeg,
    );

    if (compressed == null) {
      return file;
    }

    return File(compressed.path);
  }
}











