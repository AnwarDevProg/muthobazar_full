import 'package:shared_models/shared_models.dart';

class MBProductCardPreviewCategory {
  final String id;
  final String nameEn;
  final String nameBn;

  const MBProductCardPreviewCategory({
    required this.id,
    required this.nameEn,
    required this.nameBn,
  });
}

class MBProductCardPreviewDummyData {
  const MBProductCardPreviewDummyData._();

  static final DateTime _baseNow = DateTime.now();

  static const List<MBProductCardPreviewCategory> categories = [
    MBProductCardPreviewCategory(
      id: 'grocery',
      nameEn: 'Grocery',
      nameBn: 'গ্রোসারি',
    ),
    MBProductCardPreviewCategory(
      id: 'fruits_vegetables',
      nameEn: 'Fruits & Vegetables',
      nameBn: 'ফল ও সবজি',
    ),
    MBProductCardPreviewCategory(
      id: 'personal_care',
      nameEn: 'Personal Care',
      nameBn: 'পার্সোনাল কেয়ার',
    ),
    MBProductCardPreviewCategory(
      id: 'electronics',
      nameEn: 'Electronics',
      nameBn: 'ইলেকট্রনিক্স',
    ),
    MBProductCardPreviewCategory(
      id: 'home_kitchen',
      nameEn: 'Home & Kitchen',
      nameBn: 'হোম অ্যান্ড কিচেন',
    ),
    MBProductCardPreviewCategory(
      id: 'baby_kids',
      nameEn: 'Baby & Kids',
      nameBn: 'বেবি অ্যান্ড কিডস',
    ),
  ];

  static final List<MBProduct> allProducts = _buildAllProducts();

  static List<MBProduct> productsForCategory(String categoryId) {
    return allProducts.where((item) => item.categoryId == categoryId).toList();
  }

