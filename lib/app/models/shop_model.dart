import 'package:silk_route/app/utils/constants.dart';

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String city;
  final String? pincode;
  final String phone;
  final String? gstNumber;
  final String? panNumber;
  final String status; // 'pending', 'approved', 'rejected'
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    this.pincode,
    required this.phone,
    this.gstNumber,
    this.panNumber,
    required this.status,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from JSON
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'],
      phone: json['phone'],
      gstNumber: json['gst_number'],
      panNumber: json['pan_number'],
      status: json['status'] ?? ShopStatus.pending.value,
      imageUrl: json['image_url'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'pincode': pincode,
      'phone': phone,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'status': status,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  ShopModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? pincode,
    String? phone,
    String? gstNumber,
    String? panNumber,
    String? status,
    String? imageUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if shop is approved
  bool get isApproved => status == ShopStatus.approved.value;
  
  // Check if shop is pending approval
  bool get isPending => status == ShopStatus.pending.value;
  
  // Check if shop is rejected
  bool get isRejected => status == ShopStatus.rejected.value;
}