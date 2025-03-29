import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eferme_app/services/auth_service.dart';

// Create a provider for FirebaseAuth
final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// Stream Provider for user authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authProvider);
  final authService = ref.read(authServiceProvider);

  return auth.authStateChanges().asyncMap((user) async{
    // If user is null, check if user is logged in offline
    if(user == null){
      // Check if user is logged in locally
      final isLoggedInOffline = await authService.isUserLoggedInLocally();
      if(isLoggedInOffline){
        //Fetch data from SQLite
        final userId = await authService.getStoredUserId();
        final userData = await authService.getUserFromSQLite(userId);
        print(userData);
      }
      return null;
    }

    return user;
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());