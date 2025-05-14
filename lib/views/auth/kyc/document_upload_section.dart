// lib/app/modules/kyc/views/widgets/document_upload_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/controllers/kyc_controller.dart';

class DocumentUploadSection extends StatelessWidget {
  final KycController controller;
  final String idProofPath;
  final String businessLicensePath;

  const DocumentUploadSection({
    Key? key,
    required this.controller,
    required this.idProofPath,
    required this.businessLicensePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Business Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // ID Proof Upload Button
        OutlinedButton.icon(
          onPressed: () => _pickDocument(DocumentType.ID_PROOF),
          icon: const Icon(Icons.upload_file),
          label: Text(
            idProofPath.isEmpty
                ? 'Upload ID Proof *'
                : 'ID Proof Selected',
            style: TextStyle(
              color: idProofPath.isEmpty ? Colors.grey : Colors.green,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: idProofPath.isEmpty ? Colors.grey : Colors.green,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Business License Upload Button
        OutlinedButton.icon(
          onPressed: () => _pickDocument(DocumentType.BUSINESS_LICENSE),
          icon: const Icon(Icons.upload_file),
          label: Text(
            businessLicensePath.isEmpty
                ? 'Upload Business License *'
                : 'Business License Selected',
            style: TextStyle(
              color: businessLicensePath.isEmpty ? Colors.grey : Colors.green,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: businessLicensePath.isEmpty ? Colors.grey : Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  // Method to pick document
  void _pickDocument(String documentType) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Document Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                controller.pickDocument(documentType, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                controller.pickDocument(documentType, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}