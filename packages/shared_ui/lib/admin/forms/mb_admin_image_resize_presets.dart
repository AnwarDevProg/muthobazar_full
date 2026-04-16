import 'package:flutter/foundation.dart';

// Reusable admin image resize preset for category, brand, banner, product,
// and future admin forms.
@immutable
class MBAdminImageResizePreset {
  const MBAdminImageResizePreset({
    required this.id,
    required this.label,
    required this.note,
    required this.fullMaxWidth,
    required this.fullMaxHeight,
    required this.fullJpegQuality,
    required this.thumbSize,
    required this.thumbJpegQuality,
    this.thumbWidth,
    this.thumbHeight,
    this.cropAspectRatioX = 1,
    this.cropAspectRatioY = 1,
    this.requestSquareCrop = false,
  });

  final String id;
  final String label;
  final String note;
  final int fullMaxWidth;
  final int fullMaxHeight;
  final int fullJpegQuality;

  // Backward-compatible legacy square thumb input.
  final int thumbSize;

  // New optional explicit thumb dimensions.
  final int? thumbWidth;
  final int? thumbHeight;

  final int thumbJpegQuality;

  // New generic crop ratio support.
  final int cropAspectRatioX;
  final int cropAspectRatioY;

  // Keep this for backward compatibility with older callers/pipeline logic.
  final bool requestSquareCrop;

  int get resolvedThumbWidth => thumbWidth ?? thumbSize;
  int get resolvedThumbHeight => thumbHeight ?? thumbSize;

  bool get hasExplicitThumbSize => thumbWidth != null || thumbHeight != null;

  bool get isSquareThumb => resolvedThumbWidth == resolvedThumbHeight;

  bool get isSquareCrop =>
      cropAspectRatioX == cropAspectRatioY || requestSquareCrop;

  double get cropAspectRatio =>
      cropAspectRatioY == 0 ? 1 : cropAspectRatioX / cropAspectRatioY;

  String get fullSizeText => '${fullMaxWidth} × ${fullMaxHeight}';

  String get thumbSizeText =>
      '${resolvedThumbWidth} × ${resolvedThumbHeight}';

  String get cropRatioText => '${cropAspectRatioX}:${cropAspectRatioY}';
}

