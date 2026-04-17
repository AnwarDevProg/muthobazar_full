class MBAttributePreset {
  const MBAttributePreset({
    required this.nameEn,
    required this.code,
    required this.displayType,
    this.nameBn = '',
    this.suggestedValues = const <String>[],
  });

  final String nameEn;
  final String nameBn;
  final String code;
  final String displayType;
  final List<String> suggestedValues;

  String get displayName => nameBn.isNotEmpty ? nameBn : nameEn;
  bool get hasSuggestions => suggestedValues.isNotEmpty;
}

const List<MBAttributePreset> kMbAttributePresets = <MBAttributePreset>[
  MBAttributePreset(
    nameEn: 'Size',
    nameBn: 'সাইজ',
    code: 'size',
    displayType: 'text',
    suggestedValues: ['Small', 'Medium', 'Large', 'Extra Large'],
  ),
  MBAttributePreset(
    nameEn: 'Weight',
    nameBn: 'ওজন',
    code: 'Weight',
    displayType: 'text',
    suggestedValues: ['250g', '500g', '1kg', '2kg'],
  ),
  MBAttributePreset(
    nameEn: 'Color',
    nameBn: 'রং',
    code: 'color',
    displayType: 'color',
    suggestedValues: ['Red', 'Green', 'Blue', 'Black', 'White'],
  ),
  MBAttributePreset(
    nameEn: 'Volume',
    nameBn: 'পরিমাণ',
    code: 'volume',
    displayType: 'text',
    suggestedValues: ['250ml', '500ml', '1L', '2L'],
  ),
  MBAttributePreset(
    nameEn: 'Pack',
    nameBn: 'প্যাক',
    code: 'pack',
    displayType: 'chip',
    suggestedValues: ['1 pcs', '2 pcs', '6 pcs', '12 pcs'],
  ),
  MBAttributePreset(
    nameEn: 'Cut',
    nameBn: 'কাট',
    code: 'cut',
    displayType: 'text',
    suggestedValues: ['Whole', 'Half', 'Boneless', 'Curry Cut'],
  ),
];

MBAttributePreset? findAttributePreset({
  String? nameEn,
  String? code,
}) {
  final normalizedName = (nameEn ?? '').trim().toLowerCase();
  final normalizedCode = (code ?? '').trim().toLowerCase();

  if (normalizedName.isEmpty && normalizedCode.isEmpty) {
    return null;
  }

  for (final preset in kMbAttributePresets) {
    if (normalizedCode.isNotEmpty &&
        preset.code.toLowerCase() == normalizedCode) {
      return preset;
    }
    if (normalizedName.isNotEmpty &&
        preset.nameEn.toLowerCase() == normalizedName) {
      return preset;
    }
  }

  return null;
}