import 'package:flutter/material.dart';
import 'package:logbook_app_067/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_067/features/logbook/models/log_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV (.env file)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Failed to load .env - $e');
  }


  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter());
  await Hive.openBox<LogModel>('offline_logs');

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
        useMaterial3: true,
      ),
      home: const OnboardingView(),
    );
  }
}