class MBAttributeValuePreset {
  const MBAttributeValuePreset({
    required this.value,
    required this.labelEn,
    this.labelBn = '',
    this.colorHex,
  });

  final String value;
  final String labelEn;
  final String labelBn;
  final String? colorHex;

  String get displayLabel {
    final english = labelEn.trim().isEmpty ? value : labelEn.trim();
    final bangla = labelBn.trim();
    return bangla.isEmpty ? english : '$english ($bangla)';
  }
}

class MBAttributePreset {
  const MBAttributePreset({
    required this.nameEn,
    required this.code,
    required this.displayType,
    this.nameBn = '',
    this.suggestedValues = const <String>[],
    this.suggestedValuePresets = const <MBAttributeValuePreset>[],
  });

  final String nameEn;
  final String nameBn;
  final String code;
  final String displayType;
  final List<String> suggestedValues;
  final List<MBAttributeValuePreset> suggestedValuePresets;

  String get displayName => nameBn.isNotEmpty ? nameBn : nameEn;
  bool get hasSuggestions =>
      suggestedValues.isNotEmpty || suggestedValuePresets.isNotEmpty;

  List<MBAttributeValuePreset> get effectiveSuggestedValuePresets {
    if (suggestedValuePresets.isNotEmpty) return suggestedValuePresets;
    return suggestedValues
        .map(
          (value) => MBAttributeValuePreset(
            value: value,
            labelEn: value,
            labelBn: value,
          ),
        )
        .toList(growable: false);
  }
}

const List<MBAttributePreset> kMbAttributePresets = <MBAttributePreset>[
  MBAttributePreset(
    nameEn: 'Size',
    nameBn: 'সাইজ',
    code: 'size',
    displayType: 'text',
    suggestedValues: ['Small', 'Medium', 'Large', 'Extra Large'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: 'small', labelEn: 'Small', labelBn: 'ছোট'),
      MBAttributeValuePreset(value: 'medium', labelEn: 'Medium', labelBn: 'মাঝারি'),
      MBAttributeValuePreset(value: 'large', labelEn: 'Large', labelBn: 'বড়'),
      MBAttributeValuePreset(value: 'extra_large', labelEn: 'Extra Large', labelBn: 'এক্সট্রা বড়'),
    ],
  ),
  MBAttributePreset(
    nameEn: 'Weight',
    nameBn: 'ওজন',
    code: 'Weight',
    displayType: 'text',
    suggestedValues: ['250g', '500g', '1kg', '2kg'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: '250g', labelEn: '250g', labelBn: '২৫০ গ্রাম'),
      MBAttributeValuePreset(value: '500g', labelEn: '500g', labelBn: '৫০০ গ্রাম'),
      MBAttributeValuePreset(value: '1kg', labelEn: '1kg', labelBn: '১ কেজি'),
      MBAttributeValuePreset(value: '2kg', labelEn: '2kg', labelBn: '২ কেজি'),
    ],
  ),
  MBAttributePreset(
    nameEn: 'Color',
    nameBn: 'রং',
    code: 'color',
    displayType: 'color',
    suggestedValues: ['Red', 'Green', 'Blue', 'Black', 'White'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: 'red', labelEn: 'Red', labelBn: 'লাল', colorHex: '#FF0000'),
      MBAttributeValuePreset(value: 'green', labelEn: 'Green', labelBn: 'সবুজ', colorHex: '#00AA00'),
      MBAttributeValuePreset(value: 'blue', labelEn: 'Blue', labelBn: 'নীল', colorHex: '#0066FF'),
      MBAttributeValuePreset(value: 'black', labelEn: 'Black', labelBn: 'কালো', colorHex: '#111111'),
      MBAttributeValuePreset(value: 'white', labelEn: 'White', labelBn: 'সাদা', colorHex: '#FFFFFF'),
    ],
  ),
  MBAttributePreset(
    nameEn: 'Volume',
    nameBn: 'পরিমাণ',
    code: 'volume',
    displayType: 'text',
    suggestedValues: ['250ml', '500ml', '1L', '2L'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: '250ml', labelEn: '250ml', labelBn: '২৫০ মিলি'),
      MBAttributeValuePreset(value: '500ml', labelEn: '500ml', labelBn: '৫০০ মিলি'),
      MBAttributeValuePreset(value: '1L', labelEn: '1L', labelBn: '১ লিটার'),
      MBAttributeValuePreset(value: '2L', labelEn: '2L', labelBn: '২ লিটার'),
    ],
  ),
  MBAttributePreset(
    nameEn: 'Pack',
    nameBn: 'প্যাক',
    code: 'pack',
    displayType: 'chip',
    suggestedValues: ['1 pcs', '2 pcs', '6 pcs', '12 pcs'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: '1 pcs', labelEn: '1 pcs', labelBn: '১ পিস'),
      MBAttributeValuePreset(value: '2 pcs', labelEn: '2 pcs', labelBn: '২ পিস'),
      MBAttributeValuePreset(value: '6 pcs', labelEn: '6 pcs', labelBn: '৬ পিস'),
      MBAttributeValuePreset(value: '12 pcs', labelEn: '12 pcs', labelBn: '১২ পিস'),
    ],
  ),
  MBAttributePreset(
    nameEn: 'Cut',
    nameBn: 'কাট',
    code: 'cut',
    displayType: 'text',
    suggestedValues: ['Whole', 'Half', 'Boneless', 'Curry Cut'],
    suggestedValuePresets: <MBAttributeValuePreset>[
      MBAttributeValuePreset(value: 'whole', labelEn: 'Whole', labelBn: 'সম্পূর্ণ'),
      MBAttributeValuePreset(value: 'half', labelEn: 'Half', labelBn: 'অর্ধেক'),
      MBAttributeValuePreset(value: 'boneless', labelEn: 'Boneless', labelBn: 'হাড় ছাড়া'),
      MBAttributeValuePreset(value: 'curry_cut', labelEn: 'Curry Cut', labelBn: 'কারি কাট'),
    ],
  ),
];

MBAttributePreset? findAttributePreset({
  String? nameEn,
  String? nameBn,
  String? code,
}) {
  final normalizedName = (nameEn ?? '').trim().toLowerCase();
  final normalizedNameBn = (nameBn ?? '').trim().toLowerCase();
  final normalizedCode = (code ?? '').trim().toLowerCase();

  if (normalizedName.isEmpty && normalizedNameBn.isEmpty && normalizedCode.isEmpty) {
    return null;
  }

  for (final preset in kMbAttributePresets) {
    if (normalizedCode.isNotEmpty && preset.code.toLowerCase() == normalizedCode) {
      return preset;
    }
    if (normalizedName.isNotEmpty && preset.nameEn.toLowerCase() == normalizedName) {
      return preset;
    }
    if (normalizedNameBn.isNotEmpty &&
        preset.nameBn.trim().toLowerCase() == normalizedNameBn) {
      return preset;
    }
  }

  return null;
}
