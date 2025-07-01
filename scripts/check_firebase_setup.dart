import 'dart:io';
import 'dart:convert';

void main() {
  print('🔥 Firebase Setup Checker for MartFury Flutter App\n');
  
  bool allGood = true;
  
  // Check Android configuration
  print('📱 Checking Android Configuration...');
  final androidConfigFile = File('android/app/google-services.json');
  if (androidConfigFile.existsSync()) {
    try {
      final content = androidConfigFile.readAsStringSync();
      final config = jsonDecode(content);
      
      if (config['project_info']['project_id'] == 'martfury-d6732') {
        print('   ✅ Android google-services.json found and project ID matches');
        
        final packageName = config['client'][0]['client_info']['android_client_info']['package_name'];
        if (packageName == 'com.example.martfury') {
          print('   ✅ Package name matches: $packageName');
        } else {
          print('   ❌ Package name mismatch: $packageName (expected: com.example.martfury)');
          allGood = false;
        }
      } else {
        print('   ❌ Project ID mismatch in google-services.json');
        allGood = false;
      }
    } catch (e) {
      print('   ❌ Error reading google-services.json: $e');
      allGood = false;
    }
  } else {
    print('   ⚠️  google-services.json not found (template exists)');
    print('   📝 Download from Firebase Console and replace the template');
    allGood = false;
  }
  
  // Check iOS configuration
  print('\n🍎 Checking iOS Configuration...');
  final iosConfigFile = File('ios/Runner/GoogleService-Info.plist');
  if (iosConfigFile.existsSync()) {
    final content = iosConfigFile.readAsStringSync();
    if (content.contains('martfury-d6732') && content.contains('com.example.martfury')) {
      print('   ✅ iOS GoogleService-Info.plist found with correct identifiers');
    } else {
      print('   ❌ iOS configuration file has incorrect identifiers');
      allGood = false;
    }
  } else {
    print('   ⚠️  GoogleService-Info.plist not found (template exists)');
    print('   📝 Download from Firebase Console and replace the template');
    allGood = false;
  }
  
  // Check build configuration
  print('\n🔧 Checking Build Configuration...');
  final androidBuildFile = File('android/app/build.gradle.kts');
  if (androidBuildFile.existsSync()) {
    final content = androidBuildFile.readAsStringSync();
    if (content.contains('com.google.gms.google-services')) {
      print('   ✅ Google Services plugin configured in Android build');
    } else {
      print('   ❌ Google Services plugin missing in Android build');
      allGood = false;
    }
  }
  
  // Final result
  print('\n' + '='*50);
  if (allGood) {
    print('🎉 Firebase setup is complete!');
    print('   Run: flutter run');
    print('   Check debug console for FCM token');
  } else {
    print('⚠️  Firebase setup incomplete');
    print('   Follow instructions in setup_firebase.md');
    print('   Replace template files with real Firebase config files');
  }
  print('='*50);
}
