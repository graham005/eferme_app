import 'package:eferme_app/pages/auth/signin_page.dart';
import 'package:eferme_app/stateNotifierProviders/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eferme_app/services/auth_service.dart';

class AuthGuard extends ConsumerWidget{
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authServiceProvider);
      
      return FutureBuilder(
        future: authState.getStoredUserId(),
        builder: (context, snapshot) {
          // print('AuthGuard - User ID: ${snapshot.data}');

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return child;
            }
            return SigninPage();
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      );
    // return authState.when(
    //   data: (user) {
    //     if (user == null) {
    //       // User is not logged in, redirect to login page
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         Navigator.pushAndRemoveUntil(
    //           context, 
    //           MaterialPageRoute(builder: (context) => SigninPage()), 
    //           (route) => false
    //         );
    //       });
    //       return Container();
    //     }
    //     else{
    //       // User is logged in, show the requested page
    //       return child;
    //     }
    //   },
    //   loading: () => Center(child: CircularProgressIndicator()),
    //   error: (error, stackTrace) => Center(child: Text('An error occurred: $error')),
    // );
  }
}