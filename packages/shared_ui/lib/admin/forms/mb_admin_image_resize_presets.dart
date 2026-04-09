import 'package:flutter/foundation.dart';

// Reusable admin image resize preset for category, brand, banner, and future
// admin forms.
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
    this.requestSquareCrop = false,
  });

  final String id;
  final String label;
  final String note;
  final int fullMaxWidth;
  final int fullMaxHeight;
  final int fullJpegQuality;
  final int thumbSize;
  final int thumbJpegQuality;
  final bool requestSquareCrop;

  String get fullSizeText => '${fullMaxWidth} × ${fullMaxHeight}';

  String get thumbSizeText => '${thumbSize} × ${thumbSize}';
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
      requestSquareCrop: false,
    ),
  ];

  static MBAdminImageResizePreset defaultCategorySquare() =>
      categorySquare[1];

  static MBAdminImageResizePreset defaultBrandSquare() => brandSquare[1];

  static MBAdminImageResizePreset defaultBannerWide() => bannerWide[1];
}
