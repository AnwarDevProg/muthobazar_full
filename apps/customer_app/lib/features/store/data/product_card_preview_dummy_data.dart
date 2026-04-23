import 'package:shared_models/shared_models.dart';

import 'package:customer_app/features/store/models/mb_store_card_preview_entry.dart';

class MBProductCardPreviewDummyData {
  const MBProductCardPreviewDummyData._();

  static const List<String> sectionKeys = <String>[
    'fruits',
    'vegetables',
    'fish',
    'meat',
    'beverages',
    'household',
  ];

  static const Map<String, String> sectionTitles = <String, String>{
    'fruits': 'Fresh Fruits',
    'vegetables': 'Vegetables',
    'fish': 'Fish & Seafood',
    'meat': 'Meat',
    'beverages': 'Beverages',
    'household': 'Household',
  };

  static final List<MBProduct> products = <MBProduct>[
    _product(
      id: 'fruit_apple_red',
      slug: 'fruit-apple-red',
      titleEn: 'Fresh Red Apple',
      titleBn: 'তাজা লাল আপেল',
      shortDescriptionEn: 'Sweet and crispy daily fruit',
      shortDescriptionBn: 'মিষ্টি ও মচমচে দৈনন্দিন ফল',
      categoryId: 'fruits',
      categoryNameEn: 'Fruits',
      categoryNameBn: 'ফল',
      brandNameEn: 'MuthoFresh',
      brandNameBn: 'মুঠোফ্রেশ',
      unitLabelEn: '1 kg',
      price: 240,
      salePrice: 199,
      stockQty: 26,
      imageUrl:
      'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=1200&q=80',
      cardVariantId: MBCardVariant.compact01.id,
      isFeatured: true,
      isNewArrival: true,
      tags: <String>['fruit', 'fresh', 'daily'],
    ),
    _product(
      id: 'fruit_banana_cavendish',
      slug: 'fruit-banana-cavendish',
      titleEn: 'Cavendish Banana',
      titleBn: 'কাভেনডিশ কলা',
      shortDescriptionEn: 'Soft and energy-rich bananas',
      shortDescriptionBn: 'নরম ও এনার্জি-সমৃদ্ধ কলা',
      categoryId: 'fruits',
      categoryNameEn: 'Fruits',
      categoryNameBn: 'ফল',
      brandNameEn: 'MuthoFresh',
      brandNameBn: 'মুঠোফ্রেশ',
      unitLabelEn: '12 pcs',
      price: 120,
      salePrice: 99,
      stockQty: 34,
      imageUrl:
      'https://images.unsplash.com/photo-1574226516831-e1dff420e37f?w=1200&q=80',
      cardVariantId: MBCardVariant.flash01.id,
      isFlashSale: true,
      tags: <String>['fruit', 'banana'],
    ),
    _product(
      id: 'veg_tomato_local',
      slug: 'veg-tomato-local',
      titleEn: 'Local Tomato',
      titleBn: 'দেশি টমেটো',
      shortDescriptionEn: 'Fresh red tomatoes for cooking',
      shortDescriptionBn: 'রান্নার জন্য তাজা লাল টমেটো',
      categoryId: 'vegetables',
      categoryNameEn: 'Vegetables',
      categoryNameBn: 'সবজি',
      brandNameEn: 'Green Basket',
      brandNameBn: 'গ্রিন বাস্কেট',
      unitLabelEn: '1 kg',
      price: 90,
      salePrice: 75,
      stockQty: 41,
      imageUrl:
      'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=1200&q=80',
      cardVariantId: MBCardVariant.price01.id,
      isBestSeller: true,
      tags: <String>['vegetable', 'tomato'],
    ),
    _product(
      id: 'veg_potato_farm',
      slug: 'veg-potato-farm',
      titleEn: 'Farm Potato',
      titleBn: 'ফার্ম আলু',
      shortDescriptionEn: 'Everyday kitchen essential',
      shortDescriptionBn: 'প্রতিদিনের রান্নাঘরের প্রয়োজনীয় পণ্য',
      categoryId: 'vegetables',
      categoryNameEn: 'Vegetables',
      categoryNameBn: 'সবজি',
      brandNameEn: 'Green Basket',
      brandNameBn: 'গ্রিন বাস্কেট',
      unitLabelEn: '2 kg',
      price: 110,
      salePrice: 95,
      stockQty: 58,
      imageUrl:
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=1200&q=80',
      cardVariantId: MBCardVariant.horizontal01.id,
      tags: <String>['vegetable', 'potato'],
    ),
    _product(
      id: 'fish_ruhi_medium',
      slug: 'fish-ruhi-medium',
      titleEn: 'Medium Ruhi Fish',
      titleBn: 'মাঝারি রুই মাছ',
      shortDescriptionEn: 'Fresh-cut river fish',
      shortDescriptionBn: 'তাজা কাটা নদীর মাছ',
      categoryId: 'fish',
      categoryNameEn: 'Fish & Seafood',
      categoryNameBn: 'মাছ ও সামুদ্রিক খাবার',
      brandNameEn: 'River Catch',
      brandNameBn: 'রিভার ক্যাচ',
      unitLabelEn: '1 kg',
      price: 420,
      salePrice: 389,
      stockQty: 12,
      imageUrl:
      'https://images.unsplash.com/photo-1510130387422-82bed34b37e9?w=1200&q=80',
      cardVariantId: MBCardVariant.premium01.id,
      isFeatured: true,
      tags: <String>['fish', 'fresh'],
    ),
    _product(
      id: 'fish_shrimp_golda',
      slug: 'fish-shrimp-golda',
      titleEn: 'Golda Shrimp',
      titleBn: 'গলদা চিংড়ি',
      shortDescriptionEn: 'Premium frozen shrimp pack',
      shortDescriptionBn: 'প্রিমিয়াম ফ্রোজেন চিংড়ি প্যাক',
      categoryId: 'fish',
      categoryNameEn: 'Fish & Seafood',
      categoryNameBn: 'মাছ ও সামুদ্রিক খাবার',
      brandNameEn: 'River Catch',
      brandNameBn: 'রিভার ক্যাচ',
      unitLabelEn: '500 g',
      price: 680,
      salePrice: 599,
      stockQty: 8,
      imageUrl:
      'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=1200&q=80',
      cardVariantId: MBCardVariant.wide01.id,
      isFeatured: true,
      isFlashSale: true,
      tags: <String>['fish', 'shrimp', 'premium'],
    ),
    _product(
      id: 'meat_broiler_dressed',
      slug: 'meat-broiler-dressed',
      titleEn: 'Broiler Chicken Dressed',
      titleBn: 'ড্রেসড ব্রয়লার চিকেন',
      shortDescriptionEn: 'Clean and fresh ready-to-cook chicken',
      shortDescriptionBn: 'পরিষ্কার ও তাজা রান্নার উপযোগী চিকেন',
      categoryId: 'meat',
      categoryNameEn: 'Meat',
      categoryNameBn: 'মাংস',
      brandNameEn: 'Daily Protein',
      brandNameBn: 'ডেইলি প্রোটিন',
      unitLabelEn: '1 kg',
      price: 290,
      salePrice: 265,
      stockQty: 19,
      imageUrl:
      'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=1200&q=80',
      cardVariantId: MBCardVariant.featured01.id,
      isBestSeller: true,
      tags: <String>['meat', 'chicken'],
    ),
    _product(
      id: 'meat_beef_boneless',
      slug: 'meat-beef-boneless',
      titleEn: 'Boneless Beef',
      titleBn: 'বোনলেস গরুর মাংস',
      shortDescriptionEn: 'Premium fresh-cut boneless beef',
      shortDescriptionBn: 'প্রিমিয়াম তাজা কাটা বোনলেস গরুর মাংস',
      categoryId: 'meat',
      categoryNameEn: 'Meat',
      categoryNameBn: 'মাংস',
      brandNameEn: 'Daily Protein',
      brandNameBn: 'ডেইলি প্রোটিন',
      unitLabelEn: '1 kg',
      price: 820,
      salePrice: 759,
      stockQty: 7,
      imageUrl:
      'https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=1200&q=80',
      cardVariantId: MBCardVariant.promo01.id,
      isFeatured: true,
      tags: <String>['meat', 'beef', 'premium'],
    ),
    _product(
      id: 'bev_orange_juice',
      slug: 'bev-orange-juice',
      titleEn: 'Orange Juice',
      titleBn: 'অরেঞ্জ জুস',
      shortDescriptionEn: 'Refreshing family juice bottle',
      shortDescriptionBn: 'রিফ্রেশিং ফ্যামিলি জুস বোতল',
      categoryId: 'beverages',
      categoryNameEn: 'Beverages',
      categoryNameBn: 'পানীয়',
      brandNameEn: 'FreshSip',
      brandNameBn: 'ফ্রেশসিপ',
      unitLabelEn: '1 L',
      price: 180,
      salePrice: 149,
      stockQty: 23,
      imageUrl:
      'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=1200&q=80',
      cardVariantId: MBCardVariant.compact02.id,
      isNewArrival: true,
      tags: <String>['beverage', 'juice'],
    ),
    _product(
      id: 'bev_milk_uht',
      slug: 'bev-milk-uht',
      titleEn: 'UHT Milk',
      titleBn: 'ইউএইচটি দুধ',
      shortDescriptionEn: 'Long-life milk for daily use',
      shortDescriptionBn: 'দৈনন্দিন ব্যবহারের জন্য দীর্ঘস্থায়ী দুধ',
      categoryId: 'beverages',
      categoryNameEn: 'Beverages',
      categoryNameBn: 'পানীয়',
      brandNameEn: 'FreshSip',
      brandNameBn: 'ফ্রেশসিপ',
      unitLabelEn: '1 L',
      price: 115,
      salePrice: 105,
      stockQty: 31,
      imageUrl:
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=1200&q=80',
      cardVariantId: MBCardVariant.horizontal01.id,
      tags: <String>['beverage', 'milk'],
    ),
    _product(
      id: 'home_liquid_cleaner',
      slug: 'home-liquid-cleaner',
      titleEn: 'Floor Cleaner',
      titleBn: 'ফ্লোর ক্লিনার',
      shortDescriptionEn: 'Fresh fragrance household cleaner',
      shortDescriptionBn: 'ফ্রেশ ফ্র্যাগরেন্স হাউসহোল্ড ক্লিনার',
      categoryId: 'household',
      categoryNameEn: 'Household',
      categoryNameBn: 'গৃহস্থালি',
      brandNameEn: 'HomeCare',
      brandNameBn: 'হোমকেয়ার',
      unitLabelEn: '1 L',
      price: 260,
      salePrice: 229,
      stockQty: 14,
      imageUrl:
      'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=1200&q=80',
      cardVariantId: MBCardVariant.price01.id,
      isFeatured: true,
      tags: <String>['household', 'cleaner'],
    ),
    _product(
      id: 'home_tissue_box',
      slug: 'home-tissue-box',
      titleEn: 'Soft Tissue Box',
      titleBn: 'সফট টিস্যু বক্স',
      shortDescriptionEn: 'Daily-use soft facial tissue',
      shortDescriptionBn: 'দৈনন্দিন ব্যবহারের সফট ফেসিয়াল টিস্যু',
      categoryId: 'household',
      categoryNameEn: 'Household',
      categoryNameBn: 'গৃহস্থালি',
      brandNameEn: 'HomeCare',
      brandNameBn: 'হোমকেয়ার',
      unitLabelEn: '1 box',
      price: 85,
      salePrice: 72,
      stockQty: 38,
      imageUrl:
      'https://images.unsplash.com/photo-1583947582886-f40ec95dd752?w=1200&q=80',
      cardVariantId: MBCardVariant.flash01.id,
      isFlashSale: true,
      tags: <String>['household', 'tissue'],
    ),
  ];

