import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/models/user_model.dart';
import 'package:silk_route/app/routes/app_routes.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/app/utils/helpers.dart';
import 'package:silk_route/services/supabase_service.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var hidePassword = true.obs;
  var hideConfirmPassword = true.obs;
  var currentUser = Rxn<UserModel>();
  var currentShop = Rxn<ShopModel>();

  // KYC form variables
  var shopImagePath = ''.obs;
  var idProofPath = ''.obs;
  var businessLicensePath = ''.obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    isLoading(true);
    try {
      final user = await _supabaseService.getCurrentUser();
      if (user != null) {
        // Set the user value in the Rx
        currentUser.value = user;
        isLoggedIn(true);

        // Route based on user role
        _routeBasedOnUserRole(user);
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      showError('Authentication Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Route user based on their role
  void _routeBasedOnUserRole(UserModel user) async {
    switch (user.role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        break;
      
      case 'shop_owner':
        // Check if user has a shop
        final shop = await _supabaseService.fetchShopByUserId(user.id);
        if (shop != null) {
          // Set the shop value in the Rx
          currentShop.value = shop;

          // If shop is approved, navigate to dashboard
          if (shop.status == ShopStatus.approved.value) {
            Get.offAllNamed(AppRoutes.SHOP_DASHBOARD);
          }
          // If shop is pending approval
          else if (shop.status == ShopStatus.pending.value) {
            Get.offAllNamed(AppRoutes.KYC);
          }
        } else {
          // User has no shop yet, redirect to KYC
          Get.offAllNamed(AppRoutes.KYC);
        }
        break;
      
      case 'customer':
        // When customer dashboard is implemented
        Get.offAllNamed(AppRoutes.CUSTOMER_DASHBOARD);
        break;
      
      default:
        // Default to login page if role is unknown
        Get.offAllNamed(AppRoutes.LOGIN);
        break;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  // Pick shop image
  Future<void> pickShopImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        shopImagePath.value = pickedFile.path;
      }
    } catch (e) {
      showError('Image Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  // Pick document
  Future<void> pickDocument(String documentType, ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        if (documentType == DocumentType.ID_PROOF) {
          idProofPath.value = pickedFile.path;
        } else if (documentType == DocumentType.BUSINESS_LICENSE) {
          businessLicensePath.value = pickedFile.path;
        }
      }
    } catch (e) {
      showError('Document Error', 'Failed to pick document: ${e.toString()}');
    }
  }

  // Login method
  Future<void> login(String email, String password) async {
    isLoading(true);
    try {
      final user = await _supabaseService.login(email, password);
      if (user != null) {
        // Set the user value
        currentUser.value = user;
        isLoggedIn(true);

        // Route user based on their role
        _routeBasedOnUserRole(user);
      }
    } catch (e) {
      showError('Login Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Sign Up method
  Future<void> signUp(String name, String email, String password) async {
    isLoading(true);
    try {
      final user = await _supabaseService.signUp(name, email, password);
      if (user != null) {
        // Set the user value
        currentUser.value = user;
        isLoggedIn(true);
        Get.offAllNamed(AppRoutes.KYC);
      }
    } catch (e) {
      showError('Registration Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Logout method
  Future<void> logout() async {
    isLoading(true);
    try {
      await _supabaseService.logout();
      currentUser.value = null;
      currentShop.value = null;
      isLoggedIn(false);
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      showError('Logout Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // KYC submission
  Future<void> submitKYC({
    required String shopName,
    required String shopAddress,
    required String shopCity,
    required String shopPhone,
    String? shopDescription,
  }) async {
    // Proper null check with debug message
    if (currentUser.value == null) {
      print("DEBUG: currentUser is null in submitKYC. Authentication state: ${isLoggedIn.value}");
      showError('Authentication Error', 'User not authenticated');
      return;
    }

    isLoading(true);
    try {
      // Create shop model
      final shop = ShopModel(
        id: '', // Will be assigned by Supabase
        ownerId: currentUser.value!.id,
        name: shopName,
        address: shopAddress,
        city: shopCity,
        description: shopDescription ?? '',
        phone: shopPhone,
        status: ShopStatus.pending.value,
        createdAt: DateTime.now(),
      );

      // Submit KYC data to Supabase with document files
      final createdShop = await _supabaseService.submitKYC(
        shop,
        shopImagePath: shopImagePath.value,
        idProofPath: idProofPath.value,
        businessLicensePath: businessLicensePath.value,
      );

      if (createdShop != null) {
        // Properly set the shop value
        currentShop.value = createdShop;
        Get.offAllNamed(AppRoutes.KYC);
        showSuccess(
          'Application Submitted',
          'Your shop registration is under review.',
        );
      } else {
        showError('KYC Error', 'Failed to submit shop registration');
      }
    } catch (e) {
      showError('KYC Submission Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Helper methods for showing messages
  void showError(String title, String message) {
    Helpers.showSnackbar(title, message, isError: true);
  }

  void showSuccess(String title, String message) {
    Helpers.showSnackbar(title, message);
  }
}