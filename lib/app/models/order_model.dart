import 'package:silk_route/app/utils/constants.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String shopId;
  final String status;
  final double totalAmount;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? customerName;
  final String? paymentMethod;
  final String? paymentStatus; // 'pending', 'paid', 'failed'
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.status,
    required this.totalAmount,
    this.deliveryAddress,
    this.customerPhone,
    this.customerName,
    this.paymentMethod,
    this.paymentStatus,
    required this.items,
    required this.createdAt,
    this.acceptedAt,
    this.deliveredAt,
  });

  // Create from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      shopId: json['shop_id'] ?? '',
      status: json['status'] ?? OrderStatus.pending.value,
      totalAmount: json['total_amount'] != null ? double.parse(json['total_amount'].toString()) : 0.0,
      deliveryAddress: json['delivery_address'],
      customerPhone: json['customer_phone'],
      customerName: json['customer_name'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      items: orderItems,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'shop_id': shopId,
      'status': status,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? shopId,
    String? status,
    double? totalAmount,
    String? deliveryAddress,
    String? customerPhone,
    String? customerName,
    String? paymentMethod,
    String? paymentStatus,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  // Check if order is pending
  bool get isPending => status == OrderStatus.pending.value;
  
  // Check if order is accepted
  bool get isAccepted => status == OrderStatus.accepted.value;
  
  // Check if order is in progress
  bool get isInProgress => status == OrderStatus.inProgress.value;
  
  // Check if order is delivered
  bool get isDelivered => status == OrderStatus.delivered.value;
  
  // Check if order is cancelled
  bool get isCancelled => status == OrderStatus.cancelled.value;
  
  // Count total items in the order
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class OrderItem {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  
  OrderItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
  
  // Create from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      itemId: json['item_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      quantity: json['quantity'] != null ? int.parse(json['quantity'].toString()) : 0,
      imageUrl: json['image_url'],
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
  
  // Calculate subtotal
  double get subtotal => price * quantity;
}