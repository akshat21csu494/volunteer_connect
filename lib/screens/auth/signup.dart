import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';
import '../../components/passwordField.dart';
import 'login.dart';
import 'otpVerify.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final _formKey = GlobalKey<FormState>();
  String? gender;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  /// Get OTP Method
  Future<void> getOTP() async {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      /// Show Circular progress bar
      showDialog(context: context, builder: (context) => const Center(child: Loader()));

      await FirebaseAuth.instance.verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException ex) {
          Navigator.pop(context);
        },
        codeSent: (String verificationID, int? resendToken) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              OTPVerify(
                fname: firstNameController.text,
                lname: lastNameController.text,
                email: emailController.text,
                phone: '+91 ${phoneController.text}',
                gender: gender!,
                birthdate: dobController.text,
                address: addressController.text,
                password: passwordController.text,
                verificationID: verificationID,
              ),
          ));
          // Navigator.pop(context);
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
        phoneNumber: '+91 ${phoneController.text}'
      );
    }
  }

  /// Name Validation
  String? validateName(String? value){
    if(value!.isEmpty) return 'Enter a name';
    return null;
  }

  /// Phone Validation
  String? validatePhone(String? value) {
    if (value!.isEmpty) {
      return 'Enter mobile number';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value) && value.length != 10) {
      return 'Enter a valid phone number';
    }
    return null;
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

  /// onTap on birthdate field
  void _selectDOB(){
    showDatePicker(
      barrierDismissible: false,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
    ).then((value){
      if(value!=null){
        setState(() {
          dobController.text = "${value.year}-${value.month}-${value.day}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.background.withOpacity(0.0),
        scrolledUnderElevation: 0,
        elevation: 0,

        /// Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  /// Signup Text
                  Text('Signup',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: theme.primary),
                  ),
                  const SizedBox(height: 20),

                  /// First name field
                  NormalField(
                    controller: firstNameController,
                    label: 'First Name',
                    textType: TextInputType.name,
                    validator: validateName,
                  ),
                  const SizedBox(height: 12),

                  /// Last name field
                  NormalField(
                    controller: lastNameController,
                    label: 'Last Name',
                    validator: validateName,
                    textType: TextInputType.name,
                  ),
                  const SizedBox(height: 12),

                  /// E-mail field
                  NormalField(
                    controller: emailController,
                    label: 'E-mail',
                    textType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 12),

                  /// Phone number field
                  NormalField(
                    controller: phoneController,
                    label: 'Phone Number',
                    textType: TextInputType.phone,
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 12),

                  /// Gender DropDown
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: ["Male","Female","Other"].map((gen) => DropdownMenuItem<String>(
                      value: gen,
                      child: Text(gen),
                    )).toList(),
                    onChanged: (String? selected) {
                      setState(() {
                        gender = selected;
                      });
                    },
                    style: TextStyle(fontSize: 18,color: theme.primary),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                      labelText: 'Select Gender',
                      enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.error, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: theme.primaryContainer,
                    ),
                    validator: (value) {
                      if(gender == null) return "Select Gender";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  /// Birthdate field
                  NormalField(
                    controller: dobController,
                    label: 'Birthdate (DD-MM-YYYY)',
                    textType: TextInputType.text,
                    onTap: _selectDOB,
                    typeable: false,
                    suffix: IconButton(
                      onPressed: _selectDOB,
                      icon: const Icon(CupertinoIcons.calendar),
                    ),
                    validator: (value){
                      if(value!.isEmpty) return 'Enter a Birthdate';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  /// Address field
                  NormalField(
                    controller: addressController,
                    label: 'Address',
                    textType: TextInputType.streetAddress,
                    validator: (value){
                      if(value!.isEmpty) return 'Enter Address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  /// Password field
                  PasswordField(
                    controller: passwordController,
                    label: 'Password',
                  ),
                  const SizedBox(height: 12),

                  /// Get OTP button
                  ButtonFill(text: 'Get OTP', onTap: getOTP),

                  /// Login option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an Account?', style: TextStyle(fontSize: 16)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Login())),
                        child: Text('Login',
                          style: TextStyle(fontSize: 16, color: theme.primary, fontWeight: FontWeight.w600)
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}