import 'package:eferme_app/pages/navigation_bar.dart';
import 'package:eferme_app/pages/splash_screen.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/auth/signin_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/calculator_page.dart';
import 'pages/diseaseDetection/disease_detection_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/weather/weather_page.dart';
import 'pages/homepage.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authService = AuthService();
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => SigninPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/navbar': (context) => AuthGuard(child: Navigationbar()),
        '/home': (context) => AuthGuard(child: HomePage()),
        '/calculator': (context) => AuthGuard(child: CalculatorPage()),
        '/weather': (context) => AuthGuard(child: WeatherPage()),
        '/disease': (context) => AuthGuard(child: DiseaseDetectionPage()),
        '/settings': (context) => AuthGuard(child: SettingsPage()),

      },
    );
  }
}

