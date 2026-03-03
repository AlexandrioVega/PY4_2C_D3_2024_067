import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load ENV
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Failed to load .env - $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const OnboardingView(),
    );
  }
}