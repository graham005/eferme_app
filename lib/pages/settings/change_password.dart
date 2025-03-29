import 'package:eferme_app/pages/navigation_bar.dart';
import 'package:eferme_app/pages/settings/settings_page.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:eferme_app/widgets/form_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stateNotifierProviders/auth_provider.dart' as auth;

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(auth.authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 50),
              FormContainerWidget(
                controller: _oldPasswordController,
                hintText: 'Old Password',
                isPasswordField: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                controller: _newPasswordController,
                hintText: 'New Password',
                isPasswordField: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                controller: _confirmPasswordController,
                hintText: 'Confirm New Password',
                isPasswordField: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: _isProcessing ? null : () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 4,))), (route) => false);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                  ),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: _isProcessing ? null : () async {
                    if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isProcessing = true;
                    });
                    try {
                      await authService.changePassword(
                      _oldPasswordController.text.trim(),
                      _newPasswordController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully!')),
                      );
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 4,))), (route) => false);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to change password: $e')),
                      );
                    } finally {
                      setState(() {
                      _isProcessing = false;
                      });
                    }
                    }
                  },
                  child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Save', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}