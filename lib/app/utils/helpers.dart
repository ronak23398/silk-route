import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Show a snackbar message with null safety checks
  static void showSnackbar(String title, String message, {bool isError = false}) {
    // First check if GetX context is available
    if (!Get.isSnackbarOpen && Get.context != null && Get.overlayContext != null) {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isError ? Colors.red.withOpacity(0.9) : Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
          duration: const Duration(seconds: 3),
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
        );
      } catch (e) {
        // Fallback to print if snackbar fails
        debugPrint('Failed to show snackbar: $e');
        debugPrint('Message was: $title - $message');
      }
    } else {
      // Fallback to printing the message if GetX context isn't available
      debugPrint('Cannot show snackbar: $title - $message');
    }
  }

  // Format date to readable string
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} (${_formatTime(dateTime)})';
  }

  static String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Format date to simple date
  static String formatSimpleDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format price with currency symbol
  static String formatPrice(double? price) {
    if (price == null) return '₹0.00';
    return '₹${price.toStringAsFixed(2)}';
  }

  // Get status color based on order status
  static Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Check if string is empty or null
  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  // Show loading dialog with safety checks
  static void showLoading({String message = 'Loading...'}) {
    if (Get.context == null || Get.overlayContext == null) {
      debugPrint('Cannot show loading dialog: GetX context not available');
      return;
    }
    
    if (!(Get.isDialogOpen ?? false)) {
      try {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } catch (e) {
        debugPrint('Failed to show loading dialog: $e');
      }
    }
  }

  // Hide loading dialog with safety checks
  static void hideLoading() {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      debugPrint('Failed to hide loading dialog: $e');
    }
  }

  // Basic input validation
  static bool isValidEmail(String? email) {
    if (email == null) return false;
    return GetUtils.isEmail(email);
  }

  static bool isValidPhone(String? phone) {
    if (phone == null) return false;
    return GetUtils.isPhoneNumber(phone);
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;
    return password.length >= 6;
  }
}