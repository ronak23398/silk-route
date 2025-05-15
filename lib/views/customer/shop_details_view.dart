import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/customer_controller.dart';
import 'package:silk_route/app/models/item_model.dart';

class ShopDetailsView extends StatelessWidget {
  const ShopDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.selectedShop.value?.name ?? 'Shop Details')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isLoadingProducts.value
            ? const Center(child: CircularProgressIndicator())
            : controller.shopProducts.isEmpty
                ? const Center(child: Text('No products available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controller.shopProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.shopProducts[index];
                      return ProductCard(product: product, controller: controller);
                    },
                  ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ItemModel product;
  final CustomerController controller;

  const ProductCard({Key? key, required this.product, required this.controller}) : super(key: key);

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
            // Product image
            product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 100),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(width: 16.0),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart')),
                          );
                        },
                        child: const Text('Add to Cart'),
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
