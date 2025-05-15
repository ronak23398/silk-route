import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/customer_controller.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.recentOrders.isEmpty
            ? const Center(child: Text('No orders found'))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.recentOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.recentOrders[index];
                  return OrderCard(order: order);
                },
              ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final dynamic order; // Replace with OrderModel once defined

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id ?? "N/A"}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Date: ${order.createdAt ?? "N/A"}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Status: ${order.status ?? "N/A"}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total: ₹${order.totalAmount?.toStringAsFixed(2) ?? "N/A"}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
