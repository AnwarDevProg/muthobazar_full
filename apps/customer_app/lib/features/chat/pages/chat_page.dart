import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/design_studio/mb_card_design_studio.dart';

// MuthoBazar Chat Design Lab Host
// -------------------------------
// The full design studio shell now lives in shared_ui:
// packages/shared_ui/lib/widgets/common/product_cards/design_studio/mb_card_design_studio.dart
//
// This page only provides temporary sample products for customer-app preview.
// Later, Admin Product Card Studio can reuse the same MBCardDesignStudio widget
// with real product data.

class ChatPage extends StatelessWidget {
  const ChatPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MBCardDesignStudio(
      products: _sampleProducts,
      title: 'MuthoBazar Card Lab',
    );
  }

  static final List<MBProduct> _sampleProducts = <MBProduct>[
    _sampleProduct(
      id: 'lab_sport_shoes',
      title: 'SPORT SHOES',
      subtitle: 'Soft running shoes with lightweight comfort and daily wear feel.',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
      price: 1690,
      salePrice: 1290,
      categoryName: 'Sports',
      brandName: 'Runner',
    ),
    _sampleProduct(
      id: 'lab_red_onion',
      title: 'Red Onion',
      subtitle: 'Fresh selected local onion for daily cooking and family meals.',
      imageUrl:
          'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=900',
      price: 120,
      salePrice: 95,
      categoryName: 'Grocery',
      brandName: 'Mutho Fresh',
    ),
    _sampleProduct(
      id: 'lab_perfume',
      title: 'Premium Perfume',
      subtitle:
          'Long-lasting fragrance with elegant bottle design and refined notes.',
      imageUrl:
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=900',
      price: 2450,
      salePrice: 1990,
      categoryName: 'Beauty',
      brandName: 'Aura',
    ),
  ];

  static MBProduct _sampleProduct({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required double price,
    required double salePrice,
    required String categoryName,
    required String brandName,
  }) {
    return MBProduct.fromMap(
      <String, dynamic>{
        'id': id,
        'titleEn': title,
        'titleBn': title,
        'shortDescriptionEn': subtitle,
        'descriptionEn': subtitle,
        'thumbnailUrl': imageUrl,
        'imageUrl': imageUrl,
        'images': <String>[imageUrl],
        'price': price,
        'salePrice': salePrice,
        'effectivePrice': salePrice,
        'hasDiscount': salePrice < price,
        'categoryNameEn': categoryName,
        'categoryNameBn': categoryName,
        'brandNameEn': brandName,
        'brandNameBn': brandName,
        'stockStatus': 'stocked',
        'isActive': true,
        'isPublished': true,
        'unit': 'pcs',
        'rating': 4.6,
        'reviewCount': 124,
      },
    );
  }
}
