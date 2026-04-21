class ProductCardPreviewOption {
  final String id;
  final String label;
  final String? subtitle;

  const ProductCardPreviewOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  ProductCardPreviewOption copyWith({
    String? id,
    String? label,
    String? subtitle,
  }) {
    return ProductCardPreviewOption(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductCardPreviewOption &&
        other.id == id &&
        other.label == label &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(id, label, subtitle);

  @override
  String toString() {
    return 'ProductCardPreviewOption(id: $id, label: $label, subtitle: $subtitle)';
  }
}

