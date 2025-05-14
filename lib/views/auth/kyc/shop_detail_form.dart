// lib/app/modules/kyc/views/widgets/shop_details_form.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/utils/constants.dart';

class ShopDetailsForm extends StatelessWidget {
  final TextEditingController shopNameController;
  final TextEditingController shopAddressController;
  final TextEditingController shopPhoneController;
  final TextEditingController shopDescriptionController;
  final Function(String?) onCategoryChanged;

  const ShopDetailsForm({
    Key? key,
    required this.shopNameController,
    required this.shopAddressController,
    required this.shopPhoneController,
    required this.shopDescriptionController,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Name Field
        TextFormField(
          controller: shopNameController,
          decoration: const InputDecoration(
            labelText: 'Shop Name *',
            prefixIcon: Icon(Icons.store),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your shop name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Shop Address Field
        TextFormField(
          controller: shopAddressController,
          decoration: const InputDecoration(
            labelText: 'Shop Address *',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your shop address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Shop Phone Field
        TextFormField(
          controller: shopPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Shop Phone *',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your shop phone';
            }
            if (!GetUtils.isPhoneNumber(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Shop Description Field
        TextFormField(
          controller: shopDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Shop Description',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        // Shop Category Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Shop Category *',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: ShopCategories.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onCategoryChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }
}