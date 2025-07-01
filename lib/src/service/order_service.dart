import 'package:martfury/src/service/base_service.dart';
import 'package:martfury/src/model/order.dart';

class OrderService extends BaseService {
  Future<List<Order>> getOrders() async {
    try {
      final response = await get('/api/v1/ecommerce/orders');

      final List<dynamic> ordersJson = response['data'];

      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<Map<String, dynamic>> trackOrder({
    required String code,
    required String email,
  }) async {
    try {
      // Clean the order code (remove # if present for API call)
      final cleanCode = code.startsWith('#') ? code.substring(1) : code;

      // Try the primary API endpoint for order tracking
      final response = await post('/api/v1/ecommerce/orders/tracking', {
        'code': cleanCode,
        'email': email,
      });

      // Handle different response structures from the API
      if (response != null) {
        // If response has 'data' field, return it
        if (response['data'] != null) {
          return response['data'];
        }
        // If response has 'order' field directly, return the whole response
        else if (response['order'] != null) {
          return response;
        }
        // If response is the order data itself
        else if (response['id'] != null || response['code'] != null) {
          return {'order': response};
        }
      }

      throw Exception('Invalid response format from server');
    } catch (e) {
      // Try alternative endpoint if the primary one fails
      try {
        final response = await get('/api/v1/orders/tracking?code=${Uri.encodeComponent(code)}&email=${Uri.encodeComponent(email)}');

        if (response != null) {
          if (response['data'] != null) {
            return response['data'];
          } else if (response['order'] != null) {
            return response;
          }
        }
      } catch (fallbackError) {
        // If both endpoints fail, provide a helpful error message
        if (e.toString().contains('404') || e.toString().contains('not found')) {
          throw Exception('Order not found. Please check your order code and email address.');
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          throw Exception('Invalid email address for this order.');
        } else {
          throw Exception('Unable to track order. Please try again later.');
        }
      }

      throw Exception('Order not found. Please check your order code and email address.');
    }
  }
}
