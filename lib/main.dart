import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'screens/home_page.dart';

const bool enableDevicePreview = bool.fromEnvironment(
  'DEVICE_PREVIEW',
  defaultValue: true,
);

void main() {
  runApp(
    DevicePreview(
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
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const MyHomePage(),
    );
  }
}
