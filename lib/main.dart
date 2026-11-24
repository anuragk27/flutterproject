import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // gives us kReleaseMode
import 'firebase_options.dart';
import 'screens/home_page.dart';

// Switch from the terminal: flutter run --dart-define=DEVICE_PREVIEW=false
const bool enableDevicePreview = bool.fromEnvironment(
  'DEVICE_PREVIEW',
  defaultValue: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      // Only active in debug builds, and only if the flag is true
      enabled: enableDevicePreview && !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context), // needed by Device Preview
      builder: DevicePreview.appBuilder,     // needed by Device Preview
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      home: const HomePage(),
    );
  }
}
