import 'package:cloud_firestore/cloud_firestore.dart';

class MobileAdminPurchaseModel {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String place;
  final String sellerName;
  final String sellerNumber;
  final String purchasedBy;
  final DateTime purchaseDate;
  final String status;
  final String paymentMethod;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdByUid;
  final String updatedByUid;

  const MobileAdminPurchaseModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.place,
    required this.sellerName,
    required this.sellerNumber,
    required this.purchasedBy,
    required this.purchaseDate,
    this.status = 'completed',
    this.paymentMethod = 'cash',
    this.notes = '',
    this.createdAt,
    this.updatedAt,
    this.createdByUid = '',
    this.updatedByUid = '',
  });

  double get totalAmount => quantity * unitPrice;

  static MobileAdminPurchaseModel empty() {
    return MobileAdminPurchaseModel(
      id: '',
      productName: '',
      quantity: 1,
      unitPrice: 0,
      place: '',
      sellerName: '',
      sellerNumber: '',
      purchasedBy: '',
      purchaseDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName.trim(),
      'productNameLower': productName.trim().toLowerCase(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'place': place.trim(),
      'placeLower': place.trim().toLowerCase(),
      'sellerName': sellerName.trim(),
      'sellerNameLower': sellerName.trim().toLowerCase(),
      'sellerNumber': sellerNumber.trim(),
      'purchasedBy': purchasedBy.trim(),
      'purchasedByLower': purchasedBy.trim().toLowerCase(),
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'status': status.trim().toLowerCase(),
      'paymentMethod': paymentMethod.trim().toLowerCase(),
      'notes': notes.trim(),
      'createdByUid': createdByUid,
      'updatedByUid': updatedByUid,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory MobileAdminPurchaseModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    final purchaseDateRaw = map['purchaseDate'];
    final createdAtRaw = map['createdAt'];
    final updatedAtRaw = map['updatedAt'];

    return MobileAdminPurchaseModel(
      id: id,
      productName: (map['productName'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? (map['quantity'] ?? 0) as int
          : int.tryParse((map['quantity'] ?? '0').toString()) ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      place: (map['place'] ?? '').toString(),
      sellerName: (map['sellerName'] ?? '').toString(),
      sellerNumber: (map['sellerNumber'] ?? '').toString(),
      purchasedBy: (map['purchasedBy'] ?? '').toString(),
      purchaseDate: purchaseDateRaw is Timestamp
          ? purchaseDateRaw.toDate()
          : DateTime.tryParse((purchaseDateRaw ?? '').toString()) ??
          DateTime.now(),
      status: (map['status'] ?? 'completed').toString(),
      paymentMethod: (map['paymentMethod'] ?? 'cash').toString(),
      notes: (map['notes'] ?? '').toString(),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse((createdAtRaw ?? '').toString()),
      updatedAt: updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.tryParse((updatedAtRaw ?? '').toString()),
      createdByUid: (map['createdByUid'] ?? '').toString(),
      updatedByUid: (map['updatedByUid'] ?? '').toString(),
    );
  }

  MobileAdminPurchaseModel copyWith({
    String? id,
    String? productName,
    int? quantity,
    double? unitPrice,
    String? place,
    String? sellerName,
    String? sellerNumber,
    String? purchasedBy,
    DateTime? purchaseDate,
    String? status,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByUid,
    String? updatedByUid,
  }) {
    return MobileAdminPurchaseModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      place: place ?? this.place,
      sellerName: sellerName ?? this.sellerName,
      sellerNumber: sellerNumber ?? this.sellerNumber,
      purchasedBy: purchasedBy ?? this.purchasedBy,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUid: createdByUid ?? this.createdByUid,
      updatedByUid: updatedByUid ?? this.updatedByUid,
    );
  }
}