// lib/app/modules/kyc/controllers/kyc_controller.dart

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silk_route/controllers/auth_controllers.dart';

class KycController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  
  // Validation method for documents
  bool validateDocuments() {
    if (authController.idProofPath.isEmpty) {
      Get.snackbar(
        'Missing Document',
        'Please upload your ID proof',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    if (authController.businessLicensePath.isEmpty) {
      Get.snackbar(
        'Missing Document',
        'Please upload your business license',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    }
    
    return true;
  }

  // Method to pick document
  void pickDocument(String documentType, ImageSource source) {
    authController.pickDocument(documentType, source);
  }
  
  // Method to pick shop image
  void pickShopImage(ImageSource source) {
    authController.pickShopImage(source);
  }
  
  // Method to submit KYC data
  void submitKYC({
    required String shopName,
    required String shopAddress,
    required String shopPhone,
    required String shopCity,
    String? shopDescription,
  }) {
    authController.submitKYC(
      shopName: shopName,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      shopDescription: shopDescription ?? '',
      shopCity: shopCity,
    );
  }
}