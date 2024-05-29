import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/alerts.dart';
import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';
import '../../components/passwordField.dart';
import '../common/main.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Alerts alerts = Alerts();

  /// Login method
  Future<void> login() async {
    if (_formKey.currentState!.validate()){
      FocusManager.instance.primaryFocus?.unfocus();
      try {
        /// Show loading
        showDialog(context: context, builder: (context)=>const Loader());

        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('register')
            .where('email', isEqualTo: emailController.text.trim())
            .where('pw', isEqualTo: passwordController.text)
            .get();

        final pref = await SharedPreferences.getInstance();
        await pref.setString("userID", result.docs.first.id);
        await pref.setString("type", "register");
        await pref.setString("email",emailController.text.trim());


        if (result.docs.isNotEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User logged in successfully')),
          );
          Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Main()),
          );
        } else {
          Navigator.pop(context);
          alerts.SimpleAlert(context, 'Invalid credentials');
        }
      } catch (error) {
        Navigator.pop(context);
        alerts.SimpleAlert(context, 'Invalid credentials');
      }
    }

  }

  /// E-mail validation
  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return value!.isEmpty || !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.background.withOpacity(0.0),
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                /// Login Text
                Text('Login',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: theme.primary),
                ),
                const SizedBox(height: 40),

                /// E-mail field
                NormalField(
                  controller: emailController,
                  label: 'E-mail',
                  textType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),

                /// Password field
                PasswordField(
                  controller: passwordController,
                  label: 'Password',
                ),
                const SizedBox(height: 40),

                /// Login button
                ButtonFill(text: 'Login', onTap:login),
                const SizedBox(height: 16),

                /// Register option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an Account?', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signup())),
                      child: Text('Register',
                        style: TextStyle(fontSize: 16, color: theme.primary, fontWeight: FontWeight.w600,),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
