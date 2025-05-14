import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';

class PendingApprovalView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  PendingApprovalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopConnect'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Under Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                'Thank you ${authController.currentUser.value?.full_name} for registering your shop "${authController.currentShop.value?.name}" with us!',
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              )),
              const SizedBox(height: 16),
              const Text(
                'Your application is currently under review by our team. This process typically takes 24-48 hours.',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Card(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'What happens next?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1. Our team will verify your documents',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. You\'ll receive an email notification once approved',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. You can then start adding products to your shop',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Need help? Contact our support team:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement email support
                  Get.snackbar(
                    'Support',
                    'Email support coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.email),
                label: const Text('support@shopconnect.com'),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => authController.checkAuthStatus(),
                icon: const Icon(Icons.refresh),
                label: const Text('Check Status Again'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}