  // Store page now starts empty.
  static const List<MBStoreCardPreviewEntry> previewEntries =
  <MBStoreCardPreviewEntry>[];

  static List<MBProduct> get allProducts => List<MBProduct>.unmodifiable(products);

  static List<MBStoreCardPreviewEntry> get allEntries =>
      List<MBStoreCardPreviewEntry>.unmodifiable(previewEntries);

  static List<MBProduct> productsForSection(String sectionKey) {
    final normalized = _normalize(sectionKey);
    return products
        .where((product) => _normalize(_productCategoryId(product)) == normalized)
        .toList(growable: false);
  }

  static List<MBStoreCardPreviewEntry> entriesForSection(String sectionKey) {
    final normalized = _normalize(sectionKey);
    final list = previewEntries
        .where((entry) => _normalize(entry.sectionKey) == normalized)
        .toList(growable: false);

    final copy = List<MBStoreCardPreviewEntry>.from(list);
    copy.sort(MBStoreCardPreviewEntry.sortComparator);
    return List<MBStoreCardPreviewEntry>.unmodifiable(copy);
  }

  static List<MBStoreCardPreviewEntry> clonedEntriesForSection(String sectionKey) {
    return entriesForSection(sectionKey)
        .map(
          (entry) => entry.copyWith(
        id: entry.id,
        productId: entry.productId,
        variantId: entry.variantId,
        sectionKey: entry.sectionKey,
        sortOrder: entry.sortOrder,
      ),
    )
        .toList(growable: false);
  }

