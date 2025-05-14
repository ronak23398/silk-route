import 'package:get/get.dart';
import 'package:silk_route/controllers/admin_controller.dart';
import 'package:silk_route/services/supabase_service.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    // Make sure SupabaseService is registered
    if (!Get.isRegistered<SupabaseService>()) {
      Get.put(SupabaseService(), permanent: true);
    }
    
    // Register the AdminController
    Get.lazyPut<AdminController>(() => AdminController());
  }
}