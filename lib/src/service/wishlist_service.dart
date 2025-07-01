import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:martfury/src/service/base_service.dart';

class WishlistService extends BaseService {
  static const String _wishlistIdKey = 'wishlist_id';

  static final StreamController<int> _wishlistCountController =
      StreamController<int>.broadcast();
  static Stream<int> get wishlistCountStream => _wishlistCountController.stream;

  static Future<String?> getWishlistId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wishlistIdKey);
  }

  static Future<void> saveWishlistId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wishlistIdKey, id);
    _wishlistCountController.add(await getWishlistCount());
  }

  Future<Map<String, dynamic>> createWishlist(String productId) async {
    try {
      final wishlistId = await getWishlistId();
      final url =
          wishlistId == null
              ? '/api/v1/ecommerce/wishlist'
              : '/api/v1/ecommerce/wishlist/$wishlistId';

      final response = await post(url, {'product_id': productId});

      await saveWishlistId(response['id'].toString());

      return response;
    } catch (e) {
      throw Exception('Failed to create wishlist: $e');
    }
  }

  Future<Map<String, dynamic>> removeFromWishlist(String productId) async {
    try {
      final wishlistId = await getWishlistId();
      final url = '/api/v1/ecommerce/wishlist/$wishlistId';

      final response = await delete(url, {'product_id': productId});

      await saveWishlistId(response['id'].toString());

      return response;
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  Future<Map<String, dynamic>> getWishlist() async {
    try {
      final wishlistId = await getWishlistId();

      final response = await get('/api/v1/ecommerce/wishlist/$wishlistId');

      return response['data'];
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  static Future<int> getWishlistCount() async {
    try {
      final wishlistId = await getWishlistId();

      if (wishlistId == null) {
        return 0;
      }
      final response = await BaseService().get(
        '/api/v1/ecommerce/wishlist/$wishlistId',
      );
      if (response['data'] != null && response['data']['items'] != null) {
        final items = response['data']['items'];
        if (items is Map) {
          return items.length;
        } else if (items is List) {
          return items.length;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
