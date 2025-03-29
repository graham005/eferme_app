import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<bool>{
  NavigationNotifier(super.state);
  
  void navigateToHome(){
    state = true;
  }

  void navigateToLogin(){
    state = false;
  }
}

final navigationNotifierProvider = StateNotifierProvider<NavigationNotifier, bool>((ref) {
  return NavigationNotifier(false);
});