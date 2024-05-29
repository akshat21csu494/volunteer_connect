// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';
import '../../components/passwordField.dart';
import '../common/welcome.dart';

class RegisterNGOLast extends StatefulWidget {

  final String name;
  final String year;
  final String location;
  final String volunteers;
  final String founders;
  final String email;
  final String category;

  const RegisterNGOLast({
    super.key,
    required this.name,
    required this.year,
    required this.location,
    required this.volunteers,
    required this.founders,
    required this.email,
    required this.category
  });

  @override
  State<RegisterNGOLast> createState() => _RegisterNGOLastState();
}

class _RegisterNGOLastState extends State<RegisterNGOLast> {
  final _formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPWController = TextEditingController();

  Future<void> sendEmail(String recipientEmail, String name, String activity) async {
    final smtpServer = gmail('itsfenu21@gmail.com', 'mwxqfmqtkmxsrjdv');

    final message = Message()
      ..from = const Address('itsfenu21@gmail.com', 'SevaSanskriti')
      ..recipients.add(recipientEmail)
      ..subject = 'Registration of Your NGO'
      ..text = "Dear $name,\n\n"
          "I hope this email finds you well. My name is Fenansi Indorwala, and I am reaching out to you on behalf of Seva Sanskriti, an organization dedicated to all the NGOs to get the donation and volunteer easily and free of cost.\n\n"
          "We are pleased to inform you that we have received your registration request and are delighted to welcome you as a registered NGO with Seva Sanskriti. Your commitment to $activity aligns perfectly with our values, and we are excited about the potential for collaboration and impact in the future.\n\n"
          "To formalize your registration, we kindly request the following documents:\n\n"
          "1. NGO Registration Certificate: Please provide a copy of your official registration certificate issued by the relevant authority.\n"
          "2. Founder Identification: Please provide identification documents for the founder(s) of your organization.\n\n"
          "You can submit these documents by coming to our office address:\n\n"
          "Seva Sanskriti\n"
          "123, ABC Apartment\n"
          "XYZ Road, Vesu\n"
          "Surat\n\n"
          "Once we have received and reviewed these documents, we will finalize your registration process and send you a confirmation email along with your registration certificate.\n\n"
          "If you have any questions or need further assistance, please don't hesitate to contact us. We look forward to working together to make a meaningful difference in our community.\n\n"
          "Thank you for your cooperation and dedication to our shared goals.\n\n"
          "Warm regards,\n\n"
          "Fenansi Indorwala\n"
          "CEO\n"
          "Seva Sanskriti\n"
          "+91 9682910737\n"
          "sevasanskriti@gmail.com\n"
          "123, ABC Apartment\n"
          "XYZ Road, Vesu\n"
          "Surat\n\n"
          "https://sevasanskriti.com";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (passwordController.text == confirmPWController.text) {
        showDialog(context: context, builder: (context) => const Center(child: Loader()));

        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: passwordController.text,
        );

        final pref = await SharedPreferences.getInstance();
        await pref.setString("userID", userCredential.user!.uid);
        await pref.setString("type", "registerNGO");

        await FirebaseFirestore.instance.collection("registerNGO").doc().set({
          'nm': widget.name,
          'yr': widget.year,
          'address': widget.location,
          'offline_vol': widget.volunteers,
          'fn': widget.founders,
          'email': widget.email,
          'phno': phoneController.text,
          'activities': widget.category,
          'pw': passwordController.text,
          'description': "",
          'about': "",
          'link': "",
          'logo': "",
          'reg_certificate': "",
          'upi': "",
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'status': "pending",
        });
        // sendEmail(widget.email, widget.name, widget.category);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Welcome()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("NGO Registered Successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Both passwords do not match")));
      }
    }
  }


  /// Phone Validation
  String? validatePhone(String? value) {
    if (value!.isEmpty) {
      return 'Enter mobile number';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
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
          onPressed: () => Navigator.pop(context)
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 90),

              /// NGO register Text
              Text('Final Step',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: theme.primary)
              ),
              const SizedBox(height: 40),

              /// Number field
              NormalField(
                controller: phoneController,
                label: 'Phone number of NGO',
                textType: TextInputType.number,
                validator: validatePhone,
              ),
              const SizedBox(height: 16),

              /// Password field
              PasswordField(
                controller: passwordController,
                label: 'Password',
              ),
              const SizedBox(height: 16),

              /// Confirm Password field
              PasswordField(
                controller: confirmPWController,
                label: 'Confirm Password',
              ),
              const SizedBox(height: 40),

              /// Register button
              ButtonFill(text: 'Sign Up', onTap: signUp),
            ],
          ),
        ),
      ),
    );
  }
}