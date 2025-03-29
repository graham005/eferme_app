import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eferme_app/pages/auth/signin_page.dart';
import 'package:eferme_app/pages/settings/change_password.dart';
import 'package:eferme_app/pages/settings/edit_profile.dart';
import 'package:eferme_app/services/auth_service.dart';
import 'package:eferme_app/widgets/auth_guard.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDarkMode = false;
  bool _isLoading = false;

  Future<void> _checkInternetAndNavigate(BuildContext context, Widget page) async {
    final authService = ref.read(authServiceProvider);
    final hasInternet = await authService.hasInternetConnection();

    if (hasInternet) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthGuard(child: page)),
        (route) => false,
      );
    } else {
      // Show a popup if there is no internet connection
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('You need an internet connection to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade400,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading user data'));
              }

              final userData = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userData?['photoURL'] != null
                          ? NetworkImage(userData!['photoURL'])
                          : const AssetImage('assets/profile.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['displayName'] ?? 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          userData?['email'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => _checkInternetAndNavigate(context, EditProfilePage()),
            ),
            const SizedBox(height: 5),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () => _checkInternetAndNavigate(context, ChangePasswordPage()),
            ),
            const SizedBox(height: 5),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            const SizedBox(height: 5),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Rate App'),
                onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                  title: const Text('Under Development'),
                  content: const Text('This feature is currently under development and will be available in a future update.'),
                  actions: [
                    TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                    ),
                  ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
              ? null
              : () async {
                setState(() {
                  _isLoading = true;
                });
                final authService = ref.read(authServiceProvider);
                try {
                  await authService.signOut();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SigninPage()), (route) => false);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout failed')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
                
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      // Online mode: Use Firebase user data
      return {
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
      };
    } else {
      // Offline mode: Fetch user data from SQLite
      final userId = await authService.getStoredUserId();
      if (userId != null) {
        return await authService.getUserFromSQLite(userId);
      }
    }
    return null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());