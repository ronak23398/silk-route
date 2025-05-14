import 'package:get/get.dart';
import 'package:silk_route/app/bindings/admin_binding.dart';
import 'package:silk_route/app/bindings/auth_bindings.dart';
import 'package:silk_route/app/bindings/customer_binding.dart';
import 'package:silk_route/views/admin/admin_dashboard_view.dart';
import 'package:silk_route/views/auth/kyc/kyc_view.dart';
import 'package:silk_route/views/auth/login_view.dart';
import 'package:silk_route/views/auth/signup_view.dart';
import 'package:silk_route/views/customer/customer_dashboard_view.dart';
import 'package:silk_route/views/shop/catalog_view.dart';
import 'package:silk_route/views/shop/dashboard_view.dart';
import 'package:silk_route/views/shop/order_view.dart';

class AppRoutes {
  // Route names as constants
  static const String LOGIN = '/login';
  static const String SIGNUP = '/signup';
  static const String KYC = '/kyc';
  
  // Shop owner routes
  static const String SHOP_DASHBOARD = '/shop/dashboard';
  static const String SHOP_CATALOG = '/shop/catalog';
  static const String SHOP_ORDERS = '/shop/orders';
  
  // Admin routes
  static const String ADMIN_DASHBOARD = '/admin/dashboard';
  
  // Customer routes
  static const String CUSTOMER_DASHBOARD = '/customer/dashboard';
  
  // GetX route definitions
  static final List<GetPage> pages = [
    GetPage(
      name: LOGIN,
      page: () => LoginView(),
      transition: Transition.fadeIn,
      binding: AuthBinding()
    ),
    GetPage(
      name: SIGNUP,
      page: () => SignupView(),
      transition: Transition.fadeIn,
      binding: AuthBinding()
    ),
    GetPage(
      name: KYC,
      page: () => KycView(),
      transition: Transition.rightToLeft,
    ),
    
    // Shop owner pages
    GetPage(
      name: SHOP_DASHBOARD,
      page: () => DashboardView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SHOP_CATALOG,
      page: () => CatalogView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: SHOP_ORDERS,
      page: () => OrdersView(),
      transition: Transition.rightToLeft,
    ),
    
    // Admin pages
    GetPage(
      name: ADMIN_DASHBOARD,
      page: () => AdminDashboardView(),
      transition: Transition.fadeIn,
      binding: AdminBindings()
    ),
    
    // Customer pages
    GetPage(
      name: CUSTOMER_DASHBOARD,
      page: () => CustomerDashboardView(),
      transition: Transition.fadeIn,
      binding: CustomerBinding()
    ),
  ];
}