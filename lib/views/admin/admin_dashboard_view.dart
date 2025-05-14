import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/admin_controller.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/views/admin/admin_analytics_view.dart';
import 'package:silk_route/views/admin/admin_user_management_view.dart';
import 'package:silk_route/views/admin/shop_approval_view.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchShops();
              controller.fetchPendingShops();
              controller.fetchUsers();
              controller.fetchRecentOrders();
              controller.loadAnalytics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.approval),
              text: 'Shop Approvals',
            ),
            Tab(
              icon: Icon(Icons.store),
              text: 'Shops',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Users',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          // Analytics Overview
          AdminAnalyticsView(),
          
          // Shop Approval View
          ShopApprovalView(),
          
          // Shop Management View
          ShopApprovalView(),
          
          // User Management View
          AdminUserManagementView(),
        ],
      ),
    );
  }
}