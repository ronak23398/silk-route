import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/services/supabase_service.dart';
// Import other controllers here

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Register the auth controller as a singleton
        final supabaseService = Get.put(SupabaseService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    
  
  }
  
 
}