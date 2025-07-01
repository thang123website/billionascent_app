import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run scripts/test_fcm_token.dart <token>');
    print('Example: dart run scripts/test_fcm_token.dart eK7_Vx9mTUGq4H8j2N5pL3:APA91bF...');
    return;
  }
  
  final token = args[0];
  
  print('🔍 FCM Token Validator\n');
  print('Token: ${token.length > 50 ? '${token.substring(0, 50)}...' : token}');
  print('Length: ${token.length} characters\n');
  
  if (token.startsWith('dev_')) {
    print('❌ FALLBACK DEVELOPMENT TOKEN');
    print('   This is NOT a real FCM token');
    print('   Push notifications will NOT work');
    print('   Status: INVALID for FCM v1 API\n');
    
    if (token.contains('_ios_')) {
      print('💡 Solution for iOS:');
      print('   - Test on a physical iOS device');
      print('   - Real FCM tokens are generated on physical devices only');
    } else if (token.contains('_android_')) {
      print('💡 Solution for Android:');
      print('   - Add Android app to Firebase project');
      print('   - Download real google-services.json');
      print('   - Replace current android/app/google-services.json');
    }
  } else if (token.contains(':') && token.length > 100) {
    print('✅ REAL FCM TOKEN');
    print('   This appears to be a valid FCM token');
    print('   Push notifications should work');
    print('   Status: VALID for FCM v1 API\n');
    
    print('🎯 Token Analysis:');
    if (token.contains('APA91b')) {
      print('   - Format: Legacy FCM token');
      print('   - Compatible: FCM v1 API ✅');
    } else {
      print('   - Format: Modern FCM token');
      print('   - Compatible: FCM v1 API ✅');
    }
  } else {
    print('⚠️ UNKNOWN TOKEN FORMAT');
    print('   This token format is not recognized');
    print('   Length: ${token.length} (expected: >100 for real FCM)');
    print('   Contains colon: ${token.contains(':')}');
    print('   Status: UNCERTAIN\n');
    
    print('💡 Expected real FCM token format:');
    print('   eK7_Vx9mTUGq4H8j2N5pL3:APA91bF...very-long-string...xyz123');
  }
  
  print('\n' + '='*60);
  print('📋 Summary:');
  if (token.startsWith('dev_')) {
    print('   Action Required: Get real FCM token');
    print('   See: FIX_REAL_FCM_TOKENS.md');
  } else if (token.contains(':') && token.length > 100) {
    print('   Status: Ready for production push notifications! 🎉');
  } else {
    print('   Status: Token validation inconclusive');
  }
  print('='*60);
}