  static List<MBStoreCardPreviewEntry> clonedEntries() {
    return previewEntries
        .map(
          (entry) => entry.copyWith(
        id: entry.id,
        productId: entry.productId,
        variantId: entry.variantId,
        sectionKey: entry.sectionKey,
        sortOrder: entry.sortOrder,
      ),
    )
        .toList(growable: false);
  }

  static MBProduct? productById(String productId) {
    final normalized = _normalize(productId);

    for (final product in products) {
      if (_normalize(product.id) == normalized) {
        return product;
      }
    }

    return null;
  }

  static MBProduct? findProduct(String productId) => productById(productId);

  static String titleForSection(String sectionKey) {
    final normalized = _normalize(sectionKey);
    for (final entry in sectionTitles.entries) {
      if (_normalize(entry.key) == normalized) {
        return entry.value;
      }
    }
    return sectionKey;
  }

  static String _productCategoryId(MBProduct product) {
    final dynamic p = product;

    final candidates = <String?>[
      _tryReadString(() => p.categoryId as String?),
      _tryReadString(() => p.primaryCategoryId as String?),
      _tryReadString(() => p.categorySlug as String?),
    ];

    for (final value in candidates) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }

    return '';
  }

  static String? _tryReadString(String? Function() reader) {
    try {
      return reader();
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String? raw) {
    return raw?.trim().toLowerCase() ?? '';
  }

  static MBProduct _product({
    required String id,
    required String slug,
    required String titleEn,
    required String titleBn,
    required String shortDescriptionEn,
    required String shortDescriptionBn,
    required String categoryId,
    required String categoryNameEn,
    required String categoryNameBn,
    required String brandNameEn,
    required String brandNameBn,
    required String unitLabelEn,
    required double price,
    required double salePrice,
    required int stockQty,
    required String imageUrl,
    required String cardVariantId,
    bool isFeatured = false,
    bool isBestSeller = false,
    bool isNewArrival = false,
    bool isFlashSale = false,
    List<String> tags = const <String>[],
  }) {
    return MBProduct.fromMap(
      <String, dynamic>{
        'id': id,
        'slug': slug,
        'titleEn': titleEn,
        'titleBn': titleBn,
        'nameEn': titleEn,
        'nameBn': titleBn,
        'shortDescriptionEn': shortDescriptionEn,
        'shortDescriptionBn': shortDescriptionBn,
        'descriptionEn': shortDescriptionEn,
        'descriptionBn': shortDescriptionBn,
        'thumbnailUrl': imageUrl,
        'imageUrl': imageUrl,
        'imageUrls': <String>[imageUrl],
        'price': price,
        'salePrice': salePrice,
        'stockQty': stockQty,
        'regularStockQty': stockQty,
        'trackInventory': true,
        'allowBackorder': false,
        'categoryId': categoryId,
        'categoryNameEn': categoryNameEn,
        'categoryNameBn': categoryNameBn,
        'brandNameEn': brandNameEn,
        'brandNameBn': brandNameBn,
        'unitLabelEn': unitLabelEn,
        'productType': 'simple',
        'tags': tags,
        'cardVariantId': cardVariantId,
        'cardVariant': cardVariantId,
        'cardLayoutType': cardVariantId,
        'isFeatured': isFeatured,
        'isBestSeller': isBestSeller,
        'isNewArrival': isNewArrival,
        'isFlashSale': isFlashSale,
      },
    );
  }
}