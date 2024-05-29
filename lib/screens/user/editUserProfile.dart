import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/alerts.dart';
import '../../components/loader.dart';
import '../../components/buttonFill.dart';
import '../../components/normalField.dart';

class EditUserProfile extends StatefulWidget {

  final Map userData;

  const EditUserProfile({super.key, required this.userData});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {

  final firstNameEdit = TextEditingController();
  final lastNameEdit = TextEditingController();
  final aboutEdit = TextEditingController();
  final emailEdit = TextEditingController();
  final phoneEdit = TextEditingController();
  final dobEdit = TextEditingController();
  final addressEdit = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Uint8List? _image;
  File? selectedIMage;

  Alerts alerts = Alerts();

  @override
  void initState() {
    super.initState();
    firstNameEdit.text = widget.userData["fname"];
    lastNameEdit.text = widget.userData["lname"];
    aboutEdit.text = widget.userData["about"] ?? "";
    phoneEdit.text = widget.userData["phno"];
    emailEdit.text = widget.userData["email"];
    dobEdit.text = widget.userData["birthdate"];
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(childName);
      UploadTask uploadTask = ref.putData(
        file,
        SettableMetadata(contentType: 'image/jpeg/jpg'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  String generateAutoChildName() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String randomString = DateTime.now().microsecondsSinceEpoch.toString().substring(6);
    String uniqueFileName = '$timestamp-$randomString';
    return uniqueFileName;
  }

  Future<void> updateData() async {
    if(_formKey.currentState!.validate()){
      String? imageUrl;
      String childName = generateAutoChildName();

      try {
        showDialog(context: context, builder: (context)=>const Loader());

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('register')
            .where('email', isEqualTo: widget.userData['email'])
            .get();

        if(selectedIMage==null){
          print("No image found");
        }else{
          imageUrl=await uploadImageToStorage("ngo_profile/$childName",_image!);
        }

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userRef = querySnapshot.docs.first.reference;

          /// If profile picture is not changed
          if(_image == null){
            await userRef.update({
              'fname': firstNameEdit.text,
              'lname': lastNameEdit.text,
              'about': aboutEdit.text,
              'phno': phoneEdit.text,
              'email':emailEdit.text,
              'birthdate' : dobEdit.text
            });
          }

          /// If profile picture is changed
          if(_image != null){
            await userRef.update({
              'fname': firstNameEdit.text,
              'lname': lastNameEdit.text,
              'about': aboutEdit.text,
              'phno': phoneEdit.text,
              'logo':imageUrl??'',
              'email':emailEdit.text,
              'birthdate' : dobEdit.text
            });
          }

          /// Update email shared preference too
          final pref = await SharedPreferences.getInstance();
          await pref.setString("email",emailEdit.text.trim());

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (error) {
        print('Error updating user profile: $error');
      }
    }
  }

  void changeProfilePicture(){
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context)=>SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
                if (returnImage == null) return;
                setState(() {
                  selectedIMage = File(returnImage.path);
                  _image = File(returnImage.path).readAsBytesSync();
                });
                Navigator.of(context).pop();
              },
              child: const Column(
                children: [
                  Icon(CupertinoIcons.camera,size: 32),
                  Text('Camera',style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (returnImage == null) return;
                setState(() {
                  selectedIMage = File(returnImage.path);
                  _image = File(returnImage.path).readAsBytesSync();
                });
                Navigator.of(context).pop();
              },
              child: const Column(
                children: [
                  Icon(CupertinoIcons.photo,size: 32),
                  Text('Gallery',style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      )
    );
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
          dobEdit.text = "${value.year}-${value.month}-${value.day}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text('Edit Profile', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          /// Profile Picture
                          if(widget.userData['logo'] == "" && _image == null)
                            const CircleAvatar(
                              radius: 80,
                              backgroundImage: AssetImage('assets/user.jpeg'),
                            ),
                          if(widget.userData['logo'] != "")
                            CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(widget.userData['logo'])
                            ),
                          if(_image != null)
                            CircleAvatar(
                              backgroundColor: theme.primary,
                              radius: 80,
                              backgroundImage: MemoryImage(_image!),
                            ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              backgroundColor: theme.primary,
                              child: IconButton(
                                onPressed: changeProfilePicture,
                                icon: const Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      NormalField(
                        controller: firstNameEdit,
                        label: "First Name",
                        textType: TextInputType.name,
                        validator: (value){
                          if(value!.isEmpty) return "Enter First Name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      NormalField(
                        controller: lastNameEdit,
                        label: "Last Name",
                        textType: TextInputType.name,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Last Name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      NormalField(
                        controller: aboutEdit,
                        label: 'About',
                        textType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 8),
                      NormalField(
                        controller: phoneEdit,
                        label: 'Phone No.',
                        textType: TextInputType.phone,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Phone No.";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      NormalField(
                        controller: emailEdit,
                        label: 'E-mail',
                        textType: TextInputType.emailAddress,
                        validator: (value){
                          if(value!.isEmpty) return "Enter E-mail";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      /// Birthdate field
                      NormalField(
                        controller: dobEdit,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
            child: ButtonFill(text: "Update", onTap: updateData),
          ),
        ],
      ),
    );
  }
}