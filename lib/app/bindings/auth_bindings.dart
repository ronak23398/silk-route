import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/controllers/shop_controllers.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Put services and controllers into GetX dependency injection system

    Get.put(AuthController(), permanent: true);
    Get.put(ShopController(), permanent: true);
    
  
}}