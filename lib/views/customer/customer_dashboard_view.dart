import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/controllers/customer_controller.dart';

class CustomerDashboardView extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message with the user's name
              Text(
                'Welcome, ${authController.currentUser.value?.full_name ?? 'Customer'}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              
              // Dashboard cards
              _buildDashboardCard(
                title: 'Browse Shops',
                icon: Icons.store,
                onTap: () {
                  // TODO: Navigate to shops listing
                },
              ),
              
              _buildDashboardCard(
                title: 'My Orders',
                icon: Icons.shopping_bag,
                onTap: () {
                  // TODO: Navigate to orders history
                },
              ),
              
              _buildDashboardCard(
                title: 'My Cart',
                icon: Icons.shopping_cart,
                onTap: () {
                  // TODO: Navigate to shopping cart
                },
              ),
              
              _buildDashboardCard(
                title: 'My Profile',
                icon: Icons.person,
                onTap: () {
                  // TODO: Navigate to profile page
                },
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.blue,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}