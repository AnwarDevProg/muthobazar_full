import 'dart:math' as math;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class MBOriginalPickedImage {
  const MBOriginalPickedImage({
    required this.originalBytes,
    required this.width,
    required this.height,
    required this.originalFileName,
    required this.baseName,
    required this.mimeType,
    required this.originalByteLength,
  });

  final Uint8List originalBytes;
  final int width;
  final int height;
  final String originalFileName;
  final String baseName;
  final String mimeType;
  final int originalByteLength;
}

class MBCroppedImageResult {
  const MBCroppedImageResult({
    required this.croppedBytes,
    required this.width,
    required this.height,
    required this.originalFileName,
    required this.baseName,
    required this.mimeType,
    required this.croppedByteLength,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.cropAspectRatioX,
    required this.cropAspectRatioY,
    required this.zoomScale,
  });

  final Uint8List croppedBytes;
  final int width;
  final int height;
  final String originalFileName;
  final String baseName;
  final String mimeType;
  final int croppedByteLength;
  final int sourceWidth;
  final int sourceHeight;
  final int cropAspectRatioX;
  final int cropAspectRatioY;
  final double zoomScale;
}

class MBPreparedImageSet {
  const MBPreparedImageSet({
    required this.originalBytes,
    required this.fullBytes,
    required this.cardBytes,
    required this.thumbBytes,
    required this.tinyBytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.fullWidth,
    required this.fullHeight,
    required this.cardWidth,
    required this.cardHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.tinyWidth,
    required this.tinyHeight,
    required this.originalFileName,
    required this.baseName,
    required this.mimeType,
    required this.originalByteLength,
    required this.fullByteLength,
    required this.cardByteLength,
    required this.thumbByteLength,
    required this.tinyByteLength,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.requestSquareCrop,
    required this.requestAspectCrop,
    required this.cropAspectRatioX,
    required this.cropAspectRatioY,
    required this.croppedWidth,
    required this.croppedHeight,
    required this.croppedByteLength,
    required this.zoomScale,
    required this.fitMode,
  });

  final Uint8List originalBytes;
  final Uint8List fullBytes;
  final Uint8List cardBytes;
  final Uint8List thumbBytes;
  final Uint8List tinyBytes;

  final int originalWidth;
  final int originalHeight;
  final int fullWidth;
  final int fullHeight;
  final int cardWidth;
  final int cardHeight;
  final int thumbWidth;
  final int thumbHeight;
  final int tinyWidth;
  final int tinyHeight;

  final String originalFileName;
  final String baseName;
  final String mimeType;

  final int originalByteLength;
  final int fullByteLength;
  final int cardByteLength;
  final int thumbByteLength;
  final int tinyByteLength;

  final int sourceWidth;
  final int sourceHeight;

  final bool requestSquareCrop;
  final bool requestAspectCrop;
  final int cropAspectRatioX;
  final int cropAspectRatioY;

  final int croppedWidth;
  final int croppedHeight;
  final int croppedByteLength;
  final double zoomScale;
  final String fitMode;

  Uint8List get previewBytes => fullBytes;
}

class MBUploadedImageSet {
  const MBUploadedImageSet({
    required this.fullUrl,
    required this.thumbUrl,
    required this.fullPath,
    required this.thumbPath,
    required this.fullWidth,
    required this.fullHeight,
    required this.thumbWidth,
    required this.thumbHeight,
    this.originalUrl = '',
    this.originalPath = '',
    this.cardUrl = '',
    this.cardPath = '',
    this.tinyUrl = '',
    this.tinyPath = '',
    this.originalWidth,
    this.originalHeight,
    this.cardWidth,
    this.cardHeight,
    this.tinyWidth,
    this.tinyHeight,
  });

  final String originalUrl;
  final String fullUrl;
  final String cardUrl;
  final String thumbUrl;
  final String tinyUrl;

  final String originalPath;
  final String fullPath;
  final String cardPath;
  final String thumbPath;
  final String tinyPath;

  final int? originalWidth;
  final int? originalHeight;
  final int fullWidth;
  final int fullHeight;
  final int? cardWidth;
  final int? cardHeight;
  final int thumbWidth;
  final int thumbHeight;
  final int? tinyWidth;
  final int? tinyHeight;
}

class MBImagePipelineService {
  MBImagePipelineService._();

