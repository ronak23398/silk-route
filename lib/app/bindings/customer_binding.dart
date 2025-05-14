import 'package:get/get.dart';
import 'package:silk_route/controllers/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize customer controller
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}