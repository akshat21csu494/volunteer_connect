import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';
import '../../components/normalField.dart';

class EditNGOProfile extends StatefulWidget {

  final Map ngoData;

  const EditNGOProfile({
    super.key,
    required this.ngoData,
  });

  @override
  State<EditNGOProfile> createState() => _EditNGOProfileState();
}

class _EditNGOProfileState extends State<EditNGOProfile> {

  final nameEdit = TextEditingController();
  final foundersEdit = TextEditingController();
  final aboutEdit = TextEditingController();
  final locationEdit = TextEditingController();
  final volunteerEdit = TextEditingController();
  final emailEdit = TextEditingController();
  final phoneEdit = TextEditingController();
  final websiteURLEdit = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Uint8List? _image;
  File? selectedIMage;

  @override
  void initState() {
    super.initState();
    nameEdit.text = widget.ngoData['nm'];
    foundersEdit.text = widget.ngoData['fn'];
    aboutEdit.text = widget.ngoData['about'];
    locationEdit.text = widget.ngoData['address'];
    volunteerEdit.text = '${widget.ngoData['offline_vol']}';
    phoneEdit.text = widget.ngoData['phno'];
    emailEdit.text = widget.ngoData['email'];
    websiteURLEdit.text = widget.ngoData['link'];
  }

  void changeProfilePicture(){
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context)=> SizedBox(
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
      ),
    );
  }

  String generateAutoChildName() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String randomString = DateTime.now().microsecondsSinceEpoch.toString().substring(6);
    String uniqueFileName = '$timestamp-$randomString';
    return uniqueFileName;
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
  Future<void> updateData() async {
    if(_formKey.currentState!.validate()){
      String? imageUrl;
      String childName = generateAutoChildName();

      try {

        showDialog(context: context, builder: (context)=>const Loader());

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('registerNGO')
            .where('email', isEqualTo: widget.ngoData['email'])
            .get();
        if(selectedIMage==null){
          print("No image found");
        }else{
          imageUrl=await uploadImageToStorage("user_profile/$childName",_image!);
        }

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userRef = querySnapshot.docs.first.reference;

          /// If profile picture is not changed
          if(_image == null){
            await userRef.update({
              'nm': nameEdit.text,
              'fn': foundersEdit.text,
              'about': aboutEdit.text,
              'phno': phoneEdit.text,
              'email':emailEdit.text,
              'address' : locationEdit.text,
              'offline_vol':volunteerEdit.text,
              'link':websiteURLEdit.text,
            });
          }

          /// If profile picture is changed
          if(_image != null){
            await userRef.update({
              'nm': nameEdit.text,
              'fn': foundersEdit.text,
              'about': aboutEdit.text,
              'phno': phoneEdit.text,
              'email':emailEdit.text,
              'address' : locationEdit.text,
              'offline_vol':volunteerEdit.text,
              'link':websiteURLEdit.text,
              'logo':imageUrl ?? '',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.primary,
        title: Text('Edit Profile', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      /// Profile Picture
                      Stack(
                        children: [

                          if(widget.ngoData['logo'] != "")
                            CircleAvatar(
                              backgroundColor: theme.primary,
                              radius: 80,
                              backgroundImage: NetworkImage(widget.ngoData['logo']),
                            ),

                          if(widget.ngoData['logo'] == "" && _image == null)
                            const CircleAvatar(
                              radius: 80,
                              backgroundImage: AssetImage('assets/user.jpeg'),
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
                                icon: Icon(CupertinoIcons.pen,color: theme.primaryContainer),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Text('Basic',style: TextStyle(fontSize: 20)),
                      NormalField(
                        controller: nameEdit,
                        label: 'Name',
                        textType: TextInputType.name,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      NormalField(
                        controller: foundersEdit,
                        label: 'Founders',
                        textType: TextInputType.name,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Founders Name";
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
                        controller: locationEdit,
                        label: 'Location',
                        textType: TextInputType.streetAddress,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Location";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),


                      NormalField(
                        controller: volunteerEdit,
                        label: 'Volunteers',
                        textType: TextInputType.number,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Volunteers";
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      NormalField(
                        controller: websiteURLEdit,
                        label: 'Website of NGO',
                        textType: TextInputType.url,
                      ),
                      const SizedBox(height: 8),

                      const Divider(),

                      const Text('Contact',style: TextStyle(fontSize: 20)),
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
                      NormalField(
                        controller: phoneEdit,
                        label: 'Phone number',
                        textType: TextInputType.number,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Phone No.";
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
            child: ButtonFill(text: 'Save', onTap: updateData),
          ),
        ],
      )
    );
  }
}
