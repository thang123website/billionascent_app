import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:martfury/src/service/base_service.dart';

class CompareService extends BaseService {
  static const String _compareIdKey = 'compare_id';

  static final StreamController<int> _compareCountController =
      StreamController<int>.broadcast();
  static Stream<int> get compareCountStream => _compareCountController.stream;

  static Future<String?> getCompareId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_compareIdKey);
  }

  static Future<void> saveCompareId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_compareIdKey, id);
    _compareCountController.add(await getCompareCount());
  }

  Future<Map<String, dynamic>> createCompare(String productId) async {
    try {
      final compareId = await getCompareId();
      final url =
          compareId == null
              ? '/api/v1/ecommerce/compare'
              : '/api/v1/ecommerce/compare/$compareId';

      final response = await post(url, {'product_id': productId});

      await saveCompareId(response['id'].toString());

      return response;
    } catch (e) {
      throw Exception('Failed to create compare: $e');
    }
  }

  Future<Map<String, dynamic>> removeFromCompare(String productId) async {
    try {
      final compareId = await getCompareId();
      final url = '/api/v1/ecommerce/compare/$compareId';

      final response = await delete(url, {'product_id': productId});

      await saveCompareId(response['id'].toString());

      return response;
    } catch (e) {
      throw Exception('Failed to remove from compare: $e');
    }
  }

  Future<Map<String, dynamic>> getCompare() async {
    try {
      final compareId = await getCompareId();

      if (compareId == null) {
        return {'data': []};
      }

      final response = await get('/api/v1/ecommerce/compare/$compareId');

      return response['data'];
    } catch (e) {
      throw Exception('Failed to get compare: $e');
    }
  }

  static Future<int> getCompareCount() async {
    try {
      final compareId = await getCompareId();

      if (compareId == null) {
        return 0;
      }
      final response = await BaseService().get(
        '/api/v1/ecommerce/compare/$compareId',
      );
      if (response['data'] != null && response['data']['count'] != null) {
        return response['data']['count'];
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
