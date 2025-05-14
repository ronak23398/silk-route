import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/order_model.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/models/user_model.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/app/utils/helpers.dart';
import 'package:silk_route/services/supabase_service.dart';
import 'package:intl/intl.dart';

class AdminController extends GetxController with GetTickerProviderStateMixin {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  // Observable states
  final RxList<ShopModel> shops = <ShopModel>[].obs;
  final RxList<ShopModel> pendingShops = <ShopModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  
  // Loading states
  final RxBool isLoadingShops = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoadingAnalytics = false.obs;
  
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
  final RxList<TopShopData> topShops = <TopShopData>[].obs;
  
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
  final RxString userRoleFilter = ''.obs;

  final searchController = TextEditingController();
final RxString selectedUserRole = ''.obs;
final RxInt totalUsers = 0.obs;
final RxInt customerCount = 0.obs;
final RxInt shopOwnerCount = 0.obs;

final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  
@override
void onInit() {
  super.onInit();
  tabController = TabController(length: 4, vsync: this);
  
  // Initialize filteredUsers with all users
  filteredUsers.value = users;
  
  // Load initial data
  fetchPendingShops();
  fetchShops();
  fetchAllUsers(); // Use this instead of fetchUsers()
  fetchRecentOrders();
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
    isLoadingShops.value = true;
    
    try {
      final shopsList = await _supabaseService.fetchShopsByStatus(ShopStatus.pending.value);
      pendingShops.value = shopsList;
    } catch (e) {
      debugPrint('Error in fetchPendingShops: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load pending shops: ${e.toString()}', isError: true);
    } finally {
      isLoadingShops.value = false;
    }
  }
  
  // Fetch all shops
  Future<void> fetchShops() async {
    isLoadingShops.value = true;
    
    try {
      final shopsList = await _supabaseService.fetchAllShops();
      shops.value = shopsList;
    } catch (e) {
      debugPrint('Error in fetchShops: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load shops: ${e.toString()}', isError: true);
    } finally {
      isLoadingShops.value = false;
    }
  }
  
  // Fetch users
  Future<void> fetchUsers() async {
    isLoadingUsers.value = true;
    
    try {
      final usersList = await _supabaseService.fetchAllUsers();
      users.value = usersList;
    } catch (e) {
      debugPrint('Error in fetchUsers: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load users: ${e.toString()}', isError: true);
    } finally {
      isLoadingUsers.value = false;
    }
  }
  
  // Fetch recent orders
  Future<void> fetchRecentOrders() async {
    isLoadingOrders.value = true;
    
    try {
      final ordersList = await _supabaseService.fetchRecentOrders();
      recentOrders.value = ordersList;
      
      // Process order status data for analytics
      orderStatusData.value = {
        OrderStatus.pending.value: 0,
        OrderStatus.accepted.value: 0,
        OrderStatus.inProgress.value: 0,
        OrderStatus.delivered.value: 0,
        OrderStatus.cancelled.value: 0,
      };
      
      for (var order in ordersList) {
        if (orderStatusData.containsKey(order.status)) {
          orderStatusData[order.status] = (orderStatusData[order.status] ?? 0) + 1;
        }
      }
    } catch (e) {
      debugPrint('Error in fetchRecentOrders: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load orders: ${e.toString()}', isError: true);
    } finally {
      isLoadingOrders.value = false;
    }
  }
  
  // Load analytics data
  Future<void> loadAnalytics() async {
    isLoadingAnalytics.value = true;
    
    try {
      // Get summary data
      final summaryData = await _supabaseService.fetchAnalyticsSummary();
      analytics.value = summaryData;
      
      // Get daily sales data for the chart
      final sales = await _supabaseService.fetchDailySalesData(
        startDate.value,
        endDate.value,
      );
      dailySalesData.value = sales;
      
      // Get shop category distribution
      final categoryData = await _supabaseService.fetchShopCategoryDistribution();
      shopCategoryData.value = categoryData;
      
      // Process analytics data
      _processAnalyticsData();
      
    } catch (e) {
      debugPrint('Error in loadAnalytics: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load analytics: ${e.toString()}', isError: true);
    } finally {
      isLoadingAnalytics.value = false;
    }
  }
  
