import 'dart:convert';
import 'package:martfury/src/service/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CartService extends BaseService {
  static const String _cartIdKey = 'cart_id';
  static const String _cartProductsKey = 'cart_products';

  static final StreamController<int> _cartCountController =
      StreamController<int>.broadcast();
  static Stream<int> get cartCountStream => _cartCountController.stream;

  static Future<String?> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cartIdKey);
  }

  static Future<void> saveCartId(String cartId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartIdKey, cartId);
  }

  static Future<void> clearCartId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartIdKey);
  }

  // Get list of product IDs in cart
  static Future<List<String>> getCartProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_cartProductsKey);

    if (productsJson == null) return [];

    try {
      final List<dynamic> products = jsonDecode(productsJson);
      return products.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // Save list of product IDs to localStorage
  static Future<void> _saveCartProducts(List<String> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartProductsKey, jsonEncode(products));
    _cartCountController.add(products.length);
  }

  // Add product ID to cart if not exists
  static Future<void> addProductToCart(String productId) async {
    final products = await getCartProducts();
    if (!products.contains(productId)) {
      products.add(productId);
      await _saveCartProducts(products);
    }
  }

  // Remove product ID from cart
  static Future<void> removeProductFromCart(String productId) async {
    final products = await getCartProducts();
    products.remove(productId);
    await _saveCartProducts(products);
  }

  // Get number of unique products in cart
  static Future<int> getCartCount() async {
    final products = await getCartProducts();
    return products.length;
  }

  // Clear all products from cart
  static Future<void> clearCartProducts() async {
    await _saveCartProducts([]);
  }

  Future<Map<String, dynamic>> getCartDetail(String cartId) async {
    try {
      final response = await get('/api/v1/ecommerce/cart/$cartId');

      return response;
    } catch (e) {
      throw Exception('Failed to get cart details: $e');
    }
  }

  Future<Map<String, dynamic>> createCartItem({
    required String productId,
    required int quantity,
    bool skipCartCount = false,
  }) async {
    try {
      final response = await post('/api/v1/ecommerce/cart', {
        'product_id': productId,
        'qty': quantity,
      });

      final data = response;

      if (!skipCartCount) {
        await saveCartId(data['id']);
        await addProductToCart(productId);
      }
      return data;
    } catch (e) {
      throw Exception('Failed to create cart item: $e');
    }
  }

  Future<void> removeCartItem({
    required String cartItemId,
    required String productId,
  }) async {
    try {
      await delete('/api/v1/ecommerce/cart/$cartItemId', {
        'product_id': productId,
      });

      await removeProductFromCart(productId);
    } catch (e) {
      throw 'Failed to remove item from cart: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await put('/api/v1/ecommerce/cart/$cartItemId', {
        'product_id': productId,
        'qty': quantity,
      });

      final data = response;

      await addProductToCart(productId);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required String cartId,
  }) async {
    try {
      final response = await post('/api/v1/ecommerce/coupon/apply', {
        'coupon_code': couponCode,
        'cart_id': cartId,
      });

      final data = response;

      return data;
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }

  Future<Map<String, dynamic>> removeCoupon({required String cartId}) async {
    try {
      final response = await post('/api/v1/ecommerce/coupon/remove', {
        'cart_id': cartId,
      });

      final data = response;

      return data;
    } catch (e) {
      throw Exception('Failed to remove coupon: $e');
    }
  }
}
