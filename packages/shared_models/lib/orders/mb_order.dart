import 'dart:convert';

import 'mb_order_item.dart';

class MBOrder {
  final String id;
  final String userId;

  final String customerName;
  final String customerPhone;
  final String? customerEmail;

  final List<MBOrderItem> items;

  final double subTotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;

  final String paymentMethod;
  final String paymentStatus; // pending | paid | failed | refunded

  final String orderStatus;
  // pending | confirmed | processing | ready | out_for_delivery | delivered | cancelled

  final String orderType;
  // instant | scheduled | mixed

  final String? deliveryAddress;
  final String? note;

  final DateTime? scheduledFor;
  final String? scheduledShift;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MBOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.items,
    required this.subTotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.orderType,
    this.deliveryAddress,
    this.note,
    this.scheduledFor,
    this.scheduledShift,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MBOrder.empty() => MBOrder(
    id: '',
    userId: '',
    customerName: '',
    customerPhone: '',
    items: const [],
    subTotal: 0.0,
    deliveryFee: 0.0,
    discount: 0.0,
    totalAmount: 0.0,
    paymentMethod: 'cod',
    paymentStatus: 'pending',
    orderStatus: 'pending',
    orderType: 'instant',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  bool get isInstantOrder => orderType == 'instant';
  bool get isScheduledOrder => orderType == 'scheduled';
  bool get isMixedOrder => orderType == 'mixed';

  int get totalItemsCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  MBOrder copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    bool clearCustomerEmail = false,
    List<MBOrderItem>? items,
    double? subTotal,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? orderStatus,
    String? orderType,
    String? deliveryAddress,
    bool clearDeliveryAddress = false,
    String? note,
    bool clearNote = false,
    DateTime? scheduledFor,
    bool clearScheduledFor = false,
    String? scheduledShift,
    bool clearScheduledShift = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: clearCustomerEmail
          ? null
          : (customerEmail ?? this.customerEmail),
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      orderType: orderType ?? this.orderType,
      deliveryAddress: clearDeliveryAddress
          ? null
          : (deliveryAddress ?? this.deliveryAddress),
      note: clearNote ? null : (note ?? this.note),
      scheduledFor:
      clearScheduledFor ? null : (scheduledFor ?? this.scheduledFor),
      scheduledShift:
      clearScheduledShift ? null : (scheduledShift ?? this.scheduledShift),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'items': items.map((e) => e.toMap()).toList(),
      'subTotal': subTotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'orderType': orderType,
      'deliveryAddress': deliveryAddress,
      'note': note,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'scheduledShift': scheduledShift,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MBOrder.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBOrder.empty();

    return MBOrder(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      customerName: (map['customerName'] ?? '').toString(),
      customerPhone: (map['customerPhone'] ?? '').toString(),
      customerEmail: map['customerEmail']?.toString(),
      items: (map['items'] as List<dynamic>? ?? const [])
          .map((e) => MBOrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      subTotal: ((map['subTotal'] ?? 0) as num).toDouble(),
      deliveryFee: ((map['deliveryFee'] ?? 0) as num).toDouble(),
      discount: ((map['discount'] ?? 0) as num).toDouble(),
      totalAmount: ((map['totalAmount'] ?? 0) as num).toDouble(),
      paymentMethod: (map['paymentMethod'] ?? 'cod').toString(),
      paymentStatus: (map['paymentStatus'] ?? 'pending').toString(),
      orderStatus: (map['orderStatus'] ?? 'pending').toString(),
      orderType: (map['orderType'] ?? 'instant').toString(),
      deliveryAddress: map['deliveryAddress']?.toString(),
      note: map['note']?.toString(),
      scheduledFor: map['scheduledFor'] == null
          ? null
          : DateTime.tryParse(map['scheduledFor'].toString()),
      scheduledShift: map['scheduledShift']?.toString(),
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      updatedAt: map['updatedAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MBOrder.fromJson(String source) =>
      MBOrder.fromMap(json.decode(source) as Map<String, dynamic>);
}