  // Process analytics data for UI
  void _processAnalyticsData() {
    // Process summary metrics
    totalRevenue.value = analytics['total_revenue'] ?? 0.0;
    totalOrders.value = analytics['total_orders'] ?? 0;
    activeShops.value = analytics['active_shops'] ?? 0;
    newUsers.value = analytics['new_users'] ?? 0;
    
    // Process growth metrics
    revenueGrowth.value = analytics['revenue_growth'] ?? 0.0;
    ordersGrowth.value = analytics['orders_growth'] ?? 0.0;
    shopsGrowth.value = analytics['shops_growth'] ?? 0.0;
    usersGrowth.value = analytics['users_growth'] ?? 0.0;
    
    // Process daily revenue data
    dailyRevenue.value = dailySalesData.map((data) => DailyRevenueData(
      date: DateTime.parse(data['date']),
      revenue: (data['revenue'] as num).toDouble(),
    )).toList();
    
    // Process order status distribution
    orderStatusDistribution.value = orderStatusData.entries.map((entry) => OrderStatusData(
      status: entry.key,
      count: entry.value,
    )).toList();
    
    // Process shop category distribution
    shopCategoryDistribution.value = shopCategoryData.map((data) => ShopCategoryData(
      category: data['category'],
      count: data['count'],
    )).toList();
    
    // Process user growth data (mocked data for now)
    userGrowthData.value = _generateMockUserGrowthData();
    
    // Process top shops (mocked data for now)
    topShops.value = _generateMockTopShopsData();
  }
  
  // Generate mock user growth data
  List<UserGrowthData> _generateMockUserGrowthData() {
    final List<UserGrowthData> data = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      data.add(UserGrowthData(
        date: date,
        customers: 10 + (i * 3) + (date.day % 5),
        shopOwners: 5 + (i * 1) + (date.day % 3),
      ));
    }
    
