import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../common/main.dart';

class OTPVerify extends StatefulWidget {

  final String fname;
  final String lname;
  final String email;
  final String phone;
  final String gender;
  final String birthdate;
  final String address;
  final String password;
  final String verificationID;

  const OTPVerify({
    super.key,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthdate,
    required this.address,
    required this.password,
    required this.verificationID,
  });

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {

  final otp = TextEditingController();

  Future<void> signUp() async {

    /// Show Circular progress bar
    showDialog(context: context, builder: (context)=>const Center(child: Loader()));

    PhoneAuthProvider.credential(
      verificationId: widget.verificationID,
      smsCode: otp.text
    );
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: widget.email,
      password: widget.password,
    );

    final pref = await SharedPreferences.getInstance();
    await pref.setString("userID", userCredential.user!.uid );
    await pref.setString("type", "register");

    await FirebaseFirestore.instance.collection("register").doc().set({
      'fname': widget.fname,
      'lname': widget.lname,
      'email': widget.email,
      'phone': widget.phone,
      'gen':widget.gender,
      'birthdate': widget.birthdate,
      'address':widget.address,
      'pw':widget.password,
      'logo':'',
      'timestamp':DateTime.now().millisecondsSinceEpoch,
    });

    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Main()));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP is correct")));
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

        /// Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [

              /// Title
              Text('OTP Verification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: theme.primary),
              ),

              /// OTP sent on text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('6 digit code sent on \n${widget.phone}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              /// OTP Animation
              Lottie.asset('assets/otp.json',
                height: 200, width: 200,
              ),

              /// OTP Fields
              PinCodeTextField(
                appContext: context,
                length: 6,
                enableActiveFill: true,
                cursorColor: theme.primary,
                animationType: AnimationType.fade,
                keyboardType: const TextInputType.numberWithOptions(),
                pinTheme: PinTheme(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  shape: PinCodeFieldShape.box,
                  inactiveFillColor: theme.primaryContainer,
                  inactiveColor: theme.primaryContainer,
                  selectedColor: theme.primary,
                  selectedFillColor: theme.primaryContainer,
                  activeColor: theme.primary,
                  activeFillColor: theme.primaryContainer
                ),
              ),

              const SizedBox(height: 12),

              /// Signup button
              ButtonFill(text: 'Signup', onTap: signUp),
            ],
          ),
        ),
      )
    );
  }
}
