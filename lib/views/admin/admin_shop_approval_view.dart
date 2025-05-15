import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/controllers/admin_controller.dart';

class AdminShopApprovalView extends StatelessWidget {
  const AdminShopApprovalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.find<AdminController>();

    return Obx(
      () => adminController.isLoadingPendingShops.value
          ? const Center(child: CircularProgressIndicator())
          : adminController.pendingShops.isEmpty
              ? const Center(child: Text('No new shop approval requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: adminController.pendingShops.length,
                  itemBuilder: (context, index) {
                    final shop = adminController.pendingShops[index];
                    return ShopApprovalCard(shop: shop);
                  },
                ),
    );
  }
}

class ShopApprovalCard extends StatelessWidget {
  final ShopModel shop;

  const ShopApprovalCard({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.find<AdminController>();

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
                    // View shop details
                  },
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () async {
                    await adminController.approveShop(shop.id, 'approved');
                  },
                  child: const Text('Approve'),
                ),
                TextButton(
                  onPressed: () async {
                    await adminController.rejectShop(shop.id, 'rejected');
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
