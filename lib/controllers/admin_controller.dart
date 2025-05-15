import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/order_model.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/models/user_model.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:silk_route/controllers/auth_controllers.dart';

class AdminController extends GetxController with GetTickerProviderStateMixin {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  // Observable states
  final RxList<ShopModel> shops = <ShopModel>[].obs;
  final RxList<ShopModel> filteredShops = <ShopModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  
  // Loading states
  final RxBool isLoading = true.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingShops = false.obs;
  final RxBool isLoadingPendingShops = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isLoadingAnalytics = false.obs;
  final RxBool isProcessing = false.obs;
  
  // Data
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxList<ShopModel> allShops = <ShopModel>[].obs;
  final RxList<ShopModel> pendingShops = <ShopModel>[].obs;
  final RxList<ShopModel> topShops = <ShopModel>[].obs;
  
  // Analytics data
  final RxMap<String, dynamic> analytics = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> dailySalesData = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> shopCategoryData = <Map<String, dynamic>>[].obs;
  final RxMap<String, int> orderStatusData = <String, int>{}.obs;
  
  // Analytics models
  final RxList<DailyRevenueData> dailyRevenue = <DailyRevenueData>[].obs;
  final RxList<OrderStatusData> orderStatusDistribution = <OrderStatusData>[].obs;
  final RxList<ShopCategoryData> shopCategoryDistribution = <ShopCategoryData>[].obs;
  final RxList<UserGrowthData> userGrowthData = <UserGrowthData>[].obs;
  final RxList<TopShopData> topShopsData = <TopShopData>[].obs;
  
  // Analytics metrics
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt activeShops = 0.obs;
  final RxInt newUsers = 0.obs;
  final RxDouble revenueGrowth = 0.0.obs;
  final RxDouble ordersGrowth = 0.0.obs;
  final RxDouble shopsGrowth = 0.0.obs;
  final RxDouble usersGrowth = 0.0.obs;
  
  // Date range for analytics
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxString selectedTimeframe = 'Last 30 Days'.obs;
  
  // Tab controller for the dashboard
  late TabController tabController;
  
  // Filter states
  final RxString shopStatusFilter = ShopStatus.pending.value.obs;
  final RxString selectedShopStatus = ''.obs;
  final RxInt pendingShopCount = 0.obs;
  final RxString userRoleFilter = ''.obs;

