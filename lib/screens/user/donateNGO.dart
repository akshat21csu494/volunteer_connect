import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';
import '../../screens/user/upiPayment.dart';

class DonateNGO extends StatefulWidget {

  final String ngoID;
  const DonateNGO({super.key, required this.ngoID});

  @override
  State<DonateNGO> createState() => _DonateNGOState();
}

class _DonateNGOState extends State<DonateNGO> {

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? donationType;
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
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("register").doc(userID).get();
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

  Future<void> requestDonation() async {
    if(_formKey.currentState!.validate()){
      /// Show Circular progress bar
      showDialog(context: context, builder: (context)=>const Center(child: Loader()));

      final pref = await SharedPreferences.getInstance();
      userID = pref.getString("userID");

      await FirebaseFirestore.instance.collection("donation").doc().set({
        "ngo_id" :widget.ngoID,
        "user_id" : userID,
        "fname" : firstNameController.text,
        "lname" : lastNameController.text,
        "email" : emailController.text,
        "phno" : phoneController.text,
        "address" : addressController.text,
        "type_donation" : donationType,
        "amount" : amountController.text,
        "description" : descriptionController.text,
        "status" :"pending",
        "timestamp" : DateTime.now().millisecondsSinceEpoch,
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
        centerTitle: true,
        backgroundColor: theme.primary,
        title: Text('Donate', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                /// First Name
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

                /// Last Name
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

                /// E-mail
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

                /// Phone no
                NormalField(
                  controller: phoneController,
                  label: "Contact no.",
                  textType: TextInputType.number,
                  validator: (value){
                    if(value!.isEmpty) return "Enter Contact No.";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// Donation Type Dropdown
                DropdownButtonFormField<String>(
                  value: donationType,
                  items: ["Money","Goods","Food","Other"].map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (String? selected) {
                    setState(() {
                      donationType = selected;
                    });
                  },
                  style: TextStyle(fontSize: 18,color: theme.primary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    labelText: 'Donation Type',
                    enabledBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none
                    ),
                    errorBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.error, width: 2)
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: theme.primary, width: 2)
                    ),
                    filled: true,
                    fillColor: theme.primaryContainer,
                  ),
                  validator: (value) {
                    if(value!.isEmpty) return "Select Donation Type";
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// Amount => if donation type is money
                if(donationType == "Money")
                  NormalField(
                    controller: amountController,
                    label: 'Amount',
                    textType: TextInputType.number,
                    validator: (value){
                      if(value!.isEmpty) return "Enter Amount";
                      return null;
                    },
                  ),

                /// Details => if donation type is goods
                if(donationType == "Goods")
                  NormalField(
                    controller: amountController,
                    label: 'Details',
                    textType: TextInputType.text,
                    validator: (value){
                      if(value!.isEmpty) return "Enter Details";
                      return null;
                    },
                  ),

                /// Details => if donation type is food
                if(donationType == "Food")
                  NormalField(
                    controller: amountController,
                    label: 'Details',
                    textType: TextInputType.text,
                    validator: (value){
                      if(value!.isEmpty) return "Enter Details";
                      return null;
                    },
                  ),

                /// Details => if donation type is other
                if(donationType == "Other")
                  NormalField(
                    controller: amountController,
                    label: 'Details',
                    textType: TextInputType.text,
                    validator: (value){
                      if(value!.isEmpty) return "Enter Details";
                      return null;
                    },
                  ),

                if(donationType != null)
                  const SizedBox(height: 12),

                /// Address
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

                /// Msg field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    hintText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),

                /// Request button
                ButtonFill(
                  text: donationType == "Money" ? 'Next' : 'Request',
                  onTap: () {
                    if (donationType == "Money") {
                      if(_formKey.currentState!.validate()){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => UPIPayment(
                              amount: double.tryParse(amountController.text)!,
                              ngoId: widget.ngoID,
                              description: descriptionController.text == '' ? 'Donation' : descriptionController.text,
                              fname: firstNameController.text,
                              lname: lastNameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                              donationType: donationType!,
                            ),
                        ));
                      }
                    } else {
                      requestDonation();
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
