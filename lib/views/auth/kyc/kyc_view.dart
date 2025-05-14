// lib/app/modules/kyc/views/kyc_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/controllers/auth_controllers.dart';
import 'package:silk_route/controllers/kyc_controller.dart';
import 'package:silk_route/views/auth/kyc/document_upload_section.dart';
import 'package:silk_route/views/auth/kyc/shop_detail_form.dart';
import 'package:silk_route/views/auth/kyc/shop_image_picker.dart';

class KycView extends StatelessWidget {
  final KycController kycController = Get.put(KycController());
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopAddressController = TextEditingController();
  final TextEditingController shopPhoneController = TextEditingController();
  final TextEditingController shopDescriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  KycView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Registration'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => authController.logout(),
            icon: const Icon(Icons.logout_outlined)
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete Your Shop Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please fill in the details to get your shop registered',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Shop Image Upload Widget
                  Obx(() => ShopImagePicker(
                    imagePath: authController.shopImagePath.value,
                    controller: kycController,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Shop Details Form Widget
                  ShopDetailsForm(
                    shopNameController: shopNameController,
                    shopAddressController: shopAddressController,
                    shopPhoneController: shopPhoneController,
                    shopDescriptionController: shopDescriptionController,
                    onCategoryChanged: (value) {
                      authController.selectedCategory.value = value ?? '';
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Document Upload Section Widget
                  Obx(() => DocumentUploadSection(
                    controller: kycController,
                    idProofPath: authController.idProofPath.value,
                    businessLicensePath: authController.businessLicensePath.value,
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // Submit Button
                  Obx(() => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (kycController.validateDocuments()) {
                                kycController.submitKYC(
                                  shopName: shopNameController.text.trim(),
                                  shopAddress: shopAddressController.text.trim(),
                                  shopPhone: shopPhoneController.text.trim(),
                                  shopDescription: shopDescriptionController.text.trim(),
                                  shopCity: '',
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: authController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SUBMIT APPLICATION',
                            style: TextStyle(fontSize: 16),
                          ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}