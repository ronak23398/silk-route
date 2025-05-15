import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/controllers/admin_controller.dart';

class AdminShopsView extends StatelessWidget {
  const AdminShopsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.find<AdminController>();

    return Obx(
      () => adminController.isLoadingShops.value
          ? const Center(child: CircularProgressIndicator())
          : adminController.allShops.isEmpty
              ? const Center(child: Text('No shops available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: adminController.allShops.length,
                  itemBuilder: (context, index) {
                    final shop = adminController.allShops[index];
                    return ShopCard(shop: shop);
                  },
                ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final ShopModel shop;

  const ShopCard({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shop.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Status: ${shop.status}'),
            Text('Address: ${shop.address}, ${shop.city}'),
            Text('Phone: ${shop.phone}'),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Add functionality to view shop details
                  },
                  child: const Text('View Details'),
                ),
                if (shop.status == 'pending')
                  TextButton(
                    onPressed: () {
                      // Add functionality to approve shop
                    },
                    child: const Text('Approve'),
                  ),
                if (shop.status == 'pending')
                  TextButton(
                    onPressed: () {
                      // Add functionality to reject shop
                    },
                    child: const Text('Reject'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
