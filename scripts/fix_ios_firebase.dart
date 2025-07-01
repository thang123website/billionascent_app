import 'dart:io';

void main() {
  print('🔧 iOS Firebase Configuration Fixer\n');

  final projectFile = File('ios/Runner.xcodeproj/project.pbxproj');
  final plistFile = File('ios/Runner/GoogleService-Info.plist');

  if (!plistFile.existsSync()) {
    print('❌ GoogleService-Info.plist not found in ios/Runner/');
    print('   Please add the file first from Firebase Console');
    return;
  }

  if (!projectFile.existsSync()) {
    print('❌ Xcode project file not found');
    return;
  }

  final content = projectFile.readAsStringSync();

  // Check if GoogleService-Info.plist is properly configured
  if (content.contains('GoogleService-Info.plist')) {
    // Check if it's in the correct Runner group
    final runnerGroupMatch = RegExp(r'97C146F01CF9000F007C117D /\* Runner \*/ = \{[^}]*children = \([^)]*10F9AB642E055919005E2F15 /\* GoogleService-Info\.plist \*/[^)]*\)', multiLine: true, dotAll: true);

    if (runnerGroupMatch.hasMatch(content)) {
      print('✅ GoogleService-Info.plist properly configured in Xcode project');
      print('   File is correctly placed in Runner group');
    } else {
      print('⚠️  GoogleService-Info.plist found but may be in wrong location');
      print('   The file should be in the Runner group, not root group');
      print('');
      print('🛠️  MANUAL FIX REQUIRED:');
      print('   1. Open: open ios/Runner.xcworkspace');
      print('   2. In Xcode, find GoogleService-Info.plist in project navigator');
      print('   3. Drag it into the "Runner" folder (not root)');
      print('   4. Make sure "Add to target: Runner" is checked');
      print('');
      print('🧪 Then test with: flutter clean && flutter run');
    }
    return;
  }

  print('⚠️  GoogleService-Info.plist found but not added to Xcode project');
  print('');
  print('🛠️  MANUAL FIX REQUIRED:');
  print('   1. Open: open ios/Runner.xcworkspace');
  print('   2. Right-click "Runner" folder in Xcode');
  print('   3. Select "Add Files to Runner"');
  print('   4. Choose ios/Runner/GoogleService-Info.plist');
  print('   5. Make sure "Add to target: Runner" is checked');
  print('   6. Click "Add"');
  print('');
  print('🧪 Then test with: flutter clean && flutter run');
  print('');
  print('💡 Alternative: Use Xcode to drag-drop the file into the project');
}
