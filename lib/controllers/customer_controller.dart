import 'package:get/get.dart';
import 'package:silk_route/services/supabase_service.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/models/item_model.dart';
import 'package:silk_route/app/models/order_model.dart';

class CustomerController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingShops = false.obs;
  var isLoadingProducts = false.obs;
  var isLoadingCart = false.obs;
  
  // Data observables
  var allShops = <ShopModel>[].obs;
  var filteredShops = <ShopModel>[].obs;
  var cartItems = <CartItem>[].obs;
  var recentOrders = <OrderModel>[].obs;
  var selectedShop = Rxn<ShopModel>();
  var shopProducts = <ItemModel>[].obs;
  
  // Filter variables
  var selectedLocation = ''.obs;
  var searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load initial data
    fetchAllShops();
    fetchRecentOrders();
    fetchCartItems();
  }
  
  // Fetch all approved shops
  Future<void> fetchAllShops() async {
    isLoadingShops(true);
    try {
      print('Fetching approved shops from Supabase...');
      final response = await _supabaseService.fetchShopsByStatus('approved');
      print('Raw response from Supabase: $response');
      print('Number of shops received: ${response.length}');
      // Check if the response contains ShopModel objects or raw data
      if (response.isNotEmpty && response[0] is ShopModel) {
        allShops.value = response as List<ShopModel>;
      } else {
        allShops.value = response.map((shop) => ShopModel.fromJson(shop as Map<String, dynamic>)).toList();
      }
      print('Converted to ShopModel list. Total shops: ${allShops.length}');
      applyFilters();
      print('After applying filters, displayed shops: ${filteredShops.length}');
    } catch (e) {
      print('Error fetching shops: $e');
      Get.snackbar('Error', 'Failed to fetch shops: $e');
    } finally {
      isLoadingShops(false);
    }
  }
  
  // Apply filters and search
  void applyFilters() {
    print('Applying filters...');
    print('Selected location: ${selectedLocation.value.isEmpty ? "None" : selectedLocation.value}');
    print('Search query: ${searchQuery.value.isEmpty ? "None" : searchQuery.value}');
    filteredShops.value = allShops.where((shop) {
      final matchesLocation = selectedLocation.value.isEmpty || shop.city == selectedLocation.value;
      final matchesSearch = searchQuery.value.isEmpty || shop.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      print('Shop: ${shop.name}, City: ${shop.city}, Matches Location: $matchesLocation, Matches Search: $matchesSearch');
      return matchesLocation && matchesSearch;
    }).toList();
    print('After filtering, displaying ${filteredShops.length} shops');
  }
  
  // Set location filter
  void setLocationFilter(String location) {
    selectedLocation.value = location;
    applyFilters();
  }
  
  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }
  
  // Clear filters
  void clearFilters() {
    selectedLocation.value = '';
    searchQuery.value = '';
    applyFilters();
  }
  
  // Fetch products for a specific shop
  Future<void> fetchProductsForShop(String shopId) async {
    try {
      isLoadingProducts.value = true;
      final response = await _supabaseService.fetchItemsByShopId(shopId);
      print('Raw products response: $response');
      print('Number of products received: ${response.length}');
      // Check if the response contains ItemModel objects or raw data
      if (response.isNotEmpty && response[0] is ItemModel) {
        shopProducts.value = response as List<ItemModel>;
      } else {
        shopProducts.value = response.map((item) => ItemModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      print('Converted to ItemModel list. Total products: ${shopProducts.length}');
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar('Error', 'Failed to fetch shop products: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }
  
  // Select a shop
  void selectShop(ShopModel shop) {
    selectedShop.value = shop;
    fetchProductsForShop(shop.id);
  }
  
  // Cart management
  void addToCart(ItemModel item) {
    final existingItemIndex = cartItems.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (existingItemIndex != -1) {
      cartItems[existingItemIndex].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(item: item, quantity: 1));
    }
    _saveCartToStorage();
  }

  void removeFromCart(ItemModel item) {
    final existingItemIndex = cartItems.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (existingItemIndex != -1) {
      if (cartItems[existingItemIndex].quantity > 1) {
        cartItems[existingItemIndex].quantity--;
        cartItems.refresh();
      } else {
        cartItems.removeAt(existingItemIndex);
      }
      _saveCartToStorage();
    }
  }

  void _saveCartToStorage() async {
    // Implementation for saving cart to storage or database
  }

  Future<void> fetchCartItems() async {
    try {
      isLoadingCart.value = true;
      // Fetch cart items from storage or database
      // Placeholder until SupabaseService is updated
      final response = <Map<String, dynamic>>[];
      cartItems.value = response.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cart items: $e');
    } finally {
      isLoadingCart.value = false;
    }
  }
  
  // Fetch recent orders
  Future<void> fetchRecentOrders() async {
    isLoading(true);
    try {
      // Placeholder for fetching customer orders
      final response = <Map<String, dynamic>>[]; // Replace with actual Supabase call when available
      recentOrders.value = response.map((order) => OrderModel.fromJson(order)).toList();
    } catch (e) {
      print('Error fetching recent orders: $e');
    } finally {
      isLoading(false);
    }
  }
  
  // Place order with address
  Future<void> placeOrder(String address) async {
    try {
      isLoading.value = true;
      final orderItems = cartItems.map((cartItem) => {
        'item_id': cartItem.item.id,
        'quantity': cartItem.quantity,
        'price': cartItem.item.price,
      }).toList();

      // Placeholder until SupabaseService is updated
      print('Placing order with items: $orderItems, address: $address');
      // await _supabaseService.placeOrder(
      //   shopId: selectedShop.value?.id ?? '',
      //   items: orderItems,
      //   address: address,
      //   paymentMethod: 'Cash on Delivery',
      // );

      cartItems.clear();
      _saveCartToStorage();
      fetchRecentOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class CartItem {
  final ItemModel item;
  int quantity;

  CartItem({required this.item, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      item: ItemModel.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
    };
  }
}