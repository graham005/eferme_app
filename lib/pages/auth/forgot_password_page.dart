import 'package:eferme_app/services/auth_service.dart';
import 'package:eferme_app/widgets/form_container_widget.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Text("Forgot Password",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),),
                SizedBox( height: 50),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: 'Email',
                  isPasswordField: false,
                  validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading
                  ? null 
                  : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try{
                      await _authService.sendPasswordResetEmail(_emailController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent')));
                      Navigator.pop(context);
                    } catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset failed')));
                    }
                    finally {
                      setState(() {
                        _isLoading = false; 
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  child: Text('Reset Password',style: TextStyle(fontSize: 20))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}