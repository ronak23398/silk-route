import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/customer_controller.dart';

class CartView extends StatelessWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.cartItems.isEmpty
            ? const Center(child: Text('Your cart is empty'))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];
                  return CartItemCard(item: cartItem, controller: controller);
                },
              ),
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: controller.cartItems.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${controller.cartItems.fold(0.0, (sum, cartItem) => sum + (cartItem.item.price * cartItem.quantity)).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to checkout or order placement
                        Get.to(() => const CheckoutView());
                      },
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CustomerController controller;

  const CartItemCard({Key? key, required this.item, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item.item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item.item.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 80),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item.name,
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '₹${item.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.green),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => controller.removeFromCart(item.item),
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      IconButton(
                        onPressed: () => controller.addToCart(item.item),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutView extends StatelessWidget {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();
    final TextEditingController addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter your delivery address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              controller: addressController,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Cash on Delivery',
              style: TextStyle(fontSize: 16.0),
            ),
            const Spacer(),
            Obx(
              () => Column(
                children: [
                  Text(
                    'Total: ₹${controller.cartItems.fold(0.0, (sum, cartItem) => sum + (cartItem.item.price * cartItem.quantity)).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.placeOrder(addressController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order placed successfully!')),
                        );
                        Get.back();
                      },
                      child: const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
