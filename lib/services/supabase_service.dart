import 'dart:io';

import 'package:silk_route/app/models/item_model.dart';
import 'package:silk_route/app/models/order_model.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/models/user_model.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class SupabaseService {
  // Get Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get current authenticated user
  Future<UserModel?> getCurrentUser() async {
    final User? authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;
    
    return await getUserProfile(authUser.id);
  }
  
  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(Constants.usersTable)
          .select()
          .eq('id', userId)
          .single();
      
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  // Authentication methods
  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Create user profile in the database
        await _supabase.from(Constants.usersTable).insert({
          'id': response.user!.id,
          'email': email,
          'full_name': name,
          'role': 'customer', // Default role or specify as needed
          'created_at': DateTime.now().toIso8601String(),
        });
        
        // Return the UserModel from the created profile
        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow; // Make sure to throw the error for proper handling
    }
  }
  
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Update last login
        await _supabase.from(Constants.usersTable).update({
          'last_login': DateTime.now().toIso8601String(),
        }).eq('id', response.user!.id);
        
        // Return the user profile instead of auth user
        return await getUserProfile(response.user!.id);
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }
  
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
  
  // Shop methods
  Future<ShopModel?> fetchShopByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(Constants.shopsTable)
          .select()
          .eq('owner_id', userId)
          .single();
      
      if (response != null) {
        return ShopModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching shop: $e');
      return null;
    }
  }
  
  // ADDED METHOD: Fetch shops by status
  Future<List<ShopModel>> fetchShopsByStatus(String status) async {
    try {
      final response = await _supabase
          .from(Constants.shopsTable)
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((shop) => ShopModel.fromJson(shop)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in fetchShopsByStatus: $e');
      return [];
    }
  }
  
  // ADDED METHOD: Fetch all shops
  Future<List<ShopModel>> fetchAllShops() async {
    try {
      final response = await _supabase
          .from(Constants.shopsTable)
          .select()
          .order('created_at', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((shop) => ShopModel.fromJson(shop)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in fetchAllShops: $e');
      return [];
    }
  }
  
  // ADDED METHOD: Update shop status
  Future<bool> updateShopStatus(String shopId, String status) async {
    try {
      await _supabase
          .from(Constants.shopsTable)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shopId);
      
      return true;
    } catch (e) {
      debugPrint('Error in updateShopStatus: $e');
      return false;
    }
  }
  
  Future<ShopModel?> submitKYC(
    ShopModel shop, {
    required String shopImagePath,
    required String idProofPath,
    required String businessLicensePath,
  }) async {
    try {
      String? shopImageUrl;
      String? idProofUrl;
      String? businessLicenseUrl;
      
      // Upload shop image
      if (shopImagePath.isNotEmpty) {
        final imagePath = 'shops/${shop.ownerId}/shop_image.jpg';
        shopImageUrl = await uploadImage(shopImagePath, imagePath);
      }
      
      // Upload ID proof
      if (idProofPath.isNotEmpty) {
        final imagePath = 'shops/${shop.ownerId}/id_proof.jpg';
        idProofUrl = await uploadImage(idProofPath, imagePath);
      }
      
      // Upload business license
      if (businessLicensePath.isNotEmpty) {
        final imagePath = 'shops/${shop.ownerId}/business_license.jpg';
        businessLicenseUrl = await uploadImage(businessLicensePath, imagePath);
      }
      
      // Check if shop already exists
      final existingShop = await fetchShopByUserId(shop.ownerId);
      ShopModel updatedShop;
      
      if (existingShop != null) {
        // Update existing shop
        updatedShop = existingShop.copyWith(
          name: shop.name,
          description: shop.description,
          address: shop.address,
          city: shop.city,
          phone: shop.phone,
          status: ShopStatus.pending.value,
          imageUrl: shopImageUrl ?? existingShop.imageUrl,
          updatedAt: DateTime.now(),
        );
        
        await _supabase
            .from(Constants.shopsTable)
            .update(updatedShop.toJson())
            .eq('id', existingShop.id);
            
        // Store document URLs in a separate table if needed
        // ...
        
        return updatedShop;
      } else {
        // Create new shop
        final uuid = const Uuid();
        final newShop = shop.copyWith(
          id: uuid.v4(),
          status: ShopStatus.pending.value,
          createdAt: DateTime.now(),
          imageUrl: shopImageUrl,
        );
        
        await _supabase
            .from(Constants.shopsTable)
            .insert(newShop.toJson());
            
        // Store document URLs in a separate table if needed
        // ...
        
        return newShop;
      }
    } catch (e) {
      print('Error submitting KYC: $e');
      return null;
    }
  }
  
  // Product catalog methods
  Future<List<ItemModel>> fetchItemsByShopId(String shopId) async {
    try {
      final response = await _supabase
          .from(Constants.itemsTable)
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((item) => ItemModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }
  
  Future<bool> addItemToCatalog(ItemModel item) async {
    try {
      final uuid = const Uuid();
      final newItem = item.copyWith(
        id: uuid.v4(),
        createdAt: DateTime.now(),
      );
      
      await _supabase.from(Constants.itemsTable).insert(newItem.toJson());
      return true;
    } catch (e) {
      print('Error adding item: $e');
      return false;
    }
  }
  
  Future<bool> updateItemInCatalog(ItemModel item) async {
    try {
      final updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from(Constants.itemsTable)
          .update(updatedItem.toJson())
          .eq('id', item.id);
      
      return true;
    } catch (e) {
      print('Error updating item: $e');
      return false;
    }
  }
  
  Future<bool> deleteItem(String itemId) async {
    try {
      await _supabase.from(Constants.itemsTable).delete().eq('id', itemId);
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }
  
  // ADDED METHOD: Fetch all users
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final response = await _supabase
          .from(Constants.usersTable)
          .select()
          .order('created_at', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((user) => UserModel.fromJson(user)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in fetchAllUsers: $e');
      return [];
    }
  }
  
  // ADDED METHOD: Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _supabase
          .from(Constants.usersTable)
          .update({
            'role': newRole,
          })
          .eq('id', userId);
      
      return true;
    } catch (e) {
      debugPrint('Error in updateUserRole: $e');
      return false;
    }
  }
  
  // Order management methods
  Future<List<OrderModel>> fetchOrdersForShop(String shopId, {String? status}) async {
    try {
      var query = _supabase
          .from(Constants.ordersTable)
          .select('*, items:order_items(*)')
          .eq('shop_id', shopId);
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((order) => OrderModel.fromJson(order)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
  
  // ADDED METHOD: Fetch recent orders
  Future<List<OrderModel>> fetchRecentOrders({int limit = 50}) async {
    try {
      final response = await _supabase
          .from(Constants.ordersTable)
          .select('*, items:order_items(*)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      if (response != null && response.isNotEmpty) {
        return (response as List).map((order) => OrderModel.fromJson(order)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in fetchRecentOrders: $e');
      return [];
    }
  }
  
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status,
      };
      
      // Add timestamps based on status
      if (status == OrderStatus.accepted.value) {
        updateData['accepted_at'] = DateTime.now().toIso8601String();
      } else if (status == OrderStatus.delivered.value) {
        updateData['delivered_at'] = DateTime.now().toIso8601String();
      }
      
      await _supabase
          .from(Constants.ordersTable)
          .update(updateData)
          .eq('id', orderId);
      
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  
  // ADDED METHOD: Fetch analytics summary
  Future<Map<String, dynamic>> fetchAnalyticsSummary() async {
    try {
      // Get total revenue from all orders
      final revenueResponse = await _supabase
          .from(Constants.ordersTable)
          .select('total_amount')
          .eq('payment_status', 'paid');
      
      double totalRevenue = 0.0;
      if (revenueResponse != null && revenueResponse.isNotEmpty) {
        for (var order in revenueResponse) {
          totalRevenue += order['total_amount'] as double;
        }
      }
      
      // Get total orders count - fixed count query
      final ordersCountResponse = await _supabase
          .from(Constants.ordersTable)
          .select();
      
      final int totalOrders = ordersCountResponse.length;
      
      // Get active shops count - fixed count query
      final shopsCountResponse = await _supabase
          .from(Constants.shopsTable)
          .select()
          .eq('status', ShopStatus.approved.value);
      
      final int activeShops = shopsCountResponse.length;
      
      // Get new users in the last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final newUsersResponse = await _supabase
          .from(Constants.usersTable)
          .select()
          .gte('created_at', thirtyDaysAgo.toIso8601String());
      
      final int newUsers = newUsersResponse.length;
      
      // You could calculate growth metrics by comparing with previous periods
      // This is a simplified mock implementation
      final revenueGrowth = 15.7;  // Example value
      final ordersGrowth = 8.2;    // Example value
      final shopsGrowth = 5.4;     // Example value
      final usersGrowth = 12.1;    // Example value
      
      return {
        'total_revenue': totalRevenue,
        'total_orders': totalOrders,
        'active_shops': activeShops,
        'new_users': newUsers,
        'revenue_growth': revenueGrowth,
        'orders_growth': ordersGrowth,
        'shops_growth': shopsGrowth,
        'users_growth': usersGrowth,
      };
      
    } catch (e) {
      debugPrint('Error in fetchAnalyticsSummary: $e');
      return {
        'total_revenue': 0.0,
        'total_orders': 0,
        'active_shops': 0,
        'new_users': 0,
        'revenue_growth': 0.0,
        'orders_growth': 0.0,
        'shops_growth': 0.0,
        'users_growth': 0.0,
      };
    }
  }
  
  // ADDED METHOD: Fetch daily sales data
  Future<List<Map<String, dynamic>>> fetchDailySalesData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // This query would typically use SQL's date functions
      // For simplicity, we'll fetch all orders in the date range and process them in Dart
      
      final response = await _supabase
          .from(Constants.ordersTable)
          .select('created_at, total_amount, payment_status')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .eq('payment_status', 'paid');
      
      if (response == null || response.isEmpty) {
        return [];
      }
      
      // Group orders by date and sum the total amount
      final Map<String, double> dailySales = {};
      
      for (var order in response) {
        final createdAt = DateTime.parse(order['created_at']);
        final dateString = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        
        if (dailySales.containsKey(dateString)) {
          dailySales[dateString] = (dailySales[dateString] ?? 0) + (order['total_amount'] as num).toDouble();
        } else {
          dailySales[dateString] = (order['total_amount'] as num).toDouble();
        }
      }
      
      // Convert to list of maps
      final List<Map<String, dynamic>> result = [];
      dailySales.forEach((date, revenue) {
        result.add({
          'date': date,
          'revenue': revenue,
        });
      });
      
      // Sort by date
      result.sort((a, b) => a['date'].compareTo(b['date']));
      
      return result;
    } catch (e) {
      debugPrint('Error in fetchDailySalesData: $e');
      return [];
    }
  }
  
  // ADDED METHOD: Fetch shop category distribution
  Future<List<Map<String, dynamic>>> fetchShopCategoryDistribution() async {
    try {
      // For this example, we'll count shops by city as a proxy for category distribution
      // In a real implementation, you'd have a category field in your shops table
      
      final response = await _supabase
          .from(Constants.shopsTable)
          .select('city')
          .eq('status', ShopStatus.approved.value);
      
      if (response == null || response.isEmpty) {
        return [];
      }
      
      // Count shops by city
      final Map<String, int> categoryCounts = {};
      
      for (var shop in response) {
        final city = shop['city'] as String;
        categoryCounts[city] = (categoryCounts[city] ?? 0) + 1;
      }
      
      // Convert to list of maps
      final List<Map<String, dynamic>> result = [];
      categoryCounts.forEach((category, count) {
        result.add({
          'category': category,
          'count': count,
        });
      });
      
      return result;
    } catch (e) {
      debugPrint('Error in fetchShopCategoryDistribution: $e');
      return [];
    }
  }
  
  // Storage methods for images
  Future<String?> uploadImage(String filePath, String destination) async {
    try {
      final file = File(filePath);
      await _supabase.storage.from('shop_connect').upload(
        destination, 
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true)
      );
      
      // Get public URL for the uploaded file
      final imageUrl = _supabase.storage.from('shop_connect').getPublicUrl(destination);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add this method to the SupabaseService class
// Updated updateUserActiveStatus method for SupabaseService class
Future<bool> updateUserActiveStatus(String userId, bool isActive) async {
  try {
    // Update the is_active status in your users table
    await _supabase
        .from('users')
        .update({'is_active': isActive})
        .eq('id', userId);
    
    // If you need additional logic for disabling users, you'd implement it here
    // For example, you might have a serverless function that handles admin operations
    
    return true;
  } catch (e) {
    debugPrint('Error updating user active status: ${e.toString()}');
    return false;
  }
}

// Updated deleteUser method for SupabaseService class
Future<bool> deleteUser(String userId) async {
  try {
    // First check if the user is a shop owner and has shops
    final shopResponse = await _supabase
        .from('shops')
        .select()
        .eq('owner_id', userId);
    
    if (shopResponse != null && shopResponse.isNotEmpty) {
      // User has shops, delete them first
      for (var shop in shopResponse) {
        final String shopId = shop['id'];
        
        // Delete products associated with the shop
        await _supabase
            .from('products')
            .delete()
            .eq('shop_id', shopId);
        
        // Delete shop
        await _supabase
            .from('shops')
            .delete()
            .eq('id', shopId);
      }
    }
    
    // Delete orders associated with the user
    await _supabase
        .from('orders')
        .delete()
        .eq('user_id', userId);
    
    // Delete user's cart items
    await _supabase
        .from('cart_items')
        .delete()
        .eq('user_id', userId);
    
    // Delete user's addresses
    await _supabase
        .from('addresses')
        .delete()
        .eq('user_id', userId);
    
    // Delete user's wishlist items
    await _supabase
        .from('wishlists')
        .delete()
        .eq('user_id', userId);
    
    // Finally delete the user from your users table
    await _supabase
        .from('users')
        .delete()
        .eq('id', userId);
    
    // Note: For actual user authentication deletion, you would typically need to:
    // 1. Either use a Supabase Edge Function with admin rights
    // 2. Or implement a server-side function to handle this
    // As direct deletion via client is restricted for security
    
    return true;
  } catch (e) {
    debugPrint('Error deleting user: ${e.toString()}');
    return false;
  }
}

String? getDocumentUrl(String userId, DocumentType type) {
  try {
    String path = '';
    switch (type) {
      case DocumentType.ID_PROOF:
        path = 'shops/$userId/id_proof.jpg';
        break;
      case DocumentType.BUSINESS_LICENSE:
        path = 'shops/$userId/business_license.jpg';
        break;
      // Add other document types as needed
    }
    
    if (path.isEmpty) return null;
    
    // Get public URL for the file
    return _supabase.storage.from('shop_connect').getPublicUrl(path);
  } catch (e) {
    debugPrint('Error getting document URL: $e');
    return null;
  }
}

}