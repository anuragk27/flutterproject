// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
// import 'screens/home_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // gives us kReleaseMode
import 'screens/home_page.dart';

// const bool enableDevicePreview = bool.fromEnvironment(
//   'DEVICE_PREVIEW',
//   defaultValue: true,
// );

// void main() {
//   runApp(
//     DevicePreview(
//       enabled: enableDevicePreview && !kReleaseMode,
//       builder: (context) => const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       locale: DevicePreview.locale(context),
//       builder: DevicePreview.appBuilder,
//       home: const HomePage(),
//     );
//   }
// }



// Switch from the terminal: flutter run --dart-define=DEVICE_PREVIEW=false

const bool enableDevicePreview = bool.fromEnvironment(
  'DEVICE_PREVIEW',
  defaultValue: true,
);

void main() {
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
      // Light theme
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      home: const HomePage(), // was MyHomePage
    );
  }
}