  final searchController = TextEditingController();
  final RxString selectedUserRole = ''.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt customerCount = 0.obs;
  final RxInt shopOwnerCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    fetchAllShops();
    fetchPendingShops();
    fetchAllUsers();
    loadAnalytics();
  }

  // Add this in onClose() to dispose the controller
  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }
  
  // Fetch all pending shop applications
  Future<void> fetchPendingShops() async {
    isLoadingPendingShops.value = true;
    
    final response = await _supabaseService.fetchShopsByStatus(ShopStatus.pending.value);
    pendingShops.clear();
    pendingShops.addAll(response);
    isLoadingPendingShops.value = false;
  }
  
  // Fetch all shops
  Future<void> fetchAllShops() async {
    isLoadingShops.value = true;
    
    final response = await _supabaseService.fetchAllShops();
    allShops.clear();
    allShops.addAll(response);
    filteredShops.clear();
    filteredShops.addAll(response);
    pendingShopCount.value = response.where((shop) => shop.status == 'pending').length;
    isLoadingShops.value = false;
  }
  
  // Fetch users
  Future<void> fetchUsers() async {
    isLoadingUsers.value = true;
    
    final usersList = await _supabaseService.fetchAllUsers();
    users.clear();
    users.addAll(usersList);
    isLoadingUsers.value = false;
  }
  
  // Fetch recent orders
  Future<void> fetchRecentOrders() async {
    isLoadingOrders.value = true;
    
    final ordersList = await _supabaseService.fetchRecentOrders();
    recentOrders.clear();
    recentOrders.addAll(ordersList);
    
    // Process order status data for analytics
    orderStatusData.clear();
    orderStatusData.addAll({
      OrderStatus.pending.value: 0,
      OrderStatus.accepted.value: 0,
      OrderStatus.inProgress.value: 0,
      OrderStatus.delivered.value: 0,
      OrderStatus.cancelled.value: 0,
    });
    
    for (var order in ordersList) {
      if (orderStatusData.containsKey(order.status)) {
        orderStatusData[order.status] = (orderStatusData[order.status] ?? 0) + 1;
      }
    }
    isLoadingOrders.value = false;
  }
  
  // Load analytics data
  Future<void> loadAnalytics() async {
    isLoadingAnalytics.value = true;
    
    // Fetch data for the current date range
    final start = startDate.value;
    final end = endDate.value;
    
    // Fetch order data for revenue and status distribution
    final orders = await _supabaseService.fetchOrdersByDateRange(start, end);
    
    // Calculate total revenue and orders
    double revenue = 0.0;
    for (var order in orders) {
      revenue += order.totalAmount;
    }
    totalRevenue.value = revenue;
    totalOrders.value = orders.length;
    
    // Process order status distribution
    Map<String, int> statusCounts = {
      'pending': 0,
      'processing': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0
    };
    for (var order in orders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }
    orderStatusData.clear();
    orderStatusData.addAll(statusCounts);
    orderStatusDistribution.clear();
    orderStatusDistribution.addAll(statusCounts.entries
        .map((e) => OrderStatusData(status: e.key, count: e.value))
        .toList());
    
    // Fetch shop data
    final response = await _supabaseService.fetchAllShops();
    final shopsList = <dynamic>[];
    shopsList.addAll(response);
    activeShops.value = shopsList.where((shop) {
      if (shop is Map<dynamic, dynamic>) {
        return shop['status'] == 'approved';
      }
      return false;
    }).length;
    
    // Process shop category distribution
    Map<String, int> categoryCounts = {};
    for (var shopData in shopsList) {
      // Directly access raw data from the response
      String category = 'Unknown';
      if (shopData is Map<dynamic, dynamic>) {
        category = (shopData['shop_category'] as String?) ?? (shopData['category'] as String?) ?? 'Unknown';
      }
      if (category.isNotEmpty) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }
    shopCategoryDistribution.clear();
    shopCategoryDistribution.addAll(categoryCounts.entries
        .map((e) => ShopCategoryData(category: e.key, count: e.value))
        .toList());
    
    // Fetch user data for growth metrics
    final usersList = await _supabaseService.fetchAllUsers();
    newUsers.value = usersList.where((user) => 
        user.createdAt.isAfter(start) && user.createdAt.isBefore(end)).length;
    
    // Process user growth data - group by date
    Map<DateTime, Map<String, int>> userGrowthByDate = {};
    for (var user in usersList) {
      // Truncate time information, keep only date
      DateTime userDate = DateTime(user.createdAt.year, user.createdAt.month, user.createdAt.day);
      if (userDate.isAfter(start.subtract(const Duration(days: 1))) && userDate.isBefore(end.add(const Duration(days: 1)))) {
        if (!userGrowthByDate.containsKey(userDate)) {
          userGrowthByDate[userDate] = {'customer': 0, 'shop_owner': 0};
        }
        if (user.role == 'customer') {
          userGrowthByDate[userDate]!['customer'] = userGrowthByDate[userDate]!['customer']! + 1;
        } else if (user.role == 'shop_owner') {
          userGrowthByDate[userDate]!['shop_owner'] = userGrowthByDate[userDate]!['shop_owner']! + 1;
        }
      }
    }
    
    // Convert to list and sort by date
    var sortedDates = userGrowthByDate.keys.toList()..sort();
    userGrowthData.clear();
    userGrowthData.addAll(sortedDates.map((date) => 
        UserGrowthData(
          date: date, 
          customers: userGrowthByDate[date]!['customer']!, 
          shopOwners: userGrowthByDate[date]!['shop_owner']!)
        ).toList());
    
    // Process top shops based on order revenue
    Map<String, Map<String, dynamic>> shopPerformance = {};
    for (var order in orders) {
      // Find the shop in the raw data list
      dynamic shop = shopsList.firstWhere((s) {
        if (s is Map<dynamic, dynamic>) {
          return s['id'] == order.shopId;
        }
        return false;
      }, orElse: () => {
        'id': order.shopId,
        'name': 'Unknown Shop',
        'city': 'Unknown',
        'shop_category': 'Unknown'
      });
      String category = 'Unknown';
      String name = 'Unknown Shop';
      String city = 'Unknown';
      if (shop is Map<dynamic, dynamic>) {
        category = (shop['shop_category'] as String?) ?? (shop['category'] as String?) ?? 'Unknown';
        name = (shop['name'] as String?) ?? 'Unknown Shop';
        city = (shop['city'] as String?) ?? 'Unknown';
      }
      if (!shopPerformance.containsKey(order.shopId)) {
        shopPerformance[order.shopId] = {
          'name': name,
          'category': category,
          'city': city,
          'revenue': 0.0,
          'orders': 0
        };
      }
      shopPerformance[order.shopId]!['revenue'] += order.totalAmount;
      shopPerformance[order.shopId]!['orders'] += 1;
    }
    
    // Convert to list and sort by revenue
    var sortedShops = shopPerformance.entries.toList()
      ..sort((a, b) => b.value['revenue'].compareTo(a.value['revenue']));
    topShopsData.clear();
    topShopsData.addAll(sortedShops.take(5).map((entry) => 
        TopShopData(
          id: entry.key,
          name: entry.value['name'],
          category: entry.value['category'],
          city: entry.value['city'],
          revenue: entry.value['revenue'],
          orders: entry.value['orders'])
        ).toList());
    
    // Process daily revenue data
    Map<DateTime, double> dailyRevenueMap = {};
    for (var order in orders) {
      DateTime orderDate = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      if (orderDate.isAfter(start.subtract(const Duration(days: 1))) && orderDate.isBefore(end.add(const Duration(days: 1)))) {
        dailyRevenueMap[orderDate] = (dailyRevenueMap[orderDate] ?? 0.0) + order.totalAmount;
      }
    }
    var sortedRevenueDates = dailyRevenueMap.keys.toList()..sort();
    dailyRevenue.clear();
    dailyRevenue.addAll(sortedRevenueDates.map((date) => 
        DailyRevenueData(date: date, revenue: dailyRevenueMap[date]!)).toList());
    
    // Calculate growth metrics (simplified, comparing halves of the selected period)
    if (orders.isNotEmpty && start.difference(end).inDays.abs() > 1) {
      final midPoint = start.add(Duration(days: (end.difference(start).inDays / 2).round()));
      final firstHalfOrders = orders.where((o) => o.createdAt.isBefore(midPoint)).toList();
      final secondHalfOrders = orders.where((o) => o.createdAt.isAfter(midPoint) || o.createdAt.isAtSameMomentAs(midPoint)).toList();
      
      double firstHalfRevenue = firstHalfOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
      double secondHalfRevenue = secondHalfOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
      
      if (firstHalfRevenue > 0) {
        revenueGrowth.value = ((secondHalfRevenue - firstHalfRevenue) / firstHalfRevenue) * 100;
      } else if (secondHalfRevenue > 0) {
        revenueGrowth.value = 100.0;
      }
      
      int firstHalfOrderCount = firstHalfOrders.length;
      int secondHalfOrderCount = secondHalfOrders.length;
      if (firstHalfOrderCount > 0) {
        ordersGrowth.value = ((secondHalfOrderCount - firstHalfOrderCount) / firstHalfOrderCount) * 100;
      } else if (secondHalfOrderCount > 0) {
        ordersGrowth.value = 100.0;
      }
      
      // Similar calculation for shops and users can be implemented if we store historical data
      shopsGrowth.value = 0.0; // Placeholder - requires historical data
      usersGrowth.value = 0.0; // Placeholder - requires historical data
    } else {
      revenueGrowth.value = 0.0;
      ordersGrowth.value = 0.0;
      shopsGrowth.value = 0.0;
      usersGrowth.value = 0.0;
    }
    isLoadingAnalytics.value = false;
  }

  // Refresh analytics data
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  // Update analytics date range
  void updateDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadAnalytics();
  }

  // Update analytics timeframe
  void updateAnalyticsTimeframe() {
    switch (selectedTimeframe.value) {
      case 'Today':
        startDate.value = DateTime.now();
        endDate.value = DateTime.now();
        break;
      case 'Yesterday':
        startDate.value = DateTime.now().subtract(const Duration(days: 1));
        endDate.value = DateTime.now().subtract(const Duration(days: 1));
        break;
      case 'Last 7 Days':
        startDate.value = DateTime.now().subtract(const Duration(days: 7));
        endDate.value = DateTime.now();
        break;
      case 'Last 30 Days':
        startDate.value = DateTime.now().subtract(const Duration(days: 30));
        endDate.value = DateTime.now();
        break;
      case 'This Month':
        final now = DateTime.now();
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'Last Month':
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate.value = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate.value = DateTime(now.year, now.month, 0); // Last day of previous month
        break;
      // 'Custom Range' case is handled by the date picker directly
    }
    
    loadAnalytics();
  }

  // Navigate to shop details
  void goToShopDetails(String shopId) {
    Get.toNamed('/admin/shops/details', arguments: shopId);
  }

  Future<void> fetchAllUsers() async {
    isLoadingUsers.value = true;
    
    final usersList = await _supabaseService.fetchAllUsers();
    debugPrint('Fetched ${usersList.length} users from Supabase');
    final authController = Get.find<AuthController>();
    debugPrint('Current user ID: ${authController.currentUser.value?.id ?? "Not logged in"}');
    debugPrint('Current user role: ${authController.currentUser.value?.role ?? "Not available"}');
    for (var user in usersList) {
      debugPrint('User: ${user.email}, Role: ${user.role}, ID: ${user.id}, Active: ${user.isActive}');
    }
    users.clear();
    users.addAll(usersList);
    filteredUsers.clear();
    filteredUsers.addAll(usersList);
    
    // Update counts
    totalUsers.value = usersList.length;
    customerCount.value = usersList.where((user) => user.role == 'customer').length;
    shopOwnerCount.value = usersList.where((user) => user.role == 'shop_owner').length;
    isLoadingUsers.value = false;
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) => 
        user.email.toLowerCase().contains(query.toLowerCase()) || 
        (user.full_name?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (user.phone?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
  }

  void filterUsersByRole(String role) {
    selectedUserRole.value = role;
    if (role.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) => user.role == role).toList();
    }
  }

  void filterShopsByStatus(String status) {
    selectedShopStatus.value = status;
    if (status.isEmpty) {
      filteredShops.value = shops;
    } else {
      filteredShops.value = shops.where((shop) => shop.status == status).toList();
    }
  }

  Future<ShopModel?> getShopForOwner(String userId) async {
    final response = await _supabaseService.fetchShopByUserId(userId);
    return response;
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    await _supabaseService.updateUserRole(userId, newRole);
    // Update local list
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      users[userIndex] = users[userIndex].copyWith(role: newRole);
      filteredUsers.value = [...filteredUsers];
    }
    return true;
  }

  Future<bool> toggleUserActiveStatus(String userId, bool isActive) async {
    await _supabaseService.updateUserActiveStatus(userId, isActive);
    // Update local list
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      users[userIndex] = users[userIndex].copyWith(isActive: isActive);
      filteredUsers.value = [...filteredUsers];
    }
    return true;
  }

  Future<bool> deleteUser(String userId) async {
    await _supabaseService.deleteUser(userId);
    users.removeWhere((u) => u.id == userId);
    filteredUsers.value = [...filteredUsers];
    return true;
  }

  Future<bool> approveShop(String shopId, String ownerId) async {
    await _supabaseService.updateShopStatus(shopId, 'approved');
    await _supabaseService.updateUserRole(ownerId, 'shop_owner');
    final shopIndex = shops.indexWhere((s) {
      // Use raw data if needed, but for now assume id is accessible
      return s.id == shopId;
    });
    if (shopIndex != -1) {
      shops[shopIndex] = shops[shopIndex].copyWith(status: 'approved');
      filteredShops.clear();
      filteredShops.addAll(shops);
      pendingShopCount.value = shops.where((shop) => shop.status == 'pending').length;
    }
    return true;
  }

  Future<bool> rejectShop(String shopId, String reason) async {
    await _supabaseService.updateShopStatus(shopId, 'rejected');
    // You might want to store the rejection reason somewhere
    final shopIndex = shops.indexWhere((s) {
      // Use raw data if needed, but for now assume id is accessible
      return s.id == shopId;
    });
    if (shopIndex != -1) {
      shops[shopIndex] = shops[shopIndex].copyWith(status: 'rejected');
      filteredShops.clear();
      filteredShops.addAll(shops);
      pendingShopCount.value = shops.where((shop) => shop.status == 'pending').length;
    }
    return true;
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

}

// Data models for analytics
class DailyRevenueData {
  final DateTime date;
  final double revenue;

  DailyRevenueData({required this.date, required this.revenue});
}

class OrderStatusData {
  final String status;
  final int count;

  OrderStatusData({required this.status, required this.count});
}

class ShopCategoryData {
  final String category;
  final int count;

  ShopCategoryData({required this.category, required this.count});
}

class UserGrowthData {
  final DateTime date;
  final int customers;
  final int shopOwners;

  UserGrowthData({required this.date, required this.customers, required this.shopOwners});
}

class TopShopData {
  final String id;
  final String name;
  final String category;
  final String city;
  final double revenue;
  final int orders;

  TopShopData({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.revenue,
    required this.orders,
  });
}