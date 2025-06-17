import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'views/splash_screen.dart';
import 'views/cart_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const DarbsApp(),
    ),
  );
}

class DarbsApp extends StatelessWidget {
  const DarbsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darb\'s Food App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF8A2D20), // Darb's burgundy red
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
