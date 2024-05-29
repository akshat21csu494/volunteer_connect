import 'package:flutter/material.dart';

import '../../components/buttonFill.dart';
import '../../components/buttonOutline.dart';
import '../auth/login.dart';
import '../auth/registerNGOFirst.dart';
import '../auth/loginNGO.dart';
import '../auth/signup.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.background.withOpacity(0.0),
        leading: const Icon(Icons.abc,color: Colors.transparent),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text('Welcome to\nSevaSanskriti',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: theme.primary,),
                ),
                const Spacer(),

                ButtonFill(
                  text: 'Login',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const Login())),
                ),
                const SizedBox(height: 8),

                ButtonOutline(
                  text: 'Signup',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const Signup())),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const RegisterNGOFirst())),
                      child: Text('Register your NGO',
                        style: TextStyle(color: theme.primary, fontSize: 18),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginNGO())),
                      child: Text('Login NGO',
                        style: TextStyle(color: theme.primary, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
