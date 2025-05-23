import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/item_model.dart';
import 'package:silk_route/app/models/order_model.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/app/utils/helpers.dart';
import 'package:silk_route/services/supabase_service.dart';

class ShopController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  // Observable states
  final Rx<ShopModel?> shop = Rx<ShopModel?>(null);
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  
  // Loading states
  final RxBool isLoadingShop = false.obs;
  final RxBool isLoadingItems = false.obs;
  final RxBool isLoadingOrders = false.obs;
  final RxBool isProcessing = false.obs;
  
  // Filter states
  final RxString orderStatusFilter = OrderStatus.pending.value.obs;
  
  // Form controllers for adding/editing items
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchShopData();
    });
  }
  
  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    categoryController.dispose();
    super.onClose();
  }
  
  // Load current shop profile
 // Load current shop profile
Future<void> fetchShopData() async {
  isLoadingShop.value = true;
  
  try {
    // FIXED: Properly await the Future to get the UserModel
    final currentUser = await _supabaseService.getCurrentUser();
    if (currentUser == null) {
      Helpers.showSnackbar('Error', 'User not logged in', isError: true);
      isLoadingShop.value = false;
      return;
    }
    
    final shopData = await _supabaseService.fetchShopByUserId(currentUser.id);
    if (shopData != null) {
      shop.value = shopData;
      // Once shop data is loaded, fetch the items and orders
      await fetchItems();
      await fetchOrders();
    } else {
      debugPrint('No shop data found for current user');
    }
  } catch (e) {
    debugPrint('Error in fetchShopData: ${e.toString()}');
    Helpers.showSnackbar('Error', 'Failed to load shop data: ${e.toString()}', isError: true);
  } finally {
    isLoadingShop.value = false;
  }
}
  
  
  // Fixed updateOrderStatus method with correct parameter types
  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
  if (shop.value == null) {
    Helpers.showSnackbar('Error', 'Shop data not available', isError: true);
    return;
  }
  
  isProcessing.value = true;
  
  try {
    DateTime? acceptedAt;
    DateTime? deliveredAt;
    
    if (newStatus == OrderStatus.accepted.value) {
      acceptedAt = DateTime.now();
    } else if (newStatus == OrderStatus.delivered.value) {
      deliveredAt = DateTime.now();
    }
    
    final updatedOrder = order.copyWith(
      status: newStatus,
      acceptedAt: acceptedAt ?? order.acceptedAt,
      deliveredAt: deliveredAt ?? order.deliveredAt,
    );
    
    // FIXED: Passing just the order ID instead of the whole order object
    final success = await _supabaseService.updateOrderStatus(updatedOrder.id, newStatus);
    
    if (success) {
      final index = orders.indexWhere((element) => element.id == order.id);
      if (index != -1) {
        // Update the order in the local list with the modified copy
        orders[index] = updatedOrder;
      }
      Helpers.showSnackbar('Success', 'Order status updated successfully');
    } else {
      Helpers.showSnackbar('Error', 'Failed to update order status', isError: true);
    }
  } catch (e) {
    debugPrint('Error in updateOrderStatus: ${e.toString()}');
    Helpers.showSnackbar('Error', 'Failed to update order status: ${e.toString()}', isError: true);
  } finally {
    isProcessing.value = false;
  }
}
  
  // Load item catalog
  Future<void> fetchItems() async {
    if (shop.value == null) return;
    
    isLoadingItems.value = true;
    
    try {
      final itemsList = await _supabaseService.fetchItemsByShopId(shop.value!.id);
      items.value = itemsList;
    } catch (e) {
      debugPrint('Error in fetchItems: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load items: ${e.toString()}', isError: true);
    } finally {
      isLoadingItems.value = false;
    }
  }
  
  // Add a new product
  Future<void> addItem() async {
    if (shop.value == null) {
      Helpers.showSnackbar('Error', 'Shop data not available', isError: true);
      return;
    }
    
    if (!_validateItemForm()) {
      return;
    }
    
    isProcessing.value = true;
    
    try {
      final newItem = ItemModel(
        id: '', // Will be generated by Supabase
        shopId: shop.value!.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        stock: int.parse(stockController.text),
        category: categoryController.text.trim(),
        isAvailable: true,
        createdAt: DateTime.now(),
      );
      
      final addedItem = await _supabaseService.addItemToCatalog(newItem);
      if (addedItem != null) {
        items.add(addedItem as ItemModel);
        clearItemForm();
        Helpers.showSnackbar('Success', 'Item added successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to add item to catalog', isError: true);
      }
    } catch (e) {
      debugPrint('Error in addItem: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to add item: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Edit existing product
  Future<void> updateItem(ItemModel item) async {
    if (shop.value == null) {
      Helpers.showSnackbar('Error', 'Shop data not available', isError: true);
      return;
    }
    
    if (!_validateItemForm()) {
      return;
    }
    
    isProcessing.value = true;
    
    try {
      final updatedItem = item.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        stock: int.parse(stockController.text),
        category: categoryController.text.trim(),
        updatedAt: DateTime.now(),
      );
      
      final result = await _supabaseService.updateItemInCatalog(updatedItem);
      if (result != null) {
        final index = items.indexWhere((element) => element.id == item.id);
        if (index != -1) {
          items[index] = result as ItemModel;
        }
        clearItemForm();
        Helpers.showSnackbar('Success', 'Item updated successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to update item in catalog', isError: true);
      }
    } catch (e) {
      debugPrint('Error in updateItem: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to update item: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Remove product
  Future<void> deleteItem(String itemId) async {
    if (shop.value == null) {
      Helpers.showSnackbar('Error', 'Shop data not available', isError: true);
      return;
    }
    
    isProcessing.value = true;
    
    try {
      final success = await _supabaseService.deleteItem(itemId);
      if (success) {
        items.removeWhere((item) => item.id == itemId);
        Helpers.showSnackbar('Success', 'Item deleted successfully');
      } else {
        Helpers.showSnackbar('Error', 'Failed to delete item', isError: true);
      }
    } catch (e) {
      debugPrint('Error in deleteItem: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to delete item: ${e.toString()}', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Load incoming orders
  Future<void> fetchOrders() async {
    if (shop.value == null) return;
    
    isLoadingOrders.value = true;
    
    try {
      final ordersList = await _supabaseService.fetchOrdersForShop(shop.value!.id);
      orders.value = ordersList;
    } catch (e) {
      debugPrint('Error in fetchOrders: ${e.toString()}');
      Helpers.showSnackbar('Error', 'Failed to load orders: ${e.toString()}', isError: true);
    } finally {
      isLoadingOrders.value = false;
    }
  }
  
  // Setup form for adding a new item
  void setupAddItemForm() {
    clearItemForm();
  }
  
  // Setup form for editing an existing item
  void setupEditItemForm(ItemModel item) {
    nameController.text = item.name;
    descriptionController.text = item.description;
    priceController.text = item.price.toString();
    stockController.text = item.stock.toString();
    categoryController.text = item.category ?? '';
  }
  
  // Clear item form
  void clearItemForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();
    categoryController.clear();
  }
  
  // Validate form fields
  bool _validateItemForm() {
    if (nameController.text.trim().isEmpty) {
      Helpers.showSnackbar('Error', 'Item name is required', isError: true);
      return false;
    }
    
    if (descriptionController.text.trim().isEmpty) {
      Helpers.showSnackbar('Error', 'Description is required', isError: true);
      return false;
    }
    
    if (priceController.text.isEmpty) {
      Helpers.showSnackbar('Error', 'Price is required', isError: true);
      return false;
    }
    
    try {
      final price = double.parse(priceController.text);
      if (price <= 0) {
        Helpers.showSnackbar('Error', 'Price must be greater than zero', isError: true);
        return false;
      }
    } catch (e) {
      Helpers.showSnackbar('Error', 'Invalid price format', isError: true);
      return false;
    }
    
    if (stockController.text.isEmpty) {
      Helpers.showSnackbar('Error', 'Stock is required', isError: true);
      return false;
    }
    
    try {
      final stock = int.parse(stockController.text);
      if (stock < 0) {
        Helpers.showSnackbar('Error', 'Stock cannot be negative', isError: true);
        return false;
      }
    } catch (e) {
      Helpers.showSnackbar('Error', 'Invalid stock format', isError: true);
      return false;
    }
    
    return true;
  }
  
  // Filter orders by status
  List<OrderModel> get filteredOrders {
    if (orderStatusFilter.value == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == orderStatusFilter.value).toList();
  }
  
  // Get counts for dashboard
  int get pendingOrdersCount => orders.where((order) => order.status == OrderStatus.pending.value).length;
  int get acceptedOrdersCount => orders.where((order) => order.status == OrderStatus.accepted.value).length;
  int get inProgressOrdersCount => orders.where((order) => order.status == OrderStatus.inProgress.value).length;
  int get totalItemsCount => items.length;
  int get outOfStockItemsCount => items.where((item) => item.stock <= 0).length;
}