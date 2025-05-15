import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/controllers/customer_controller.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/views/customer/shop_details_view.dart';
import 'package:silk_route/views/customer/cart_view.dart';
import 'package:silk_route/views/customer/orders_view.dart';

class CustomerDashboardView extends StatelessWidget {
  const CustomerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllShops(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, controller);
            },
          ),
           IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
             authController.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search shops...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => controller.setSearchQuery(value),
            ),
          ),
          Obx(
            () => controller.isLoadingShops.value
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredShops.isEmpty
                    ? const Center(child: Text('No shops found'))
                    : Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: controller.filteredShops.length,
                          itemBuilder: (context, index) {
                            final shop = controller.filteredShops[index];
                            return ShopCard(shop: shop, controller: controller);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
        ],
        onTap: (index) {
          // Handle navigation to cart and orders views
          if (index == 1) {
            Get.to(() => const CartView());
          } else if (index == 2) {
            Get.to(() => const OrdersView());
          }
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, CustomerController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Shops'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location (City)',
                  hintText: 'Enter city name',
                ),
                onChanged: (value) => controller.setLocationFilter(value),
                controller: TextEditingController(text: controller.selectedLocation.value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final CustomerController controller;

  const ShopCard({Key? key, required this.shop, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          controller.selectShop(shop);
          Get.to(() => const ShopDetailsView());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              shop.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        shop.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 80),
                      ),
                    )
                  : const Icon(Icons.store, size: 80),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      shop.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      shop.city,
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}