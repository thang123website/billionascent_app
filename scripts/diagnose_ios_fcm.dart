import 'dart:io';

void main() {
  print('🔍 iOS FCM Configuration Diagnostic Tool\n');
  
  // Check iOS configuration file
  final iosConfigFile = File('ios/Runner/GoogleService-Info.plist');
  if (!iosConfigFile.existsSync()) {
    print('❌ GoogleService-Info.plist not found');
    return;
  }
  
  final content = iosConfigFile.readAsStringSync();
  print('📱 iOS Configuration Analysis:');
  
  // Check required keys
  final requiredKeys = [
    'API_KEY',
    'GCM_SENDER_ID', 
    'BUNDLE_ID',
    'PROJECT_ID',
    'GOOGLE_APP_ID',
    'CLIENT_ID',
    'REVERSED_CLIENT_ID'
  ];
  
  for (final key in requiredKeys) {
    if (content.contains('<key>$key</key>')) {
      print('   ✅ $key: Present');
    } else {
      print('   ❌ $key: Missing');
    }
  }
  
  // Check specific values
  if (content.contains('com.example.martfury')) {
    print('   ✅ Bundle ID: com.example.martfury');
  } else {
    print('   ❌ Bundle ID: Incorrect or missing');
  }
  
  if (content.contains('martfury-d6732')) {
    print('   ✅ Project ID: martfury-d6732');
  } else {
    print('   ❌ Project ID: Incorrect or missing');
  }
  
  if (content.contains('1:482507114156:ios:')) {
    print('   ✅ iOS App ID: Valid format');
  } else {
    print('   ❌ iOS App ID: Invalid or missing');
  }
  
  // Check for placeholder values
  if (content.contains('YOUR_') || content.contains('PLACEHOLDER')) {
    print('   ⚠️ WARNING: Contains placeholder values');
  }
  
  print('\n🔧 Diagnosis:');
  
  if (!content.contains('CLIENT_ID') || !content.contains('REVERSED_CLIENT_ID')) {
    print('❌ CRITICAL: Missing CLIENT_ID and REVERSED_CLIENT_ID');
    print('   This is why FCM tokens are not generating on your iPhone 15');
    print('   Solution: Download complete GoogleService-Info.plist from Firebase Console');
    print('');
    print('📝 Steps to fix:');
    print('   1. Go to https://console.firebase.google.com/project/martfury-d6732');
    print('   2. Project Settings → Your apps → iOS app');
    print('   3. Download GoogleService-Info.plist');
    print('   4. Replace ios/Runner/GoogleService-Info.plist');
    print('   5. Make sure file is added to Xcode project');
  } else {
    print('✅ Configuration appears complete');
    print('   If still getting fake tokens, check:');
    print('   - Notification permissions on device');
    print('   - Internet connectivity');
    print('   - Firebase project settings');
  }
  
  print('\n📋 Current Configuration Summary:');
  print('   File: ${iosConfigFile.path}');
  print('   Size: ${content.length} characters');
  print('   Lines: ${content.split('\n').length}');
  
  // Check if file is in Xcode project
  final xcodeProject = File('ios/Runner.xcodeproj/project.pbxproj');
  if (xcodeProject.existsSync()) {
    final xcodeContent = xcodeProject.readAsStringSync();
    if (xcodeContent.contains('GoogleService-Info.plist')) {
      print('   ✅ Added to Xcode project');
    } else {
      print('   ❌ NOT added to Xcode project');
      print('      Solution: Open Xcode and add the file to Runner target');
    }
  }
}
