import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/buttonFill.dart';
import '../../components/normalField.dart';
import 'category.dart';

class RegisterNGOFirst extends StatefulWidget {
  const RegisterNGOFirst({super.key});

  @override
  State<RegisterNGOFirst> createState() => _RegisterNGOFirstState();
}

class _RegisterNGOFirstState extends State<RegisterNGOFirst> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final estController = TextEditingController();
  final locationController = TextEditingController();
  final volunteerController = TextEditingController();
  final foundersController = TextEditingController();
  final emailController = TextEditingController();

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

  void _selectEst(){
    showDatePicker(
        barrierDismissible: false,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now()
    ).then((value){
      if(value!=null){
        setState(() {
          estController.text = "${value.year}-${value.month}-${value.day}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background.withOpacity(0.0),
        scrolledUnderElevation: 0,
        elevation: 0,

        /// Back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()=> Navigator.pop(context)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
            
                /// NGO register Text
                Text('Register your NGO',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: theme.primary),
                ),
                const SizedBox(height: 30),
            
                /// NGO name field
                NormalField(
                  controller: nameController,
                  label: 'Name of NGO',
                  textType: TextInputType.name,
                  validator: (value){
                    if(value!.isEmpty) return 'Enter Name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                /// Establishment date picker
                NormalField(
                  controller: estController,
                  label: 'Establishment Date',
                  textType: TextInputType.text,
                  onTap: _selectEst,
                  typeable: false,
                  suffix: IconButton(
                    onPressed: _selectEst,
                    icon: const Icon(CupertinoIcons.calendar),
                  ),
                  validator: (value){
                    if(value!.isEmpty) return 'Pick Establishment Date';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                /// Location field
                NormalField(
                  controller: locationController,
                  label: 'Location of NGO',
                  textType: TextInputType.streetAddress,
                  validator: (value){
                    if(value!.isEmpty) return 'Enter Location';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                /// Volunteers field
                NormalField(
                  controller: volunteerController,
                  label: 'Approx volunteers of NGO',
                  textType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty) return 'Enter valid number of volunteers';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                /// Founder/s field
                NormalField(
                  controller: foundersController,
                  label: 'Founder/s of NGO',
                  textType: TextInputType.text,
                  validator: (value){
                    if(value!.isEmpty) return 'Enter Names';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
            
                /// E-mail field
                NormalField(
                  controller: emailController,
                  label: 'E-mail of NGO',
                  textType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
            
                /// Register button
                ButtonFill(
                  text: 'Next',
                  onTap: (){
                    if (_formKey.currentState!.validate()) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Category(
                          name: nameController.text,
                          year: estController.text,
                          location: locationController.text,
                          volunteers: volunteerController.text,
                          founders: foundersController.text,
                          email: emailController.text
                      ))) ;
                    }
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