    return data;
  }
  
  // Generate mock top shops data
  List<TopShopData> _generateMockTopShopsData() {
    final List<TopShopData> data = [];
    
    data.add(TopShopData(
      id: '1',
      name: 'Fashion Hub',
      category: 'Clothing',
      city: 'Mumbai',
      revenue: 58000,
      orders: 145,
    ));
    
    data.add(TopShopData(
      id: '2',
      name: 'Tech World',
      category: 'Electronics',
      city: 'Delhi',
      revenue: 42000,
      orders: 87,
    ));
    
    data.add(TopShopData(
      id: '3',
      name: 'Home Decor',
      category: 'Home & Kitchen',
      city: 'Bangalore',
      revenue: 36500,
      orders: 120,
    ));
    
    data.add(TopShopData(
      id: '4',
      name: 'Organic Foods',
      category: 'Grocery',
      city: 'Chennai',
      revenue: 28000,
      orders: 230,
    ));
    
    data.add(TopShopData(
      id: '5',
      name: 'Book Haven',
      category: 'Books & Media',
      city: 'Kolkata',
      revenue: 18500,
      orders: 95,
    ));
    
    return data;
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
  
  // Approve shop
  Future<void> approveShop(String shopId) async {
    isProcessing.value = true;
    
    try {
      final success = await _supabaseService.updateShopStatus(shopId, ShopStatus.approved.value);
      if (success) {
        // Update local lists
        final index = pendingShops.indexWhere((shop) => shop.id == shopId);
        if (index != -1) {
          final approvedShop = pendingShops[index].copyWith(
            status: ShopStatus.approved.value,
            updatedAt: DateTime.now(),
          );
          
          pendingShops.removeAt(index);
          
          // Also update in all shops list if it exists there
          final allShopsIndex = shops.indexWhere((shop) => shop.id == shopId);
          if (allShopsIndex != -1) {
            shops[allShopsIndex] = approvedShop;
          } else {
            shops.add(approvedShop);
          }
        }
        
        Helpers.showSnackbar('Success', 'Shop approved successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to approve shop', isError: true);
      }
    } catch (e) {
      debugPrint('Error in approveShop: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to approve shop: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Reject shop
  Future<void> rejectShop(String shopId) async {
    isProcessing.value = true;
    
    try {
      final success = await _supabaseService.updateShopStatus(shopId, ShopStatus.rejected.value);
      if (success) {
        // Update local lists
        final index = pendingShops.indexWhere((shop) => shop.id == shopId);
        if (index != -1) {
          final rejectedShop = pendingShops[index].copyWith(
            status: ShopStatus.rejected.value,
            updatedAt: DateTime.now(),
          );
          
          pendingShops.removeAt(index);
          
          // Also update in all shops list if it exists there
          final allShopsIndex = shops.indexWhere((shop) => shop.id == shopId);
          if (allShopsIndex != -1) {
            shops[allShopsIndex] = rejectedShop;
          }
        }
        
        Helpers.showSnackbar('Success', 'Shop application rejected');
      } else {
        Helpers.showSnackbar('Error', 'Failed to reject shop application', isError: true);
      }
    } catch (e) {
      debugPrint('Error in rejectShop: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to reject shop: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Suspend shop
  Future<void> suspendShop(String shopId) async {
    isProcessing.value = true;
    
    try {
      final success = await _supabaseService.updateShopStatus(shopId, ShopStatus.rejected.value);
      if (success) {
        // Update local list
        final index = shops.indexWhere((shop) => shop.id == shopId);
        if (index != -1) {
          shops[index] = shops[index].copyWith(
            status: ShopStatus.rejected.value,
            updatedAt: DateTime.now(),
          );
        }
        
        Helpers.showSnackbar('Success', 'Shop suspended successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to suspend shop', isError: true);
      }
    } catch (e) {
      debugPrint('Error in suspendShop: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to suspend shop: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
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

Future<void> fetchAllUsers() async {
  isLoadingUsers.value = true;
  
  try {
    final usersList = await _supabaseService.fetchAllUsers();
    users.value = usersList;
    filteredUsers.value = usersList;
    
    // Update counts
    totalUsers.value = usersList.length;
    customerCount.value = usersList.where((user) => user.role == 'customer').length;
    shopOwnerCount.value = usersList.where((user) => user.role == 'shop_owner').length;
  } catch (e) {
    debugPrint('Error in fetchAllUsers: ${e.toString()}');
    Helpers.showSnackbar('Error', 'Failed to load users: ${e.toString()}', isError: true);
  } finally {
    isLoadingUsers.value = false;
  }
}

Future<ShopModel?> getShopForOwner(String userId) async {
  try {
    return await _supabaseService.fetchShopByUserId(userId);
  } catch (e) {
    debugPrint('Error in getShopForOwner: ${e.toString()}');
    return null;
  }
}

// Future<void> toggleUserActiveStatus(String userId, bool isActive) async {
//   isProcessing.value = true;
  
//   try {
//     final success = await _supabaseService.updateUserActiveStatus(userId, isActive);
//     if (success) {
//       // Update local list
//       final index = users.indexWhere((user) => user.id == userId);
//       if (index != -1) {
//         users[index] = users[index].copyWith(isActive: isActive);
        
//         // Also update in filtered list if it exists there
//         final filteredIndex = filteredUsers.indexWhere((user) => user.id == userId);
//         if (filteredIndex != -1) {
//           filteredUsers[filteredIndex] = filteredUsers[filteredIndex].copyWith(isActive: isActive);
//         }
//       }
      
//       Helpers.showSnackbar(
//         'Success', 
//         isActive ? 'User account enabled successfully' : 'User account disabled successfully'
//       );
//     } else {
//       Helpers.showSnackbar('Error', 'Failed to update user status', isError: true);
//     }
//   } catch (e) {
//     debugPrint('Error in toggleUserActiveStatus: ${e.toString()}');
//     Helpers.showSnackbar('Error', 'Failed to update user status: ${e.toString()}', isError: true);
//   } finally {
//     isProcessing.value = false;
//   }
// }

// Add this method to the AdminController class
Future<void> toggleUserActiveStatus(String userId, bool isActive) async {
  isProcessing.value = true;
  
  try {
    final success = await _supabaseService.updateUserActiveStatus(userId, isActive);
    if (success) {
      // Update local list
      final index = users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        users[index] = users[index].copyWith(isActive: isActive);
        
        // Also update in filtered list if it exists there
        final filteredIndex = filteredUsers.indexWhere((user) => user.id == userId);
        if (filteredIndex != -1) {
          filteredUsers[filteredIndex] = filteredUsers[filteredIndex].copyWith(isActive: isActive);
        }
      }
      
      Helpers.showSnackbar(
        'Success', 
        isActive ? 'User account enabled successfully' : 'User account disabled successfully'
      );
    } else {
      Helpers.showSnackbar('Error', 'Failed to update user status', isError: true);
    }
  } catch (e) {
    debugPrint('Error in toggleUserActiveStatus: ${e.toString()}');
    Helpers.showSnackbar('Error', 'Failed to update user status: ${e.toString()}', isError: true);
  } finally {
    isProcessing.value = false;
  }
}



Future<void> deleteUser(String userId) async {
  isProcessing.value = true;
  
  try {
    final success = await _supabaseService.deleteUser(userId);
    if (success) {
      // Remove from local lists
      users.removeWhere((user) => user.id == userId);
      filteredUsers.removeWhere((user) => user.id == userId);
      
      // Update counts
      totalUsers.value = users.length;
      customerCount.value = users.where((user) => user.role == 'customer').length;
      shopOwnerCount.value = users.where((user) => user.role == 'shop_owner').length;
      
      Helpers.showSnackbar('Success', 'User deleted successfully');
    } else {
      Helpers.showSnackbar('Error', 'Failed to delete user', isError: true);
    }
  } catch (e) {
    debugPrint('Error in deleteUser: ${e.toString()}');
    Helpers.showSnackbar('Error', 'Failed to delete user: ${e.toString()}', isError: true);
  } finally {
    isProcessing.value = false;
  }
}


  
  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    isProcessing.value = true;
    
    try {
      final success = await _supabaseService.updateUserRole(userId, newRole);
      if (success) {
        // Update local list
        final index = users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          users[index] = users[index].copyWith(
            role: newRole,
          );
        }
        
        Helpers.showSnackbar('Success', 'User role updated successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to update user role', isError: true);
      }
    } catch (e) {
      debugPrint('Error in updateUserRole: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to update user role: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Filter shops by status
  List<ShopModel> get filteredShops {
    if (shopStatusFilter.value.isEmpty || shopStatusFilter.value == 'all') {
      return shops;
    }
    return shops.where((shop) => shop.status == shopStatusFilter.value).toList();
  }
  
  
  
  // Get counts for dashboard
  int get totalShopsCount => shops.length;
  int get pendingShopsCount => shops.where((shop) => shop.status == ShopStatus.pending.value).length;
  int get activeShopsCount => shops.where((shop) => shop.status == ShopStatus.approved.value).length;
  int get suspendedShopsCount => shops.where((shop) => shop.status == ShopStatus.rejected.value).length;
  
  int get totalUsersCount => users.length;
  int get customerUsersCount => users.where((user) => user.role == 'customer').length;
  int get shopOwnerUsersCount => users.where((user) => user.role == 'shop_owner').length;
  int get adminUsersCount => users.where((user) => user.role == 'admin').length;
  
  // Format date for display
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