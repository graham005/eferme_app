import 'package:eferme_app/pages/navigation_bar.dart';
import 'package:eferme_app/pages/settings/settings_page.dart';
import 'package:eferme_app/widgets/auth_guard.dart';
import 'package:eferme_app/widgets/form_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../stateNotifierProviders/auth_provider.dart' as auth;

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(auth.authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.white.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                controller: _nameController,
                hintText: 'Username',
                isPasswordField: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                controller: _emailController,
                hintText: 'Email',
                isPasswordField: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 4,))), (route) => false);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isProcessing = true;
                        });
                        try {
                          await authService.updateProfile(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _profileImage,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully!')),
                          );
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthGuard(child: Navigationbar(initialIndex: 4,))), (route) => false);

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update profile: $e')),
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
                        : const Text('Save', style: TextStyle(color: Colors.blueAccent)),
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