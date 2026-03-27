import 'dart:convert';

import '../catalog/mb_cart_item.dart';

class MBOrderItem {
  final String productId;
  final String titleEn;
  final String titleBn;

  final int quantity;

  final double unitPrice;
  final double totalPrice;

  final String orderType; // instant | scheduled
  final DateTime? deliveryDate;
  final String? deliveryShift;

  final bool isEstimatedPrice;
  final double? finalUnitPrice;

  final String? imageUrl;
  final String? variationId;

  const MBOrderItem({
    required this.productId,
    required this.titleEn,
    required this.titleBn,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.orderType,
    this.deliveryDate,
    this.deliveryShift,
    this.isEstimatedPrice = false,
    this.finalUnitPrice,
    this.imageUrl,
    this.variationId,
  });

  factory MBOrderItem.empty() => const MBOrderItem(
    productId: '',
    titleEn: '',
    titleBn: '',
    quantity: 0,
    unitPrice: 0.0,
    totalPrice: 0.0,
    orderType: 'instant',
  );

  factory MBOrderItem.fromCartItem(MBCartItem item) {
    return MBOrderItem(
      productId: item.productId,
      titleEn: item.titleEn,
      titleBn: item.titleBn,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.total,
      orderType: item.purchaseMode,
      deliveryDate: item.selectedDate,
      deliveryShift: item.selectedShift,
      isEstimatedPrice: item.isEstimatedPrice,
      finalUnitPrice: item.finalUnitPrice,
      imageUrl: item.imageUrl,
      variationId: item.variationId,
    );
  }

  double get effectiveUnitPrice => finalUnitPrice ?? unitPrice;

  bool get isScheduled => orderType == 'scheduled';

  bool get isInstant => orderType == 'instant';

  MBOrderItem copyWith({
    String? productId,
    String? titleEn,
    String? titleBn,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? orderType,
    DateTime? deliveryDate,
    bool clearDeliveryDate = false,
    String? deliveryShift,
    bool clearDeliveryShift = false,
    bool? isEstimatedPrice,
    double? finalUnitPrice,
    bool clearFinalUnitPrice = false,
    String? imageUrl,
    bool clearImageUrl = false,
    String? variationId,
    bool clearVariationId = false,
  }) {
    return MBOrderItem(
      productId: productId ?? this.productId,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      orderType: orderType ?? this.orderType,
      deliveryDate:
      clearDeliveryDate ? null : (deliveryDate ?? this.deliveryDate),
      deliveryShift:
      clearDeliveryShift ? null : (deliveryShift ?? this.deliveryShift),
      isEstimatedPrice: isEstimatedPrice ?? this.isEstimatedPrice,
      finalUnitPrice: clearFinalUnitPrice
          ? null
          : (finalUnitPrice ?? this.finalUnitPrice),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      variationId:
      clearVariationId ? null : (variationId ?? this.variationId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'orderType': orderType,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryShift': deliveryShift,
      'isEstimatedPrice': isEstimatedPrice,
      'finalUnitPrice': finalUnitPrice,
      'imageUrl': imageUrl,
      'variationId': variationId,
    };
  }

  factory MBOrderItem.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBOrderItem.empty();

    return MBOrderItem(
      productId: (map['productId'] ?? '').toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? (map['quantity'] ?? 0) as int
          : int.tryParse((map['quantity'] ?? '0').toString()) ?? 0,
      unitPrice: ((map['unitPrice'] ?? 0) as num).toDouble(),
      totalPrice: ((map['totalPrice'] ?? 0) as num).toDouble(),
      orderType: (map['orderType'] ?? 'instant').toString(),
      deliveryDate: map['deliveryDate'] == null
          ? null
          : DateTime.tryParse(map['deliveryDate'].toString()),
      deliveryShift: map['deliveryShift']?.toString(),
      isEstimatedPrice: map['isEstimatedPrice'] ?? false,
      finalUnitPrice: map['finalUnitPrice'] == null
          ? null
          : ((map['finalUnitPrice'] as num).toDouble()),
      imageUrl: map['imageUrl']?.toString(),
      variationId: map['variationId']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBOrderItem.fromJson(String source) =>
      MBOrderItem.fromMap(json.decode(source) as Map<String, dynamic>);
}











