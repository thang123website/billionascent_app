import 'package:flutter/foundation.dart';
import 'package:martfury/src/model/device_token.dart';
import 'package:martfury/src/service/base_service.dart';

class DeviceTokenService extends BaseService {
  /// Register device token with the API
  Future<Map<String, dynamic>> registerDeviceToken(
    DeviceToken deviceToken,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🌐 DeviceTokenService: Starting API call to /api/v1/device-tokens',
        );
      }

      final Map<String, Object> requestData = {};
      final tokenJson = deviceToken.toJson();

      // Convert to Map<String, Object> to satisfy BaseService requirements
      tokenJson.forEach((key, value) {
        if (value != null) {
          requestData[key] = value;
        }
      });

      if (kDebugMode) {
        print('🌐 DeviceTokenService: Request data: $requestData');
      }

      final response = await post('/api/v1/device-tokens', requestData);

      if (kDebugMode) {
        print('🌐 DeviceTokenService: API Response: $response');
        print('✅ Device token registered successfully');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 DeviceTokenService: API Error: $e');
        print('❌ Failed to register device token');
      }
      throw Exception('Failed to register device token: $e');
    }
  }

  /// Unregister device token from the API
  Future<Map<String, dynamic>> unregisterDeviceToken(String token) async {
    try {
      final response = await delete('/api/v1/device-tokens/by-token', {'token': token});

      if (kDebugMode) {
        print('Device token unregistered successfully: $response');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to unregister device token: $e');
      }
      throw Exception('Failed to unregister device token: $e');
    }
  }

  /// Update device token with new user information
  Future<Map<String, dynamic>> updateDeviceToken(
    DeviceToken deviceToken,
  ) async {
    try {
      final Map<String, Object> requestData = {};
      final tokenJson = deviceToken.toJson();

      // Convert to Map<String, Object> to satisfy BaseService requirements
      tokenJson.forEach((key, value) {
        if (value != null) {
          requestData[key] = value;
        }
      });

      final response = await put('/api/v1/device-tokens', requestData);

      if (kDebugMode) {
        print('Device token updated successfully: $response');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update device token: $e');
      }
      throw Exception('Failed to update device token: $e');
    }
  }

  /// Get all device tokens for the current user
  Future<List<DeviceToken>> getUserDeviceTokens() async {
    try {
      final response = await get('/api/v1/device-tokens');

      final List<dynamic> tokensJson = response['data'] ?? [];
      return tokensJson.map((json) => DeviceToken.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get user device tokens: $e');
      }
      throw Exception('Failed to get user device tokens: $e');
    }
  }
}
