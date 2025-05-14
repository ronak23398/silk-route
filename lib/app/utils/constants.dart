class Constants {
  // Supabase configuration
  static const String supabaseUrl = 'https://jxfjfwtsenrharywayte.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4Zmpmd3RzZW5yaGFyeXdheXRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcwNzMzNDMsImV4cCI6MjA2MjY0OTM0M30.oIz8eRpIKaM3BrT5X1B4XpbdMP0EX08bxmhzaI5rq4o';

  // App strings
  static const String appName = 'ShopConnect';
  static const String tagline = 'Connect with local customers';
  
  // Auth messages
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed';
  static const String signupSuccess = 'Registration successful';
  static const String signupFailed = 'Registration failed';
  static const String logoutSuccess = 'Logged out successfully';
  static const String kycSubmitted = 'KYC submitted successfully. Pending approval.';
  static const String kycFailed = 'KYC submission failed';
  
  // Shop Owner messages
  static const String itemAdded = 'Product added successfully';
  static const String itemUpdated = 'Product updated successfully';
  static const String itemDeleted = 'Product deleted successfully';
  static const String orderAccepted = 'Order accepted';
  static const String orderDelivered = 'Order marked as delivered';
  
  // Error messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'Network error. Please check your connection';
  static const String sessionExpired = 'Session expired. Please login again';
  
  // Database table names
  static const String usersTable = 'users';
  static const String shopsTable = 'shops';
  static const String itemsTable = 'items';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
}

// Enum for shop approval status
enum ShopStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');
  
  final String value;
  const ShopStatus(this.value);
}

// Extension to convert enum to string
extension ShopStatusExtension on ShopStatus {
  String get value {
    switch (this) {
      case ShopStatus.pending:
        return 'pending';
      case ShopStatus.approved:
        return 'approved';
      case ShopStatus.rejected:
        return 'rejected';
      }
  }
}

// API Response Codes
class ApiResponseCode {
  static const int SUCCESS = 200;
  static const int CREATED = 201;
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int NOT_FOUND = 404;
  static const int SERVER_ERROR = 500;
}

class DocumentType {
  static const String ID_PROOF = 'id_proof';
  static const String BUSINESS_LICENSE = 'business_license';
}
// Enum for order status
enum OrderStatus {
  pending('pending'),
  accepted('accepted'),
  inProgress('in_progress'),
  delivered('delivered'),
  cancelled('cancelled');
  
  final String value;
  const OrderStatus(this.value);
}

// Extension to convert enum to string
extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      }
  }
}

// Add this to your constants.dart file

class ShopCategories {
  static const String CLOTHING = 'Clothing';
  static const String ELECTRONICS = 'Electronics';
  static const String FOOD = 'Food & Beverages';
  static const String GROCERIES = 'Groceries';
  static const String HEALTH = 'Health & Beauty';
  static const String HOME = 'Home & Kitchen';
  static const String BOOKS = 'Books & Stationery';
  static const String TOYS = 'Toys & Games';
  static const String OTHER = 'Other';
  
  static const List<String> values = [
    CLOTHING,
    ELECTRONICS,
    FOOD,
    GROCERIES,
    HEALTH,
    HOME,
    BOOKS,
    TOYS,
    OTHER,
  ];
}