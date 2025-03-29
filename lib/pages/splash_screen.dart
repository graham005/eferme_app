import 'package:eferme_app/stateNotifierProviders/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to authStateProvider and navigate accordingly
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          Future.delayed(const Duration(seconds: 3), () { // Optional delay
            if (!context.mounted) return; // Ensure the context is still valid
            if (user == null) {
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              Navigator.pushReplacementNamed(context, '/navbar');
            }
          });
        },
        loading: () {},
        error: (error, stackTrace) {
          debugPrint('Error during authentication: $error');
          if (!context.mounted) return; // Ensure the context is still valid
          Navigator.pushReplacementNamed(context, '/login');
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xffc2c7b8),
      body: Center(
        child: Image.asset('assets/e-ferme logo.png'),
      ),
    );
  }
}