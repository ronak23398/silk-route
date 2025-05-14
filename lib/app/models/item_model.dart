class ItemModel {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? category;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ItemModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.category,
    this.isAvailable = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      stock: json['stock'] != null ? int.parse(json['stock'].toString()) : 0,
      imageUrl: json['image_url'],
      category: json['category'],
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  ItemModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if the item is in stock
  bool get hasStock => stock > 0 && isAvailable;
}