  static final MBImagePipelineService instance = MBImagePipelineService._();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<MBOriginalPickedImage?> pickOriginalImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      return null;
    }

    final Uint8List pickedBytes = await picked.readAsBytes();
    if (pickedBytes.isEmpty) {
      throw Exception('Picked image is empty.');
    }

    final img.Image? decoded = img.decodeImage(pickedBytes);
    if (decoded == null) {
      throw Exception('Failed to decode selected image.');
    }

    final String originalName =
        picked.name.trim().isEmpty ? 'image.jpg' : picked.name.trim();

    final String baseName = _sanitizeBaseName(
      p.basenameWithoutExtension(originalName),
    );

    return MBOriginalPickedImage(
      originalBytes: pickedBytes,
      width: decoded.width,
      height: decoded.height,
      originalFileName: originalName,
      baseName: baseName,
      mimeType: 'image/jpeg',
      originalByteLength: pickedBytes.lengthInBytes,
    );
  }

  Future<MBPreparedImageSet> prepareImageSetFromOriginal({
    required MBOriginalPickedImage original,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    bool requestSquareCrop = false,
    bool requestAspectCrop = false,
    int cropAspectRatioX = 1,
    int cropAspectRatioY = 1,
    int? thumbWidth,
    int? thumbHeight,
    int originalMaxLongSide = 2048,
    int originalJpegQuality = 90,
    int cardWidth = 600,
    int cardHeight = 750,
    int cardJpegQuality = 80,
    int tinyWidth = 120,
    int tinyHeight = 150,
    int tinyJpegQuality = 72,
  }) async {
    _validateResizeInputs(
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      thumbJpegQuality: thumbJpegQuality,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: cropAspectRatioX,
      cropAspectRatioY: cropAspectRatioY,
      originalMaxLongSide: originalMaxLongSide,
      originalJpegQuality: originalJpegQuality,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardJpegQuality: cardJpegQuality,
      tinyWidth: tinyWidth,
      tinyHeight: tinyHeight,
      tinyJpegQuality: tinyJpegQuality,
    );

    final img.Image? decoded = img.decodeImage(original.originalBytes);
    if (decoded == null) {
      throw Exception('Failed to decode original image for resize.');
    }

    final img.Image cropBase = requestSquareCrop
        ? _buildCenteredSquare(decoded)
        : requestAspectCrop
            ? _buildCenteredAspectCrop(
                decoded,
                aspectRatioX: cropAspectRatioX,
                aspectRatioY: cropAspectRatioY,
              )
            : img.Image.from(decoded);

    final Uint8List croppedBytes = Uint8List.fromList(
      img.encodeJpg(cropBase, quality: 96),
    );

    return _prepareImageSetFromDecoded(
      decodedOriginal: decoded,
      workingImage: cropBase,
      originalFileName: original.originalFileName,
      baseName: original.baseName,
      mimeType: original.mimeType,
      sourceWidth: original.width,
      sourceHeight: original.height,
      croppedWidth: cropBase.width,
      croppedHeight: cropBase.height,
      croppedByteLength: croppedBytes.lengthInBytes,
      zoomScale: 1.0,
      requestSquareCrop: requestSquareCrop,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: requestSquareCrop ? 1 : cropAspectRatioX,
      cropAspectRatioY: requestSquareCrop ? 1 : cropAspectRatioY,
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbJpegQuality: thumbJpegQuality,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      originalMaxLongSide: originalMaxLongSide,
      originalJpegQuality: originalJpegQuality,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardJpegQuality: cardJpegQuality,
      tinyWidth: tinyWidth,
      tinyHeight: tinyHeight,
      tinyJpegQuality: tinyJpegQuality,
      fitMode: requestAspectCrop || requestSquareCrop ? 'manualCrop' : 'contain',
    );
  }

  Future<MBPreparedImageSet?> pickCropAndPrepareImage({
    int fullMaxWidth = 1600,
    int fullMaxHeight = 1600,
    int fullJpegQuality = 88,
    int thumbSize = 320,
    int thumbJpegQuality = 82,
    bool requestSquareCrop = false,
    bool requestAspectCrop = false,
    int cropAspectRatioX = 1,
    int cropAspectRatioY = 1,
    int? thumbWidth,
    int? thumbHeight,
  }) async {
    final MBOriginalPickedImage? original = await pickOriginalImage();
    if (original == null) {
      return null;
    }

    return prepareImageSetFromOriginal(
      original: original,
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbJpegQuality: thumbJpegQuality,
      requestSquareCrop: requestSquareCrop,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: cropAspectRatioX,
      cropAspectRatioY: cropAspectRatioY,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
    );
  }

  Future<MBPreparedImageSet> prepareImageSetFromCropped({
    required MBCroppedImageResult cropped,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    bool requestSquareCrop = false,
    bool requestAspectCrop = false,
    int cropAspectRatioX = 1,
    int cropAspectRatioY = 1,
    int? thumbWidth,
    int? thumbHeight,
    int originalMaxLongSide = 2048,
    int originalJpegQuality = 90,
    int cardWidth = 600,
    int cardHeight = 750,
    int cardJpegQuality = 80,
    int tinyWidth = 120,
    int tinyHeight = 150,
    int tinyJpegQuality = 72,
  }) async {
    _validateResizeInputs(
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      thumbJpegQuality: thumbJpegQuality,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: cropAspectRatioX,
      cropAspectRatioY: cropAspectRatioY,
      originalMaxLongSide: originalMaxLongSide,
      originalJpegQuality: originalJpegQuality,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardJpegQuality: cardJpegQuality,
      tinyWidth: tinyWidth,
      tinyHeight: tinyHeight,
      tinyJpegQuality: tinyJpegQuality,
    );

    final img.Image? decoded = img.decodeImage(cropped.croppedBytes);
    if (decoded == null) {
      throw Exception('Failed to decode cropped image for resize.');
    }

    return _prepareImageSetFromDecoded(
      decodedOriginal: decoded,
      workingImage: decoded,
      originalFileName: cropped.originalFileName,
      baseName: cropped.baseName,
      mimeType: cropped.mimeType,
      sourceWidth: cropped.sourceWidth,
      sourceHeight: cropped.sourceHeight,
      croppedWidth: cropped.width,
      croppedHeight: cropped.height,
      croppedByteLength: cropped.croppedByteLength,
      zoomScale: cropped.zoomScale,
      requestSquareCrop: requestSquareCrop,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: requestSquareCrop ? 1 : cropAspectRatioX,
      cropAspectRatioY: requestSquareCrop ? 1 : cropAspectRatioY,
      fullMaxWidth: fullMaxWidth,
      fullMaxHeight: fullMaxHeight,
      fullJpegQuality: fullJpegQuality,
      thumbSize: thumbSize,
      thumbJpegQuality: thumbJpegQuality,
      thumbWidth: thumbWidth,
      thumbHeight: thumbHeight,
      originalMaxLongSide: originalMaxLongSide,
      originalJpegQuality: originalJpegQuality,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardJpegQuality: cardJpegQuality,
      tinyWidth: tinyWidth,
      tinyHeight: tinyHeight,
      tinyJpegQuality: tinyJpegQuality,
      fitMode: 'manualCrop',
    );
  }

  Future<MBUploadedImageSet> uploadPreparedImageSet({
    required MBPreparedImageSet prepared,
    required String storageFolder,
    required String entityId,
    String? fileStem,
    Map<String, String>? customMetadata,
    bool uploadOriginalCardTiny = false,
  }) async {
    final String safeFolder = _sanitizePathSegment(storageFolder);
    final String safeEntityId = _sanitizePathSegment(entityId);
    final String safeStem = _sanitizeBaseName(
      (fileStem ?? prepared.baseName).trim().isEmpty
          ? 'image'
          : (fileStem ?? prepared.baseName).trim(),
    );

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final String fullPath =
        '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_full.jpg';
    final String thumbPath =
        '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_thumb.jpg';

    final Reference fullRef = _storage.ref(fullPath);
    final Reference thumbRef = _storage.ref(thumbPath);

    String originalPath = '';
    String cardPath = '';
    String tinyPath = '';
    String originalUrl = '';
    String cardUrl = '';
    String tinyUrl = '';

    // Non-product image modules such as category, brand, banner, and profile
    // should upload only full + thumb. Product media can opt into the complete
    // original/full/card/thumb/tiny set with uploadOriginalCardTiny: true.
    if (uploadOriginalCardTiny) {
      originalPath =
          '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_original.jpg';
      cardPath =
          '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_card.jpg';
      tinyPath =
          '$safeFolder/$safeEntityId/${safeStem}_${timestamp}_tiny.jpg';

      final Reference originalRef = _storage.ref(originalPath);
      final Reference cardRef = _storage.ref(cardPath);
      final Reference tinyRef = _storage.ref(tinyPath);

      await originalRef.putData(
        prepared.originalBytes,
        _metadataForVariant(
          prepared: prepared,
          variant: 'original',
          entityId: safeEntityId,
          width: prepared.originalWidth,
          height: prepared.originalHeight,
          byteLength: prepared.originalByteLength,
          customMetadata: customMetadata,
        ),
      );

      await cardRef.putData(
        prepared.cardBytes,
        _metadataForVariant(
          prepared: prepared,
          variant: 'card',
          entityId: safeEntityId,
          width: prepared.cardWidth,
          height: prepared.cardHeight,
          byteLength: prepared.cardByteLength,
          customMetadata: customMetadata,
        ),
      );

      await tinyRef.putData(
        prepared.tinyBytes,
        _metadataForVariant(
          prepared: prepared,
          variant: 'tiny',
          entityId: safeEntityId,
          width: prepared.tinyWidth,
          height: prepared.tinyHeight,
          byteLength: prepared.tinyByteLength,
          customMetadata: customMetadata,
        ),
      );

      originalUrl = await originalRef.getDownloadURL();
      cardUrl = await cardRef.getDownloadURL();
      tinyUrl = await tinyRef.getDownloadURL();
    }

    await fullRef.putData(
      prepared.fullBytes,
      _metadataForVariant(
        prepared: prepared,
        variant: 'full',
        entityId: safeEntityId,
        width: prepared.fullWidth,
        height: prepared.fullHeight,
        byteLength: prepared.fullByteLength,
        customMetadata: customMetadata,
      ),
    );

    await thumbRef.putData(
      prepared.thumbBytes,
      _metadataForVariant(
        prepared: prepared,
        variant: 'thumb',
        entityId: safeEntityId,
        width: prepared.thumbWidth,
        height: prepared.thumbHeight,
        byteLength: prepared.thumbByteLength,
        customMetadata: customMetadata,
      ),
    );

    final String fullUrl = await fullRef.getDownloadURL();
    final String thumbUrl = await thumbRef.getDownloadURL();

    return MBUploadedImageSet(
      originalUrl: originalUrl,
      fullUrl: fullUrl,
      cardUrl: cardUrl,
      thumbUrl: thumbUrl,
      tinyUrl: tinyUrl,
      originalPath: originalPath,
      fullPath: fullPath,
      cardPath: cardPath,
      thumbPath: thumbPath,
      tinyPath: tinyPath,
      originalWidth: uploadOriginalCardTiny ? prepared.originalWidth : null,
      originalHeight: uploadOriginalCardTiny ? prepared.originalHeight : null,
      fullWidth: prepared.fullWidth,
      fullHeight: prepared.fullHeight,
      cardWidth: uploadOriginalCardTiny ? prepared.cardWidth : null,
      cardHeight: uploadOriginalCardTiny ? prepared.cardHeight : null,
      thumbWidth: prepared.thumbWidth,
      thumbHeight: prepared.thumbHeight,
      tinyWidth: uploadOriginalCardTiny ? prepared.tinyWidth : null,
      tinyHeight: uploadOriginalCardTiny ? prepared.tinyHeight : null,
    );
  }

  MBPreparedImageSet _prepareImageSetFromDecoded({
    required img.Image decodedOriginal,
    required img.Image workingImage,
    required String originalFileName,
    required String baseName,
    required String mimeType,
    required int sourceWidth,
    required int sourceHeight,
    required int croppedWidth,
    required int croppedHeight,
    required int croppedByteLength,
    required double zoomScale,
    required bool requestSquareCrop,
    required bool requestAspectCrop,
    required int cropAspectRatioX,
    required int cropAspectRatioY,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    required int? thumbWidth,
    required int? thumbHeight,
    required int originalMaxLongSide,
    required int originalJpegQuality,
    required int cardWidth,
    required int cardHeight,
    required int cardJpegQuality,
    required int tinyWidth,
    required int tinyHeight,
    required int tinyJpegQuality,
    required String fitMode,
  }) {
    final int resolvedThumbWidth = thumbWidth ?? thumbSize;
    final int resolvedThumbHeight = thumbHeight ?? thumbSize;

    final img.Image originalImage = _resizeContain(
      decodedOriginal,
      maxWidth: originalMaxLongSide,
      maxHeight: originalMaxLongSide,
    );

    final img.Image fullImage = _resizeContain(
      workingImage,
      maxWidth: fullMaxWidth,
      maxHeight: fullMaxHeight,
    );

    final img.Image cardImage = _resizeContainOnCanvas(
      workingImage,
      targetWidth: cardWidth,
      targetHeight: cardHeight,
    );

    final img.Image thumbImage = _resizeContainOnCanvas(
      workingImage,
      targetWidth: resolvedThumbWidth,
      targetHeight: resolvedThumbHeight,
    );

    final img.Image tinyImage = _resizeContainOnCanvas(
      workingImage,
      targetWidth: tinyWidth,
      targetHeight: tinyHeight,
    );

    final Uint8List originalBytes = Uint8List.fromList(
      img.encodeJpg(originalImage, quality: originalJpegQuality),
    );
    final Uint8List fullBytes = Uint8List.fromList(
      img.encodeJpg(fullImage, quality: fullJpegQuality),
    );
    final Uint8List cardBytes = Uint8List.fromList(
      img.encodeJpg(cardImage, quality: cardJpegQuality),
    );
    final Uint8List thumbBytes = Uint8List.fromList(
      img.encodeJpg(thumbImage, quality: thumbJpegQuality),
    );
    final Uint8List tinyBytes = Uint8List.fromList(
      img.encodeJpg(tinyImage, quality: tinyJpegQuality),
    );

    return MBPreparedImageSet(
      originalBytes: originalBytes,
      fullBytes: fullBytes,
      cardBytes: cardBytes,
      thumbBytes: thumbBytes,
      tinyBytes: tinyBytes,
      originalWidth: originalImage.width,
      originalHeight: originalImage.height,
      fullWidth: fullImage.width,
      fullHeight: fullImage.height,
      cardWidth: cardImage.width,
      cardHeight: cardImage.height,
      thumbWidth: thumbImage.width,
      thumbHeight: thumbImage.height,
      tinyWidth: tinyImage.width,
      tinyHeight: tinyImage.height,
      originalFileName: originalFileName,
      baseName: baseName,
      mimeType: mimeType,
      originalByteLength: originalBytes.lengthInBytes,
      fullByteLength: fullBytes.lengthInBytes,
      cardByteLength: cardBytes.lengthInBytes,
      thumbByteLength: thumbBytes.lengthInBytes,
      tinyByteLength: tinyBytes.lengthInBytes,
      sourceWidth: sourceWidth,
      sourceHeight: sourceHeight,
      requestSquareCrop: requestSquareCrop,
      requestAspectCrop: requestAspectCrop,
      cropAspectRatioX: cropAspectRatioX,
      cropAspectRatioY: cropAspectRatioY,
      croppedWidth: croppedWidth,
      croppedHeight: croppedHeight,
      croppedByteLength: croppedByteLength,
      zoomScale: zoomScale,
      fitMode: fitMode,
    );
  }

  SettableMetadata _metadataForVariant({
    required MBPreparedImageSet prepared,
    required String variant,
    required String entityId,
    required int width,
    required int height,
    required int byteLength,
    required Map<String, String>? customMetadata,
  }) {
    return SettableMetadata(
      contentType: prepared.mimeType,
      customMetadata: <String, String>{
        'variant': variant,
        'entityId': entityId,
        'originalFileName': prepared.originalFileName,
        'width': width.toString(),
        'height': height.toString(),
        'byteLength': byteLength.toString(),
        'sourceWidth': prepared.sourceWidth.toString(),
        'sourceHeight': prepared.sourceHeight.toString(),
        'squareCrop': prepared.requestSquareCrop.toString(),
        'aspectCrop': prepared.requestAspectCrop.toString(),
        'cropAspectRatioX': prepared.cropAspectRatioX.toString(),
        'cropAspectRatioY': prepared.cropAspectRatioY.toString(),
        'croppedWidth': prepared.croppedWidth.toString(),
        'croppedHeight': prepared.croppedHeight.toString(),
        'croppedByteLength': prepared.croppedByteLength.toString(),
        'zoomScale': prepared.zoomScale.toString(),
        'fitMode': prepared.fitMode,
        ...?customMetadata,
      },
    );
  }

  void _validateResizeInputs({
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int? thumbWidth,
    required int? thumbHeight,
    required int thumbJpegQuality,
    required bool requestAspectCrop,
    required int cropAspectRatioX,
    required int cropAspectRatioY,
    required int originalMaxLongSide,
    required int originalJpegQuality,
    required int cardWidth,
    required int cardHeight,
    required int cardJpegQuality,
    required int tinyWidth,
    required int tinyHeight,
    required int tinyJpegQuality,
  }) {
    if (fullMaxWidth <= 0 || fullMaxHeight <= 0) {
      throw Exception('Full image target size must be greater than zero.');
    }
    if (thumbSize <= 0) {
      throw Exception('Thumb size must be greater than zero.');
    }
    if (thumbWidth != null && thumbWidth <= 0) {
      throw Exception('Thumb width must be greater than zero.');
    }
    if (thumbHeight != null && thumbHeight <= 0) {
      throw Exception('Thumb height must be greater than zero.');
    }
    if (originalMaxLongSide <= 0) {
      throw Exception('Original image max long side must be greater than zero.');
    }
    if (cardWidth <= 0 || cardHeight <= 0) {
      throw Exception('Card image target size must be greater than zero.');
    }
    if (tinyWidth <= 0 || tinyHeight <= 0) {
      throw Exception('Tiny image target size must be greater than zero.');
    }
    for (final quality in <int>[
      fullJpegQuality,
      thumbJpegQuality,
      originalJpegQuality,
      cardJpegQuality,
      tinyJpegQuality,
    ]) {
      if (quality < 1 || quality > 100) {
        throw Exception('JPEG quality must be between 1 and 100.');
      }
    }
    if (requestAspectCrop) {
      if (cropAspectRatioX <= 0 || cropAspectRatioY <= 0) {
        throw Exception('Crop aspect ratio values must be greater than zero.');
      }
    }
  }

  img.Image _resizeContain(
    img.Image source, {
    required int maxWidth,
    required int maxHeight,
  }) {
    if (source.width <= maxWidth && source.height <= maxHeight) {
      return img.Image.from(source);
    }

    final double widthRatio = maxWidth / source.width;
    final double heightRatio = maxHeight / source.height;
    final double scale = math.min(widthRatio, heightRatio);

    final int targetWidth = math.max(1, (source.width * scale).round());
    final int targetHeight = math.max(1, (source.height * scale).round());

    return img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.average,
    );
  }

  img.Image _resizeContainOnCanvas(
    img.Image source, {
    required int targetWidth,
    required int targetHeight,
  }) {
    final img.Image canvas = img.Image(width: targetWidth, height: targetHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    final img.Image contained = _resizeContain(
      source,
      maxWidth: targetWidth,
      maxHeight: targetHeight,
    );

    final int dstX = ((targetWidth - contained.width) / 2).round();
    final int dstY = ((targetHeight - contained.height) / 2).round();

    img.compositeImage(canvas, contained, dstX: dstX, dstY: dstY);
    return canvas;
  }

  img.Image _buildCenteredSquare(img.Image source) {
    final int squareSide = math.min(source.width, source.height);
    final int offsetX = ((source.width - squareSide) / 2).round();
    final int offsetY = ((source.height - squareSide) / 2).round();

    return img.copyCrop(
      source,
      x: offsetX,
      y: offsetY,
      width: squareSide,
      height: squareSide,
    );
  }

  img.Image _buildCenteredAspectCrop(
    img.Image source, {
    required int aspectRatioX,
    required int aspectRatioY,
  }) {
    final double targetRatio = aspectRatioX / aspectRatioY;
    final double sourceRatio = source.width / source.height;

    int cropWidth = source.width;
    int cropHeight = source.height;

    if (sourceRatio > targetRatio) {
      cropWidth = math.max(1, (source.height * targetRatio).round());
      cropHeight = source.height;
    } else if (sourceRatio < targetRatio) {
      cropWidth = source.width;
      cropHeight = math.max(1, (source.width / targetRatio).round());
    }

    final int offsetX = ((source.width - cropWidth) / 2).round();
    final int offsetY = ((source.height - cropHeight) / 2).round();

    return img.copyCrop(
      source,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );
  }

  String _sanitizeBaseName(String input) {
    final String cleaned = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return cleaned.isEmpty ? 'image' : cleaned;
  }

  String _sanitizePathSegment(String input) {
    final String cleaned = input
        .trim()
        .replaceAll(RegExp(r'[^\w\-/]+'), '_')
        .replaceAll(RegExp(r'/+'), '/')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^/+|/+$'), '');

    return cleaned.isEmpty ? 'unknown' : cleaned;
  }
}
