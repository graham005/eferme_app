import 'package:eferme_app/pages/Auth/signin_page.dart';
import 'package:eferme_app/services/auth_service.dart';
import 'package:eferme_app/widgets/form_container_widget.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 70),
                  Text ('Sign Up', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.green)),
                  SizedBox(height: 80),
                  FormContainerWidget(
                    controller: _nameController,
                    hintText: 'Name',
                    isPasswordField: false,
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 20),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: 'Email',
                    isPasswordField: false,
                    validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                  ),
                  SizedBox(height: 20),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPasswordField: true,
                    validator: (value) => value!.length < 8 ? 'Please enter valid password' : null,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading
                    ? null
                    : () async {
                      if (_formKey.currentState!.validate()){
                        setState(() {
                          _isLoading = true;
                        });
                        try{
                          await _authService.signUp(
                            _emailController.text.trim(), 
                            _passwordController.text.trim(), 
                            _nameController.text.trim(),
                            null
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created')));
                          Navigator.pop(context);
                          Navigator.pushNamed(context, ('/login'));
                        } catch(e){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SignUp failed')));
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text('Sign Up',style: TextStyle(fontSize: 20, color: Colors.white),),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SigninPage()), (route) => false),
                    child: Text("Already have an account? Login")
                  ),
                ],
              )
              ),
            ),
        ),
      ),
    );
  }
}