// How a card element reads data from product/resolved price/action context.
// Design config stays separate from product data.

class MBCardElementBinding {
  const MBCardElementBinding({
    required this.source,
    this.fallbackText,
    this.format,
    this.prefix,
    this.suffix,
  });

  factory MBCardElementBinding.fromMap(Map map) {
    return MBCardElementBinding(
      source: _string(map['source'] ?? map['binding']),
      fallbackText: _stringOrNull(map['fallbackText'] ?? map['fallback_text']),
      format: _stringOrNull(map['format']),
      prefix: _stringOrNull(map['prefix']),
      suffix: _stringOrNull(map['suffix']),
    );
  }

  final String source;
  final String? fallbackText;
  final String? format;
  final String? prefix;
  final String? suffix;

  bool get hasSource => source.trim().isNotEmpty;

  Map<String, Object?> toMap() => _cleanMap({
        'source': source,
        'fallbackText': fallbackText,
        'format': format,
        'prefix': prefix,
        'suffix': suffix,
      });
}

String _string(Object? value) => value?.toString().trim() ?? '';

String? _stringOrNull(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(map.entries.where((entry) {
    final value = entry.value;
    if (value == null) return false;
    if (value is String && value.isEmpty) return false;
    return true;
  }));
}