  static MBProduct? productById(String productId) {
    for (final product in allProducts) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  static MBProduct get fallbackProduct => allProducts.first;

  static List<MBProduct> _buildAllProducts() {
    final layouts = MBProductCardLayoutHelper.previewValues;
    final products = <MBProduct>[];
    var globalIndex = 0;

    for (final category in categories) {
      final templates = _templatesFor(category.id);
      for (var localIndex = 0; localIndex < templates.length; localIndex++) {
        final template = templates[localIndex];
        final layout = layouts[globalIndex % layouts.length];
        products.add(
          _buildProduct(
            category: category,
            template: template,
            globalIndex: globalIndex,
            localIndex: localIndex,
            layoutValue: layout.value,
          ),
        );
        globalIndex++;
      }
    }

    return List<MBProduct>.unmodifiable(products);
  }

  static MBProduct _buildProduct({
    required MBProductCardPreviewCategory category,
    required _PreviewProductTemplate template,
    required int globalIndex,
    required int localIndex,
    required String layoutValue,
  }) {
    final imagePool = _imagePoolFor(category.id);
    final gallerySize = localIndex % 3 == 0 ? 4 : (localIndex % 2 == 0 ? 3 : 1);
    final gallery = List<String>.generate(
      gallerySize,
          (index) => imagePool[(localIndex + index) % imagePool.length],
    );

    final price = template.price;
    final salePrice = localIndex.isEven
        ? double.parse((price * (0.82 + ((localIndex % 3) * 0.03))).toStringAsFixed(2))
        : null;
    final stockQty = 18 + ((globalIndex * 7) % 65);
    final createdAt = _baseNow.subtract(Duration(days: globalIndex + 2));
    final updatedAt = _baseNow.subtract(Duration(hours: globalIndex * 3));
    final quantityMeta = _quantityMetaFor(category.id, localIndex);
    final mediaItems = _buildMediaItems(
      productId: 'preview_${category.id}_${localIndex + 1}',
      titleEn: template.titleEn,
      gallery: gallery,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    return MBProduct(
      id: 'preview_${category.id}_${localIndex + 1}',
      slug: _slugify('${category.nameEn} ${template.titleEn}'),
      productCode: 'P-${globalIndex + 1001}',
      sku: 'SKU-${category.id.substring(0, 3).toUpperCase()}-${(localIndex + 1).toString().padLeft(2, '0')}',
      titleEn: template.titleEn,
      titleBn: template.titleBn,
      shortDescriptionEn: template.shortDescriptionEn,
      shortDescriptionBn: template.shortDescriptionBn,
      descriptionEn: template.descriptionEn,
      descriptionBn: template.descriptionBn,
      thumbnailUrl: gallery.first,
      imageUrls: gallery,
      mediaItems: mediaItems,
      price: price,
      salePrice: salePrice,
      costPrice: double.parse((price * 0.72).toStringAsFixed(2)),
      saleStartsAt: salePrice == null ? null : _baseNow.subtract(const Duration(days: 1)),
      saleEndsAt: salePrice == null ? null : _baseNow.add(Duration(days: 5 + (localIndex % 4))),
      stockQty: stockQty,
      inventoryMode: 'stocked',
      trackInventory: true,
      supportsInstantOrder: category.id != 'electronics',
      supportsScheduledOrder: category.id == 'grocery' || category.id == 'fruits_vegetables',
      regularStockQty: stockQty,
      reservedInstantQty: localIndex % 4,
      todayInstantCap: 40 + (localIndex * 3),
      todayInstantSold: localIndex % 5,
      maxScheduleQtyPerDay: 60,
      schedulePriceType: 'fixed',
      estimatedSchedulePrice: salePrice == null ? null : salePrice,
      instantCutoffTime: category.id == 'grocery' ? '21:30' : null,
      minScheduleNoticeHours: category.id == 'grocery' ? 4 : 12,
      reorderLevel: 8,
      allowBackorder: false,
      categoryId: category.id,
      categoryNameEn: category.nameEn,
      categoryNameBn: category.nameBn,
      categorySlug: _slugify(category.nameEn),
      brandId: 'brand_${category.id}_${(localIndex % 4) + 1}',
      brandNameEn: _brandNameFor(category.id, localIndex),
      brandNameBn: _brandNameBnFor(category.id, localIndex),
      brandSlug: _slugify(_brandNameFor(category.id, localIndex)),
      productType: 'simple',
      tags: <String>[
        category.nameEn.toLowerCase(),
        template.tag,
        if (salePrice != null) 'discount',
        if (localIndex % 4 == 0) 'popular',
      ],
      keywords: <String>[
        template.titleEn.toLowerCase(),
        category.nameEn.toLowerCase(),
        template.keyword,
      ],
      attributes: const <MBProductAttribute>[],
      variations: const <MBProductVariation>[],
      purchaseOptions: const <MBProductPurchaseOption>[],
      cardLayoutType: layoutValue,
      isFeatured: localIndex == 0 || localIndex == 5,
      isFlashSale: salePrice != null && localIndex % 4 == 0,
      isEnabled: true,
      isNewArrival: localIndex <= 2,
      isBestSeller: localIndex == 1 || localIndex == 6,
      sortOrder: globalIndex,
      publishAt: createdAt,
      unpublishAt: null,
      views: 80 + (globalIndex * 17),
      totalSold: 5 + (globalIndex * 3),
      addToCartCount: 2 + (globalIndex * 2),
      quantityType: quantityMeta.quantityType,
      quantityValue: quantityMeta.quantityValue,
      toleranceType: quantityMeta.toleranceType,
      tolerance: quantityMeta.tolerance,
      isToleranceActive: quantityMeta.tolerance > 0,
      deliveryShift: category.id == 'electronics' ? 'next_day' : 'any',
      minOrderQty: quantityMeta.minOrderQty,
      maxOrderQty: quantityMeta.maxOrderQty,
      stepQty: quantityMeta.stepQty,
      unitLabelEn: quantityMeta.unitLabelEn,
      unitLabelBn: quantityMeta.unitLabelBn,
      isDeleted: false,
      deletedAt: null,
      deletedBy: null,
      deleteReason: null,
      createdBy: 'preview_lab',
      updatedBy: 'preview_lab',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<MBProductMedia> _buildMediaItems({
    required String productId,
    required String titleEn,
    required List<String> gallery,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return List<MBProductMedia>.generate(gallery.length, (index) {
      final url = gallery[index];
      return MBProductMedia(
        id: '${productId}_media_${index + 1}',
        url: url,
        fullUrl: url,
        thumbUrl: url,
        originalUrl: url,
        type: 'image',
        role: index == 0 ? 'thumbnail' : 'gallery',
        labelEn: index == 0 ? '$titleEn Cover' : '$titleEn View ${index + 1}',
        labelBn: '',
        altEn: titleEn,
        altBn: '',
        sortOrder: index,
        isPrimary: index == 0,
        isEnabled: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    });
  }

  static List<_PreviewProductTemplate> _templatesFor(String categoryId) {
    switch (categoryId) {
      case 'grocery':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Premium Miniket Rice 5kg', 'প্রিমিয়াম মিনিকেট চাল ৫ কেজি', 640, 'Fresh stock for daily family cooking.', 'পারিবারিক রান্নার জন্য ফ্রেশ স্টক।', 'Long-grain everyday rice with clean polish and reliable quality.', 'পরিষ্কার পালিশ করা দৈনন্দিন ব্যবহারের লং-গ্রেইন চাল।', 'rice', 'daily_rice'),
          _PreviewProductTemplate('Fortified Soybean Oil 5L', 'ফর্টিফাইড সয়াবিন তেল ৫ লিটার', 890, 'Balanced cooking oil for regular kitchen use.', 'নিয়মিত রান্নার জন্য ব্যালান্সড তেল।', 'Refined soybean oil with a clean finish for frying and curry cooking.', 'ভাজি ও তরকারির জন্য পরিশোধিত সয়াবিন তেল।', 'oil', 'soybean_oil'),
          _PreviewProductTemplate('Brown Sugar Pack 1kg', 'ব্রাউন সুগার প্যাক ১ কেজি', 145, 'Clean crystals with rich caramel tone.', 'পরিষ্কার দানা ও সমৃদ্ধ স্বাদ।', 'Sweetener suited for tea, dessert, and baking use.', 'চা, ডেজার্ট ও বেকিংয়ের জন্য উপযোগী।', 'sugar', 'brown_sugar'),
          _PreviewProductTemplate('Iodized Salt 1kg', 'আয়োডাইজড লবণ ১ কেজি', 42, 'Everyday essential kitchen staple.', 'দৈনন্দিন রান্নাঘরের প্রয়োজনীয় পণ্য।', 'Fine refined iodized salt packed for home cooking.', 'ঘরোয়া রান্নার জন্য ফাইন রিফাইন্ড আয়োডাইজড লবণ।', 'salt', 'iodized_salt'),
          _PreviewProductTemplate('Red Lentils 2kg', 'মসুর ডাল ২ কেজি', 255, 'Quick-cooking lentils for daily meals.', 'দৈনন্দিন খাবারের জন্য দ্রুত সেদ্ধ ডাল।', 'Uniform grain size with bright color and reliable taste.', 'উজ্জ্বল রঙ ও সমান দানার মানসম্মত ডাল।', 'lentils', 'red_lentils'),
          _PreviewProductTemplate('Whole Wheat Flour 2kg', 'আটা ২ কেজি', 130, 'Soft chapati and roti flour.', 'নরম রুটি ও চাপাটির জন্য।', 'Stone-milled style flour for bread and flatbreads.', 'রুটি ও চাপাটির জন্য মানসম্মত আটা।', 'flour', 'wheat_flour'),
          _PreviewProductTemplate('Gram Flour 1kg', 'বেসন ১ কেজি', 155, 'Fine besan for snacks and batter.', 'নাস্তা ও ব্যাটারের জন্য ফাইন বেসন।', 'Smooth gram flour suitable for pakora and sweets.', 'পাকোড়া ও মিষ্টির জন্য উপযোগী।', 'besan', 'gram_flour'),
          _PreviewProductTemplate('Powder Milk 500g', 'গুঁড়া দুধ ৫০০ গ্রাম', 380, 'Creamy milk powder for tea and baking.', 'চা ও বেকিংয়ের জন্য ক্রিমি গুঁড়া দুধ।', 'Instant milk powder with smooth mixing performance.', 'সহজে মিশে যায় এমন ইনস্ট্যান্ট গুঁড়া দুধ।', 'milk', 'powder_milk'),
          _PreviewProductTemplate('Black Tea Premium 400g', 'প্রিমিয়াম ব্ল্যাক টি ৪০০ গ্রাম', 295, 'Strong aroma and deep liquor.', 'গাঢ় স্বাদ ও দারুণ ঘ্রাণ।', 'Premium loose black tea for a rich cup every day.', 'প্রতিদিনের জন্য প্রিমিয়াম লুজ ব্ল্যাক টি।', 'tea', 'black_tea'),
          _PreviewProductTemplate('Chili Powder 200g', 'মরিচের গুঁড়া ২০০ গ্রাম', 120, 'Bright color with spicy kick.', 'ঝাঁঝালো স্বাদ ও উজ্জ্বল রঙ।', 'Clean ground chili powder packed for home spice racks.', 'ঘরের মশলার জন্য পরিষ্কারভাবে প্যাক করা মরিচ গুঁড়া।', 'spice', 'chili_powder'),
        ];
      case 'fruits_vegetables':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Fresh Red Apples 1kg', 'ফ্রেশ লাল আপেল ১ কেজি', 320, 'Crisp imported apples for snacking.', 'স্ন্যাকিংয়ের জন্য ক্রিস্প আপেল।', 'Bright red apples with a sweet bite and smooth skin.', 'মিষ্টি স্বাদের উজ্জ্বল লাল আপেল।', 'apple', 'red_apple'),
          _PreviewProductTemplate('Premium Bananas 12 pcs', 'প্রিমিয়াম কলা ১২ টি', 110, 'Naturally sweet everyday fruit.', 'প্রতিদিনের জন্য প্রাকৃতিক মিষ্টি ফল।', 'Carefully selected bananas for breakfast and smoothies.', 'ব্রেকফাস্ট ও স্মুদির জন্য বাছাইকৃত কলা।', 'banana', 'banana_bunch'),
          _PreviewProductTemplate('Orange Carrots 1kg', 'গাজর ১ কেজি', 95, 'Crunchy carrots for salad and curry.', 'সালাদ ও তরকারির জন্য কড়মড়ে গাজর।', 'Fresh carrots with bright color and sweet earthy taste.', 'উজ্জ্বল রঙের তাজা গাজর।', 'carrot', 'orange_carrot'),
          _PreviewProductTemplate('Farm Tomatoes 1kg', 'টমেটো ১ কেজি', 85, 'Juicy tomatoes with fresh aroma.', 'রসালো ও তাজা টমেটো।', 'Daily-use tomato batch for salad, curry, and sauce.', 'সালাদ, তরকারি ও সসের জন্য উপযোগী।', 'tomato', 'farm_tomato'),
          _PreviewProductTemplate('Green Cucumbers 1kg', 'শসা ১ কেজি', 70, 'Cool and crisp for salad platters.', 'সালাদের জন্য ঠান্ডা ও কড়মড়ে।', 'Hydrating cucumbers selected for fresh daily use.', 'তাজা ব্যবহারের জন্য বাছাইকৃত শসা।', 'cucumber', 'green_cucumber'),
          _PreviewProductTemplate('Fresh Spinach Bundle', 'পালং শাক', 45, 'Tender leafy greens for healthy meals.', 'স্বাস্থ্যকর খাবারের জন্য নরম শাক।', 'Washed spinach bundle suitable for stir fry and soup.', 'স্টির ফ্রাই ও স্যুপের জন্য উপযোগী।', 'spinach', 'spinach_bundle'),
          _PreviewProductTemplate('Purple Eggplant 1kg', 'বেগুন ১ কেজি', 80, 'Glossy eggplant for fry and bhorta.', 'ভর্তা ও ভাজার জন্য চকচকে বেগুন।', 'Firm eggplants packed fresh for home kitchen use.', 'ঘরোয়া রান্নার জন্য ফ্রেশ বেগুন।', 'eggplant', 'purple_eggplant'),
          _PreviewProductTemplate('Fresh Lemons 500g', 'লেবু ৫০০ গ্রাম', 60, 'Tangy citrus for juice and garnish.', 'রস ও গার্নিশের জন্য টক স্বাদ।', 'Bright lemons with fresh aroma and juicy flesh.', 'তাজা ঘ্রাণ ও রসালো অংশসহ লেবু।', 'lemon', 'fresh_lemon'),
          _PreviewProductTemplate('Broccoli Crown 500g', 'ব্রকলি ৫০০ গ্রাম', 140, 'Green florets for soup and stir fry.', 'স্যুপ ও স্টির ফ্রাইয়ের জন্য সবুজ ব্রকলি।', 'Fresh broccoli crown with compact florets and clean cut stem.', 'কমপ্যাক্ট ফ্লোরেটসহ তাজা ব্রকলি।', 'broccoli', 'broccoli_crown'),
          _PreviewProductTemplate('Potatoes 2kg', 'আলু ২ কেজি', 98, 'Everyday cooking essential in family size.', 'পরিবারের রান্নার জন্য দৈনন্দিন প্রয়োজনীয়।', 'Clean medium-size potatoes for curry, fry, and mash.', 'তরকারি, ভাজি ও ম্যাশের জন্য উপযোগী আলু।', 'potato', 'potato_bag'),
        ];
      case 'personal_care':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Hydrating Face Wash 100ml', 'হাইড্রেটিং ফেসওয়াশ ১০০ মি.লি.', 299, 'Gentle daily cleanser for fresh skin.', 'প্রতিদিনের জন্য জেন্টল ক্লিনজার।', 'Soft-foam face wash for regular skin cleansing and hydration.', 'নিয়মিত ত্বক পরিষ্কার ও হাইড্রেশনের জন্য ফেসওয়াশ।', 'facewash', 'hydrating_facewash'),
          _PreviewProductTemplate('Herbal Shampoo 340ml', 'হারবাল শ্যাম্পু ৩৪০ মি.লি.', 360, 'Smooth cleansing with light herbal fragrance.', 'হালকা হারবাল ঘ্রাণসহ পরিষ্কার চুল।', 'Balanced shampoo for soft hair and fresh scalp feel.', 'নরম চুল ও সতেজ স্ক্যাল্পের জন্য ব্যালান্সড শ্যাম্পু।', 'shampoo', 'herbal_shampoo'),
          _PreviewProductTemplate('Repair Conditioner 300ml', 'রিপেয়ার কন্ডিশনার ৩০০ মি.লি.', 390, 'Soft finish for dry and rough hair.', 'রুক্ষ চুলের জন্য নরম ফিনিশ।', 'Conditioner designed to smooth strands after each wash.', 'প্রতিবার ধোয়ার পর চুল মসৃণ রাখতে সহায়ক।', 'conditioner', 'repair_conditioner'),
          _PreviewProductTemplate('Fresh Deo Spray 150ml', 'ফ্রেশ ডিও স্প্রে ১৫০ মি.লি.', 255, 'Daily freshness with long-lasting feel.', 'দীর্ঘক্ষণ সতেজ অনুভূতি।', 'Compact body spray with modern fresh fragrance profile.', 'আধুনিক ফ্রেশ ঘ্রাণের কমপ্যাক্ট বডি স্প্রে।', 'deodorant', 'fresh_deo'),
          _PreviewProductTemplate('Whitening Toothpaste 180g', 'হোয়াইটেনিং টুথপেস্ট ১৮০ গ্রাম', 165, 'Clean mint protection for every day.', 'প্রতিদিনের জন্য মিন্টি সুরক্ষা।', 'Family-size toothpaste for freshness and plaque control.', 'ফ্রেশনেস ও প্লাক কন্ট্রোলের জন্য ফ্যামিলি সাইজ টুথপেস্ট।', 'toothpaste', 'whitening_toothpaste'),
          _PreviewProductTemplate('Moisturizing Lotion 200ml', 'ময়েশ্চারাইজিং লোশন ২০০ মি.লি.', 420, 'Smooth body care for dry skin.', 'শুষ্ক ত্বকের জন্য স্মুথ বডি কেয়ার।', 'Daily lotion with non-greasy finish and soft fragrance.', 'নন-গ্রিজি ফিনিশসহ দৈনিক লোশন।', 'lotion', 'body_lotion'),
          _PreviewProductTemplate('Hand Sanitizer 250ml', 'হ্যান্ড স্যানিটাইজার ২৫০ মি.লি.', 180, 'Quick clean for home and travel.', 'বাড়ি ও ট্রাভেলের জন্য দ্রুত পরিষ্কার।', 'Portable sanitizer bottle with easy pump action.', 'সহজ পাম্পসহ পোর্টেবল স্যানিটাইজার।', 'sanitizer', 'hand_sanitizer'),
          _PreviewProductTemplate('Luxury Bath Soap 125g', 'লাক্সারি বাথ সোপ ১২৫ গ্রাম', 78, 'Rich lather and soft fragrance.', 'ঘন ফেনা ও নরম ঘ্রাণ।', 'Beauty bath soap for daily shower use.', 'দৈনন্দিন গোসলের জন্য বিউটি বাথ সোপ।', 'soap', 'bath_soap'),
          _PreviewProductTemplate('Shaving Foam 200ml', 'শেভিং ফোম ২০০ মি.লি.', 310, 'Comfort shave with creamy texture.', 'ক্রিমি টেক্সচারে কমফোর্ট শেভ।', 'Smooth shaving foam for a close and easy shave.', 'সহজ ও ক্লোজ শেভের জন্য স্মুথ ফোম।', 'shaving', 'shaving_foam'),
          _PreviewProductTemplate('Hair Serum 80ml', 'হেয়ার সিরাম ৮০ মি.লি.', 470, 'Glossy finish with lightweight feel.', 'হালকা অনুভূতিতে গ্লসি ফিনিশ।', 'Serum for frizz control and smooth hair styling.', 'ফ্রিজ কন্ট্রোল ও স্মুথ স্টাইলিংয়ের জন্য সিরাম।', 'serum', 'hair_serum'),
        ];
      case 'electronics':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Wireless Earbuds Pro', 'ওয়্যারলেস ইয়ারবাডস প্রো', 2890, 'Compact buds with charging case.', 'চার্জিং কেসসহ কমপ্যাক্ট ইয়ারবাড।', 'TWS earbuds with touch controls and clear daily sound.', 'টাচ কন্ট্রোলসহ দৈনন্দিন ব্যবহারের টিডব্লিউএস ইয়ারবাড।', 'earbuds', 'wireless_earbuds'),
          _PreviewProductTemplate('Fast Charger 33W', 'ফাস্ট চার্জার ৩৩ ওয়াট', 1250, 'Reliable high-speed charging adapter.', 'বিশ্বাসযোগ্য হাই-স্পিড চার্জিং অ্যাডাপ্টার।', 'Type-C fast charger for phones and small devices.', 'ফোন ও ছোট ডিভাইসের জন্য টাইপ-সি ফাস্ট চার্জার।', 'charger', 'fast_charger'),
          _PreviewProductTemplate('Bluetooth Neckband', 'ব্লুটুথ নেকব্যান্ড', 1650, 'Lightweight audio for work and travel.', 'কাজ ও ভ্রমণের জন্য হালকা অডিও।', 'Flexible neckband with strong battery backup.', 'দীর্ঘ ব্যাটারি ব্যাকআপসহ ফ্লেক্সিবল নেকব্যান্ড।', 'audio', 'bluetooth_neckband'),
          _PreviewProductTemplate('Smart Watch Active', 'স্মার্ট ওয়াচ অ্যাকটিভ', 3450, 'Fitness-friendly watch with modern dial.', 'মডার্ন ডায়ালসহ ফিটনেস-ফ্রেন্ডলি ঘড়ি।', 'Everyday smart watch with health stats and notifications.', 'হেলথ স্ট্যাটস ও নোটিফিকেশনসহ স্মার্ট ওয়াচ।', 'watch', 'smart_watch'),
          _PreviewProductTemplate('Portable Power Bank 20000mAh', 'পাওয়ার ব্যাংক ২০০০০ এমএএইচ', 2190, 'High-capacity backup for travel days.', 'ভ্রমণের জন্য হাই-ক্যাপাসিটি ব্যাকআপ।', 'Dual-output power bank for phones and accessories.', 'ফোন ও এক্সেসরির জন্য ডুয়াল-আউটপুট পাওয়ার ব্যাংক।', 'powerbank', 'portable_power_bank'),
          _PreviewProductTemplate('Mini Bluetooth Speaker', 'মিনি ব্লুটুথ স্পিকার', 1990, 'Punchy sound in a small body.', 'ছোট বডিতে জোরালো সাউন্ড।', 'Portable speaker suitable for indoor and desk use.', 'ইনডোর ও ডেস্ক ব্যবহারের জন্য পোর্টেবল স্পিকার।', 'speaker', 'mini_speaker'),
          _PreviewProductTemplate('USB-C Data Cable', 'ইউএসবি-সি ডাটা কেবল', 320, 'Durable braided cable for daily charging.', 'দৈনন্দিন চার্জিংয়ের জন্য টেকসই ব্রেইডেড কেবল।', 'Fast-charge compatible cable with reinforced connector ends.', 'রিইনফোর্সড কানেক্টরসহ ফাস্ট-চার্জ সাপোর্টেড কেবল।', 'cable', 'usb_c_cable'),
          _PreviewProductTemplate('True HD Webcam', 'ট্রু এইচডি ওয়েবক্যাম', 2750, 'Clear video for calls and meetings.', 'কল ও মিটিংয়ের জন্য ক্লিয়ার ভিডিও।', 'USB webcam for desk setup and remote sessions.', 'ডেস্ক সেটআপ ও রিমোট সেশনের জন্য ইউএসবি ওয়েবক্যাম।', 'webcam', 'hd_webcam'),
          _PreviewProductTemplate('Wireless Mouse Silent', 'ওয়্যারলেস মাউস সাইলেন্ট', 980, 'Comfort click with quiet buttons.', 'শান্ত বাটনসহ কমফোর্ট ক্লিক।', 'Slim wireless mouse for office and laptop use.', 'অফিস ও ল্যাপটপের জন্য স্লিম ওয়্যারলেস মাউস।', 'mouse', 'wireless_mouse'),
          _PreviewProductTemplate('Laptop Cooling Pad', 'ল্যাপটপ কুলিং প্যাড', 1490, 'Desk comfort with active cooling fan.', 'অ্যাকটিভ কুলিংসহ ডেস্ক কমফোর্ট।', 'Cooling pad with adjustable angle and USB power.', 'অ্যাডজাস্টেবল অ্যাঙ্গেলসহ ইউএসবি চালিত কুলিং প্যাড।', 'cooling', 'laptop_cooling_pad'),
        ];
      case 'home_kitchen':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Non-Stick Fry Pan 28cm', 'নন-স্টিক ফ্রাই প্যান ২৮ সেমি', 1450, 'Smooth cooking surface for home meals.', 'ঘরোয়া রান্নার জন্য স্মুথ কুকিং সারফেস।', 'Wide fry pan with sturdy handle and easy-clean coating.', 'মজবুত হ্যান্ডেলসহ সহজে পরিষ্কার করা যায় এমন প্যান।', 'cookware', 'fry_pan'),
          _PreviewProductTemplate('Glass Storage Jar Set', 'গ্লাস স্টোরেজ জার সেট', 890, 'Clear jars for dry food organization.', 'শুকনা খাবার গোছাতে স্বচ্ছ জার।', 'Kitchen storage jar set with tight lids and clean look.', 'টাইট ঢাকনাসহ পরিচ্ছন্ন লুকের কিচেন জার সেট।', 'storage', 'glass_jar_set'),
          _PreviewProductTemplate('Chef Knife 8 inch', 'শেফ নাইফ ৮ ইঞ্চি', 990, 'Sharp everyday utility knife.', 'দৈনন্দিন ব্যবহারের ধারালো নাইফ।', 'Balanced chef knife for slicing vegetables and meat.', 'সবজি ও মাংস কাটার জন্য ব্যালান্সড শেফ নাইফ।', 'knife', 'chef_knife'),
          _PreviewProductTemplate('Cotton Kitchen Towel 3 pcs', 'কটন কিচেন টাওয়েল ৩ পিস', 420, 'Soft absorbent towels for kitchen work.', 'কিচেনের জন্য সফট ও অ্যাবজরবেন্ট টাওয়েল।', 'Reusable cotton towel pack with practical hanging loop.', 'হ্যাঙ্গিং লুপসহ পুনর্ব্যবহারযোগ্য কটন টাওয়েল।', 'towel', 'kitchen_towel'),
          _PreviewProductTemplate('Water Bottle Steel 1L', 'স্টিল ওয়াটার বোতল ১ লিটার', 780, 'Durable bottle for daily carry.', 'দৈনন্দিন ব্যবহারের জন্য টেকসই বোতল।', 'Leak-resistant steel bottle for office, school, and travel.', 'অফিস, স্কুল ও ভ্রমণের জন্য লিক-রেসিস্ট্যান্ট বোতল।', 'bottle', 'steel_bottle'),
          _PreviewProductTemplate('Ceramic Mug Duo Set', 'সেরামিক মগ ডুও সেট', 650, 'Pair of mugs for tea and coffee time.', 'চা-কফির জন্য জোড়া মগ।', 'Ceramic mug set with glossy finish and comfortable grip.', 'গ্লসি ফিনিশ ও আরামদায়ক গ্রিপসহ সেরামিক মগ।', 'mug', 'ceramic_mug'),
          _PreviewProductTemplate('Cutlery Set 24 pcs', 'কাটলারি সেট ২৪ পিস', 1590, 'Neat dining setup for family meals.', 'পারিবারিক খাবারের জন্য পরিপাটি ডাইনিং সেটআপ।', 'Complete spoon and fork set for everyday dining.', 'দৈনন্দিন ডাইনিংয়ের জন্য সম্পূর্ণ স্পুন-ফর্ক সেট।', 'cutlery', 'cutlery_set'),
          _PreviewProductTemplate('Electric Kettle 1.8L', 'ইলেকট্রিক কেটলি ১.৮ লিটার', 1890, 'Quick boil kettle for tea and instant meals.', 'চা ও ইনস্ট্যান্ট মিলের জন্য দ্রুত ফুটন্ত কেটলি।', 'Compact kettle with simple one-touch operation.', 'ওয়ান-টাচ অপারেশনসহ কমপ্যাক্ট কেটলি।', 'kettle', 'electric_kettle'),
          _PreviewProductTemplate('Food Container Box 5 pcs', 'ফুড কন্টেইনার বক্স ৫ পিস', 720, 'Stackable boxes for fridge and pantry.', 'ফ্রিজ ও প্যান্ট্রির জন্য স্ট্যাকেবল বক্স।', 'Versatile food container pack for meal prep storage.', 'মিল প্রেপ স্টোরেজের জন্য বহুমুখী কন্টেইনার প্যাক।', 'container', 'food_container'),
          _PreviewProductTemplate('Dish Drying Rack', 'ডিশ ড্রাইং র‍্যাক', 1320, 'Countertop organizer for plates and cups.', 'প্লেট ও কাপের জন্য কাউন্টারটপ অর্গানাইজার।', 'Practical drying rack with cutlery slot and tray base.', 'কাটলারি স্লট ও ট্রে বেসসহ ব্যবহারিক র‍্যাক।', 'rack', 'dish_drying_rack'),
        ];
      case 'baby_kids':
        return const <_PreviewProductTemplate>[
          _PreviewProductTemplate('Baby Diaper Jumbo Pack', 'বেবি ডায়াপার জাম্বো প্যাক', 1150, 'Soft absorbent diapers for day and night.', 'দিন-রাতের জন্য সফট ও অ্যাবজরবেন্ট ডায়াপার।', 'Large diaper pack designed for dryness and comfort.', 'শুষ্কতা ও আরামের জন্য ডিজাইন করা বড় প্যাক।', 'diaper', 'baby_diaper'),
          _PreviewProductTemplate('Infant Formula Milk 400g', 'ইনফ্যান্ট ফর্মুলা মিল্ক ৪০০ গ্রাম', 1890, 'Trusted nutrition support in compact tin.', 'কমপ্যাক্ট টিনে বিশ্বস্ত পুষ্টি সহায়তা।', 'Baby formula pack prepared for easy measured feeding.', 'পরিমিত ফিডিংয়ের জন্য প্রস্তুত বেবি ফর্মুলা।', 'formula', 'infant_formula'),
          _PreviewProductTemplate('Baby Lotion Gentle 200ml', 'বেবি লোশন জেন্টল ২০০ মি.লি.', 430, 'Soft care for delicate baby skin.', 'নরম বেবি স্কিনের জন্য জেন্টল কেয়ার।', 'Mild lotion for baby skin after bath and daily care.', 'গোসলের পর ও দৈনিক ব্যবহারের জন্য মাইল্ড লোশন।', 'baby_lotion', 'gentle_baby_lotion'),
          _PreviewProductTemplate('Kids Toothbrush Twin Pack', 'কিডস টুথব্রাশ টুইন প্যাক', 180, 'Small soft bristles for kids.', 'শিশুদের জন্য ছোট সফট ব্রিসলস।', 'Twin toothbrush pack sized for growing children.', 'বড় হতে থাকা শিশুদের জন্য উপযোগী টুইন প্যাক।', 'toothbrush', 'kids_toothbrush'),
          _PreviewProductTemplate('Feeding Bottle 250ml', 'ফিডিং বোতল ২৫০ মি.লি.', 320, 'Easy-grip bottle with clear scale mark.', 'ক্লিয়ার স্কেলসহ ইজি-গ্রিপ বোতল।', 'Baby bottle suitable for daily feeding routine.', 'দৈনিক ফিডিং রুটিনের জন্য উপযোগী বোতল।', 'bottle', 'feeding_bottle'),
          _PreviewProductTemplate('Baby Wipes Soft Pack', 'বেবি ওয়াইপস সফট প্যাক', 250, 'Gentle wipes for home and travel.', 'বাড়ি ও ট্রাভেলের জন্য জেন্টল ওয়াইপস।', 'Soft wet wipes pack with flip-top cover.', 'ফ্লিপ-টপ কভারসহ সফট ওয়েট ওয়াইপস।', 'wipes', 'baby_wipes'),
          _PreviewProductTemplate('Kids Water Bottle 500ml', 'কিডস ওয়াটার বোতল ৫০০ মি.লি.', 390, 'Cute bottle for school and outings.', 'স্কুল ও আউটিংয়ের জন্য কিউট বোতল।', 'Lightweight bottle with child-friendly carrying strap.', 'শিশুদের উপযোগী ক্যারি স্ট্র্যাপসহ হালকা বোতল।', 'kids_bottle', 'kids_water_bottle'),
          _PreviewProductTemplate('Baby Shampoo Mild 200ml', 'বেবি শ্যাম্পু মাইল্ড ২০০ মি.লি.', 360, 'Tear-free wash for soft hair care.', 'সফট হেয়ার কেয়ারের জন্য টিয়ার-ফ্রি ওয়াশ।', 'Mild shampoo created for baby bath time routine.', 'বেবি বাথ রুটিনের জন্য তৈরি মাইল্ড শ্যাম্পু।', 'baby_shampoo', 'baby_shampoo_mild'),
          _PreviewProductTemplate('Learning Blocks Set', 'লার্নিং ব্লকস সেট', 720, 'Colorful blocks for early play learning.', 'আর্লি প্লে-লার্নিংয়ের জন্য রঙিন ব্লকস।', 'Stacking toy set designed for fun and motor practice.', 'মজা ও মোটর প্র্যাকটিসের জন্য ডিজাইন করা টয় সেট।', 'toy', 'learning_blocks'),
          _PreviewProductTemplate('Baby Blanket Soft Cotton', 'বেবি ব্ল্যাঙ্কেট সফট কটন', 580, 'Light blanket for nap and stroller time.', 'নাপ ও স্ট্রলারের জন্য হালকা ব্ল্যাঙ্কেট।', 'Soft cotton blanket with cozy touch for babies.', 'শিশুদের জন্য আরামদায়ক কটন ব্ল্যাঙ্কেট।', 'blanket', 'baby_blanket'),
        ];
      default:
        return const <_PreviewProductTemplate>[];
    }
  }

  static List<String> _imagePoolFor(String categoryId) {
    switch (categoryId) {
      case 'grocery':
        return const <String>[
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1579113800032-c38bd7635818?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=900&q=80',
        ];
      case 'fruits_vegetables':
        return const <String>[
          'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1447175008436-054170c2e979?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1461354464878-ad92f492a5a0?auto=format&fit=crop&w=900&q=80',
        ];
      case 'personal_care':
        return const <String>[
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1556228578-8c89e6adf883?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80',
        ];
      case 'electronics':
        return const <String>[
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=80',
        ];
      case 'home_kitchen':
        return const <String>[
          'https://images.unsplash.com/photo-1517705008128-361805f42e86?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1503602642458-232111445657?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1484101403633-562f891dc89a?auto=format&fit=crop&w=900&q=80',
        ];
      case 'baby_kids':
        return const <String>[
          'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?auto=format&fit=crop&w=900&q=80',
        ];
      default:
        return const <String>[];
    }
  }

  static _QuantityMeta _quantityMetaFor(String categoryId, int localIndex) {
    switch (categoryId) {
      case 'grocery':
        return _QuantityMeta(
          quantityType: 'pack',
          quantityValue: localIndex.isEven ? 1 : 2,
          toleranceType: 'g',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 12,
          stepQty: 1,
          unitLabelEn: 'pack',
          unitLabelBn: 'প্যাক',
        );
      case 'fruits_vegetables':
        return _QuantityMeta(
          quantityType: 'kg',
          quantityValue: localIndex % 2 == 0 ? 1 : 0.5,
          toleranceType: 'g',
          tolerance: 50,
          minOrderQty: 0.5,
          maxOrderQty: 10,
          stepQty: 0.5,
          unitLabelEn: 'kg',
          unitLabelBn: 'কেজি',
        );
      case 'personal_care':
        return _QuantityMeta(
          quantityType: 'pcs',
          quantityValue: 1,
          toleranceType: 'ml',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 8,
          stepQty: 1,
          unitLabelEn: 'pc',
          unitLabelBn: 'পিস',
        );
      case 'electronics':
        return _QuantityMeta(
          quantityType: 'pcs',
          quantityValue: 1,
          toleranceType: 'pcs',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 4,
          stepQty: 1,
          unitLabelEn: 'pc',
          unitLabelBn: 'পিস',
        );
      case 'home_kitchen':
        return _QuantityMeta(
          quantityType: 'pcs',
          quantityValue: 1,
          toleranceType: 'pcs',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 6,
          stepQty: 1,
          unitLabelEn: 'pc',
          unitLabelBn: 'পিস',
        );
      case 'baby_kids':
        return _QuantityMeta(
          quantityType: 'pack',
          quantityValue: 1,
          toleranceType: 'pcs',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 8,
          stepQty: 1,
          unitLabelEn: 'pack',
          unitLabelBn: 'প্যাক',
        );
      default:
        return const _QuantityMeta(
          quantityType: 'pcs',
          quantityValue: 1,
          toleranceType: 'pcs',
          tolerance: 0,
          minOrderQty: 1,
          maxOrderQty: 1,
          stepQty: 1,
          unitLabelEn: 'pc',
          unitLabelBn: 'পিস',
        );
    }
  }

  static String _brandNameFor(String categoryId, int localIndex) {
    final index = localIndex % 4;
    switch (categoryId) {
      case 'grocery':
        return <String>['Fresh Basket', 'Daily Harvest', 'Kitchen Select', 'Prime Pantry'][index];
      case 'fruits_vegetables':
        return <String>['Farm Pick', 'Green Valley', 'Fresh Route', 'Nature Hub'][index];
      case 'personal_care':
        return <String>['Pure Glow', 'Soft Bloom', 'Care Nest', 'Daily Fresh'][index];
      case 'electronics':
        return <String>['Pulse Tech', 'Voltix', 'Nova Gear', 'Urban Connect'][index];
      case 'home_kitchen':
        return <String>['HomeCraft', 'CookNest', 'Everyday Living', 'Urban Kitchen'][index];
      case 'baby_kids':
        return <String>['Tiny Steps', 'Happy Tots', 'Little Bloom', 'Kids Cove'][index];
      default:
        return 'Preview Brand';
    }
  }

  static String _brandNameBnFor(String categoryId, int localIndex) {
    final index = localIndex % 4;
    switch (categoryId) {
      case 'grocery':
        return <String>['ফ্রেশ বাস্কেট', 'ডেইলি হারভেস্ট', 'কিচেন সিলেক্ট', 'প্রাইম প্যান্ট্রি'][index];
      case 'fruits_vegetables':
        return <String>['ফার্ম পিক', 'গ্রীন ভ্যালি', 'ফ্রেশ রুট', 'নেচার হাব'][index];
      case 'personal_care':
        return <String>['পিওর গ্লো', 'সফট ব্লুম', 'কেয়ার নেস্ট', 'ডেইলি ফ্রেশ'][index];
      case 'electronics':
        return <String>['পালস টেক', 'ভোল্টিক্স', 'নোভা গিয়ার', 'আরবান কানেক্ট'][index];
      case 'home_kitchen':
        return <String>['হোমক্রাফট', 'কুকনেস্ট', 'এভরিডে লিভিং', 'আরবান কিচেন'][index];
      case 'baby_kids':
        return <String>['টিনি স্টেপস', 'হ্যাপি টটস', 'লিটল ব্লুম', 'কিডস কোভ'][index];
      default:
        return 'প্রিভিউ ব্র্যান্ড';
    }
  }

  static String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

class _PreviewProductTemplate {
  final String titleEn;
  final String titleBn;
  final double price;
  final String shortDescriptionEn;
  final String shortDescriptionBn;
  final String descriptionEn;
  final String descriptionBn;
  final String tag;
  final String keyword;

  const _PreviewProductTemplate(
      this.titleEn,
      this.titleBn,
      this.price,
      this.shortDescriptionEn,
      this.shortDescriptionBn,
      this.descriptionEn,
      this.descriptionBn,
      this.tag,
      this.keyword,
      );
}

class _QuantityMeta {
  final String quantityType;
  final double quantityValue;
  final String toleranceType;
  final double tolerance;
  final double? minOrderQty;
  final double? maxOrderQty;
  final double? stepQty;
  final String? unitLabelEn;
  final String? unitLabelBn;

  const _QuantityMeta({
    required this.quantityType,
    required this.quantityValue,
    required this.toleranceType,
    required this.tolerance,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.stepQty,
    required this.unitLabelEn,
    required this.unitLabelBn,
  });
}
