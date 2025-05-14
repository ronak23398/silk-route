import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/routes/app_routes.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/controllers/shop_controllers.dart';

class DashboardView extends StatelessWidget {
  final ShopController shopController = Get.find<ShopController>();

  DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await shopController.fetchShopData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed(AppRoutes.LOGIN);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (shopController.isLoadingShop.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (shopController.shop.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No shop data found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.KYC);
                  },
                  child: const Text('Complete KYC'),
                ),
              ],
            ),
          );
        }

        final shop = shopController.shop.value!;
        
        if (shop.isPending) {
          return _buildPendingApprovalView(shop);
        }

        if (shop.isRejected) {
          return _buildRejectedView(shop);
        }

        return _buildDashboardView(context);
      }),
    );
  }

  Widget _buildPendingApprovalView(shop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 72,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Shop Pending Approval',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your shop "${shop.name}" is under review by our team.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'We\'ll notify you once your shop is approved.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.LOGIN);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedView(shop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 72,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Shop Application Rejected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your shop "${shop.name}" application was not approved.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'Please contact support for more information.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.KYC);
            },
            child: const Text('Update Shop Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await shopController.fetchShopData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopInfoCard(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMenuButtons(context),
            const SizedBox(height: 24),
            _buildRecentOrdersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfoCard() {
    final shop = shopController.shop.value!;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey[200],
              backgroundImage: shop.imageUrl != null 
                  ? NetworkImage(shop.imageUrl!) 
                  : null,
              child: shop.imageUrl == null 
                  ? Text(
                      shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.address,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Approved',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Stats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              'Pending Orders',
              shopController.pendingOrdersCount.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
            _buildStatCard(
              'In Progress',
              shopController.inProgressOrdersCount.toString(),
              Icons.delivery_dining,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Products',
              shopController.totalItemsCount.toString(),
              Icons.category,
              Colors.green,
            ),
            _buildStatCard(
              'Out of Stock',
              shopController.outOfStockItemsCount.toString(),
              Icons.inventory_2,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    final buttonHeight = MediaQuery.of(context).size.height * 0.12;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNavButton(
                'Product Catalog',
                Icons.inventory,
                Colors.blue[700]!,
                AppRoutes.SHOP_CATALOG,
                buttonHeight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNavButton(
                'Order Management',
                Icons.receipt_long,
                Colors.purple[700]!,
                AppRoutes.SHOP_ORDERS,
                buttonHeight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(
      String title, IconData icon, Color color, String route, double height) {
    return InkWell(
      onTap: () {
        Get.toNamed(route);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    final pendingOrders = shopController.orders
        .where((order) => order.isPending)
        .take(3)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.SHOP_ORDERS);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (pendingOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No pending orders',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingOrders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final order = pendingOrders[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.receipt,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${order.itemCount} items • ₹${order.totalAmount}',
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.SHOP_ORDERS);
                  },
                  child: const Text('View'),
                ),
              );
            },
          ),
      ],
    );
  }
}