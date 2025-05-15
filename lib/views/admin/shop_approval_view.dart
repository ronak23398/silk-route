import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/shop_model.dart';
import 'package:silk_route/app/utils/constants.dart';
import 'package:silk_route/controllers/admin_controller.dart';
import 'package:silk_route/services/supabase_service.dart';

class ShopApprovalView extends GetView<AdminController> {
  const ShopApprovalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingShops.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.pendingShops.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
              const SizedBox(height: 16),
              const Text(
                'No pending shop applications',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => controller.fetchPendingShops(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pendingShops.length,
        itemBuilder: (context, index) {
          final shop = controller.pendingShops[index];
          return _buildShopCard(context, shop);
        },
      );
    });
  }
  
  Widget _buildShopCard(BuildContext context, ShopModel shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop header
          ListTile(
            title: Text(
              shop.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text('Submitted on ${controller.formatDate(shop.createdAt)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PENDING',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Shop details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Shop info
                _buildInfoRow(Icons.location_on, '${shop.address}, ${shop.city}'),
                _buildInfoRow(Icons.phone, shop.phone),
                if (shop.description.isNotEmpty)
                  _buildInfoRow(Icons.description, shop.description),
                  
                const SizedBox(height: 16),
                
                // Shop image
                if (shop.imageUrl != null && shop.imageUrl!.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: shop.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View Documents Button
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDocumentsBottomSheet(context, shop);
                      },
                      icon: const Icon(Icons.file_copy),
                      label: const Text('Documents'),
                    ),
                    const SizedBox(width: 12),
                    
                    // Reject Button
                    ElevatedButton(
                      onPressed: () async {
                        // Show dialog to input rejection reason
                        final reasonController = TextEditingController();
                        final reason = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reject Shop'),
                            content: TextField(
                              controller: reasonController,
                              decoration: const InputDecoration(hintText: 'Enter rejection reason'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, reasonController.text);
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                        
                        if (reason != null && reason.isNotEmpty) {
                          if (await controller.rejectShop(shop.id, reason)) {
                            controller.fetchPendingShops();
                            Get.snackbar('Success', 'Shop rejected successfully');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    
                    // Approve Button
                    ElevatedButton(
                      onPressed: () async {
                        if (await controller.approveShop(shop.id, shop.ownerId)) {
                          controller.fetchPendingShops();
                          Get.snackbar('Success', 'Shop approved successfully');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
  
  void _showDocumentsBottomSheet(BuildContext context, ShopModel shop) {
    // Assuming we're storing document URLs in the SupabaseService
    final documentsMap = {
      'Shop Image': shop.imageUrl,
      'ID Proof': Get.find<SupabaseService>().getDocumentUrl(shop.ownerId, DocumentType.ID_PROOF as DocumentType),
      'Business License': Get.find<SupabaseService>().getDocumentUrl(shop.ownerId, DocumentType.BUSINESS_LICENSE as DocumentType),
    };
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: documentsMap.entries.length,
                itemBuilder: (context, index) {
                  final entry = documentsMap.entries.elementAt(index);
                  final docName = entry.key;
                  final docUrl = entry.value;
                  
                  return ListTile(
                    title: Text(docName),
                    leading: const Icon(Icons.file_present),
                    trailing: docUrl != null
                        ? const Icon(Icons.visibility)
                        : const Text('Not uploaded', style: TextStyle(color: Colors.red)),
                    onTap: docUrl != null
                        ? () => _showDocumentPreview(context, docName, docUrl)
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  void _showDocumentPreview(BuildContext context, String docName, String docUrl) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(docName),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),
            Flexible(
              child: CachedNetworkImage(
                imageUrl: docUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, size: 64),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}