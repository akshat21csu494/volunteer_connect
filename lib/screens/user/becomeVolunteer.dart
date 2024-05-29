import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';

class BecomeVolunteer extends StatefulWidget {

  final String ngoID;

  const BecomeVolunteer({
    super.key,
    required this.ngoID,
  });

  @override
  State<BecomeVolunteer> createState() => _BecomeVolunteerState();
}

class _BecomeVolunteerState extends State<BecomeVolunteer> {

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final educationController = TextEditingController();
  final daysInWeekController = TextEditingController();
  final hoursInWeekController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? userID;
  late DocumentSnapshot userData;

  @override
  initState(){
    super.initState();
    loadData();
  }

  loadData() async {

    final pref = await SharedPreferences.getInstance();
    userID = pref.getString("userID");

    if(userID != null){
      userData = await FirebaseFirestore.instance.collection("register").doc(userID).get();
      if(userData.exists){
        setState(() {
          firstNameController.text = userData['fname'] ?? "";
          lastNameController.text = userData['lname'] ?? "";
          emailController.text = userData['email'] ?? "";
          phoneController.text = userData['phno'] ?? "";
          addressController.text = userData['address'] ?? "";
        });
      }
    }
  }

  Future<void> request() async {
    if(_formKey.currentState!.validate()){
      /// Show Circular progress bar
      showDialog(context: context, builder: (context)=>const Center(child: Loader()));

      final pref = await SharedPreferences.getInstance();
      userID = pref.getString("userID");

      await FirebaseFirestore.instance.collection("volunteers").doc().set({
        "ngo_id" :widget. ngoID,
        "user_id" : userID,
        "fname" : firstNameController.text,
        "lname" : lastNameController.text,
        "email" : emailController.text,
        "phno" : phoneController.text,
        "address" : addressController.text,
        "days_in_week" : daysInWeekController.text,
        "time_hr_inweek" : hoursInWeekController.text,
        "education" : educationController.text,
        "status" : "pending",
        "timestamp" : DateTime.now().millisecondsSinceEpoch
      });
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Become Volunteer', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                NormalField(
                  controller: firstNameController,
                  label: "First Name",
                  textType: TextInputType.text,
                  validator: (value){
                    if(value!.isEmpty) return "Enter First Name";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: lastNameController,
                  label: "Last Name",
                  textType: TextInputType.text,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Last Name";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: emailController,
                  label: "E-mail",
                  textType: TextInputType.emailAddress,
                  validator: (value){
                    if(value!.isEmpty) return "Enter E-mail";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: phoneController,
                  label: "Contact No.",
                  textType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Contact No.";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: addressController,
                  label: 'Address',
                  textType: TextInputType.streetAddress,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Address";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: educationController,
                  label: 'Educational Qualification',
                  textType: TextInputType.text,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Educational Qualification";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: daysInWeekController,
                  label: 'Available Days in Week',
                  textType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Available Days in Week";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                NormalField(
                  controller: hoursInWeekController,
                  label: 'Available Hours in Week',
                  textType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Available Hours in Week";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                ButtonFill(text: 'Request', onTap: request),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
