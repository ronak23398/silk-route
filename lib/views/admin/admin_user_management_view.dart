import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silk_route/app/models/user_model.dart';
import 'package:silk_route/app/utils/helpers.dart';
import 'package:silk_route/controllers/admin_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminUserManagementView extends GetView<AdminController> {
  const AdminUserManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.searchUsers('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => controller.searchUsers(value),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: controller.selectedUserRole.value,
                  hint: const Text('All Roles'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All Roles'),
                    ),
                    const DropdownMenuItem(
                      value: 'customer',
                      child: Text('Customers'),
                    ),
                    const DropdownMenuItem(
                      value: 'shop_owner',
                      child: Text('Shop Owners'),
                    ),
                    const DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admins'),
                    ),
                  ],
                  onChanged: (value) => controller.filterUsersByRole(value ?? ''),
                ),
              ],
            ),
          ),
          
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() => Row(
              children: [
                _buildStatCard(
                  Icons.people_outline,
                  'Total Users',
                  controller.totalUsers.toString(),
                  Colors.blue,
                ),
                _buildStatCard(
                  Icons.person_outline,
                  'Customers',
                  controller.customerCount.toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  Icons.store_outlined,
                  'Shop Owners',
                  controller.shopOwnerCount.toString(),
                  Colors.orange,
                ),
              ],
            )),
          ),
          
          // User list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingUsers.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      if (controller.searchController.text.isNotEmpty || 
                          controller.selectedUserRole.value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            controller.searchController.clear();
                            controller.selectedUserRole.value = '';
                            controller.filterUsersByRole('');
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return _buildUserCard(context, user);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getAvatarColor(user.role),
          child: Text(
            (user.full_name?.isNotEmpty == true)
                ? user.full_name![0].toUpperCase()
                : user.email[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.full_name ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(user.role),
                const SizedBox(width: 8),
                Text(
                  'Joined ${timeago.format(user.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showUserActionSheet(context, user),
        ),
        onTap: () => _showUserDetailsDialog(context, user),
      ),
    );
  }

  Color _getAvatarColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'shop_owner':
        return Colors.orange;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRoleChip(String role) {
    Color color;
    String label;
    
    switch (role) {
      case 'admin':
        color = Colors.purple;
        label = 'Admin';
        break;
      case 'shop_owner':
        color = Colors.orange;
        label = 'Shop Owner';
        break;
      case 'customer':
        color = Colors.blue;
        label = 'Customer';
        break;
      default:
        color = Colors.grey;
        label = role.capitalizeFirst ?? 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUserActionSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserDetailsDialog(context, user);
                },
              ),
              if (user.role != 'admin')
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Role'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditRoleDialog(context, user);
                  },
                ),
              if (user.role != 'admin')
                ListTile(
                  leading: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    color: user.isActive ? Colors.red : Colors.green,
                  ),
                  title: Text(user.isActive ? 'Disable Account' : 'Enable Account'),
                  onTap: () {
                    Navigator.pop(context);
                    _showToggleActiveDialog(context, user);
                  },
                ),
              if (user.role != 'admin')
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteUserDialog(context, user);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Name', user.full_name ?? 'Not provided'),
              _detailRow('Email', user.email),
              _detailRow('Phone', user.phone ?? 'Not provided'),
              _detailRow('Role', user.role.capitalizeFirst ?? ''),
              _detailRow('Status', user.isActive ? 'Active' : 'Disabled'),
              _detailRow('Joined', Helpers.formatDate(user.createdAt)),
              if (user.lastLogin != null)
                _detailRow('Last Login', Helpers.formatDate(user.lastLogin!)),
                
              // If shop owner, show associated shop
              if (user.role == 'shop_owner')
                FutureBuilder(
                  future: controller.getShopForOwner(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final shop = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 24),
                          const Text(
                            'Associated Shop',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _detailRow('Shop Name', shop!.name),
                          _detailRow('Status', shop.status.capitalizeFirst ?? ''),
                          _detailRow('Location', '${shop.address}, ${shop.city}'),
                        ],
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No shop associated with this account'),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, UserModel user) {
    final currentRole = user.role;
    String selectedRole = currentRole;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current role: ${currentRole.capitalizeFirst}'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Customer'),
                      value: 'customer',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Shop Owner'),
                      value: 'shop_owner',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Admin'),
                      value: 'admin',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() => selectedRole = value!);
                      },
                    ),
                  ],
                );
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedRole != currentRole) {
                Get.back();
                controller.updateUserRole(user.id, selectedRole);
              } else {
                Get.back();
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _showToggleActiveDialog(BuildContext context, UserModel user) {
    final isActive = user.isActive;
    
    Get.dialog(
      AlertDialog(
        title: Text(isActive ? 'Disable Account' : 'Enable Account'),
        content: Text(
          isActive
              ? 'Are you sure you want to disable ${user.full_name ?? user.email}\'s account? '
                'They will no longer be able to log in.'
              : 'Are you sure you want to enable ${user.full_name ?? user.email}\'s account? '
                'They will be able to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleUserActiveStatus(user.id, !isActive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'DISABLE' : 'ENABLE'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to permanently delete ${user.full_name ?? user.email}\'s account? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}