abstract final class MBAdminImageResizePresets {
  // Category and brand use small square thumbnail-style assets in the app.
  static const List<MBAdminImageResizePreset> categorySquare = [
    MBAdminImageResizePreset(
      id: 'category_square_small',
      label: 'Small (320 × 320)',
      note: 'Lightweight square image for compact category tiles.',
      fullMaxWidth: 320,
      fullMaxHeight: 320,
      fullJpegQuality: 88,
      thumbSize: 120,
      thumbJpegQuality: 82,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
    MBAdminImageResizePreset(
      id: 'category_square_recommended',
      label: 'Recommended (512 × 512)',
      note: 'Balanced square size for category cards across app and admin.',
      fullMaxWidth: 512,
      fullMaxHeight: 512,
      fullJpegQuality: 90,
      thumbSize: 160,
      thumbJpegQuality: 85,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
    MBAdminImageResizePreset(
      id: 'category_square_large',
      label: 'Large (640 × 640)',
      note: 'Sharper square image where category artwork needs more clarity.',
      fullMaxWidth: 640,
      fullMaxHeight: 640,
      fullJpegQuality: 92,
      thumbSize: 200,
      thumbJpegQuality: 86,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
  ];

  static const List<MBAdminImageResizePreset> brandSquare = [
    MBAdminImageResizePreset(
      id: 'brand_square_small',
      label: 'Small (320 × 320)',
      note: 'Compact square logo image for lightweight brand tiles.',
      fullMaxWidth: 320,
      fullMaxHeight: 320,
      fullJpegQuality: 88,
      thumbSize: 120,
      thumbJpegQuality: 82,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
    MBAdminImageResizePreset(
      id: 'brand_square_recommended',
      label: 'Recommended (512 × 512)',
      note: 'Balanced square size for brand presentation in app and admin.',
      fullMaxWidth: 512,
      fullMaxHeight: 512,
      fullJpegQuality: 90,
      thumbSize: 160,
      thumbJpegQuality: 85,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
    MBAdminImageResizePreset(
      id: 'brand_square_large',
      label: 'Large (640 × 640)',
      note: 'Sharper square image for richer brand cards and future promos.',
      fullMaxWidth: 640,
      fullMaxHeight: 640,
      fullJpegQuality: 92,
      thumbSize: 200,
      thumbJpegQuality: 86,
      cropAspectRatioX: 1,
      cropAspectRatioY: 1,
      requestSquareCrop: true,
    ),
  ];

  static const List<MBAdminImageResizePreset> bannerWide = [
    MBAdminImageResizePreset(
      id: 'banner_wide_small',
      label: 'Small (1280 × 720)',
      note: 'Useful for lightweight promotional banners.',
      fullMaxWidth: 1280,
      fullMaxHeight: 720,
      fullJpegQuality: 88,
      thumbSize: 240,
      thumbJpegQuality: 82,
      cropAspectRatioX: 16,
      cropAspectRatioY: 9,
      requestSquareCrop: false,
    ),
    MBAdminImageResizePreset(
      id: 'banner_wide_recommended',
      label: 'Recommended (1600 × 900)',
      note: 'Balanced wide banner size for web and app hero use.',
      fullMaxWidth: 1600,
      fullMaxHeight: 900,
      fullJpegQuality: 90,
      thumbSize: 320,
      thumbJpegQuality: 85,
      cropAspectRatioX: 16,
      cropAspectRatioY: 9,
      requestSquareCrop: false,
    ),
    MBAdminImageResizePreset(
      id: 'banner_wide_large',
      label: 'Large (1920 × 1080)',
      note: 'Sharper wide banner for richer hero presentation.',
      fullMaxWidth: 1920,
      fullMaxHeight: 1080,
      fullJpegQuality: 92,
      thumbSize: 360,
      thumbJpegQuality: 86,
      cropAspectRatioX: 16,
      cropAspectRatioY: 9,
      requestSquareCrop: false,
    ),
  ];

  static const List<MBAdminImageResizePreset> productPortrait = [
    MBAdminImageResizePreset(
      id: 'product_portrait_small',
      label: 'Small (720 × 900)',
      note: 'Lightweight portrait image for simple product detail and cards.',
      fullMaxWidth: 720,
      fullMaxHeight: 900,
      fullJpegQuality: 88,
      thumbSize: 400,
      thumbWidth: 400,
      thumbHeight: 500,
      thumbJpegQuality: 82,
      cropAspectRatioX: 4,
      cropAspectRatioY: 5,
      requestSquareCrop: false,
    ),
    MBAdminImageResizePreset(
      id: 'product_portrait_recommended',
      label: 'Recommended (1080 × 1350)',
      note:
      'Balanced portrait size for product detail view and customer app cards.',
      fullMaxWidth: 1080,
      fullMaxHeight: 1350,
      fullJpegQuality: 90,
      thumbSize: 400,
      thumbWidth: 400,
      thumbHeight: 500,
      thumbJpegQuality: 85,
      cropAspectRatioX: 4,
      cropAspectRatioY: 5,
      requestSquareCrop: false,
    ),
    MBAdminImageResizePreset(
      id: 'product_portrait_large',
      label: 'Large (1280 × 1600)',
      note:
      'Sharper portrait image for premium product presentation where more detail is needed.',
      fullMaxWidth: 1280,
      fullMaxHeight: 1600,
      fullJpegQuality: 92,
      thumbSize: 400,
      thumbWidth: 400,
      thumbHeight: 500,
      thumbJpegQuality: 86,
      cropAspectRatioX: 4,
      cropAspectRatioY: 5,
      requestSquareCrop: false,
    ),
  ];

  static MBAdminImageResizePreset defaultCategorySquare() =>
      categorySquare[1];

  static MBAdminImageResizePreset defaultBrandSquare() => brandSquare[1];

  static MBAdminImageResizePreset defaultBannerWide() => bannerWide[1];

  static MBAdminImageResizePreset defaultProductPortrait() =>
      productPortrait[1];
}