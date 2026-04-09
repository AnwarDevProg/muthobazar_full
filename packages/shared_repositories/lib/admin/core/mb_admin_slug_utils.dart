// Reusable admin slug helpers for category, brand, and future admin entities.

abstract final class MBAdminSlugUtils {
  static String normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'-{2,}'), '-');
  }

  static bool equalsNormalized(String a, String b) {
    return normalize(a) == normalize(b);
  }

  static bool isEmptyAfterNormalize(String value) {
    return normalize(value).isEmpty;
  }
}
