import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/buttonFill.dart';
import '../../components/loader.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final captionController = TextEditingController();
  late DateTime now11;
  late String formatter;
  Uint8List? _image;
  File? selectedIMage;

  @override
  void initState() {
    super.initState();
    now11 = DateTime.now();
    formatter = DateFormat('yMd').format(now11);
  }

  String generateAutoChildName() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String randomString = DateTime.now().microsecondsSinceEpoch.toString().substring(6);
    String uniqueFileName = '$timestamp-$randomString';
    return uniqueFileName;
  }

  Future<void> addpost() async {
    showDialog(context: context, builder: (context)=>const Loader());
    print(captionController.text);
    final pref = await SharedPreferences.getInstance();
    String? userId = pref.getString("userID");
    String? type = pref.getString("type");
    String collection= type=="register"?"posts":"postsNGO";
    String childName = generateAutoChildName();

    if(_image!=null){

      if(captionController.text==""){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill caption"),
          backgroundColor: Colors.red,
        ));
      }else{
        String? imageUrl=type=='register'?await uploadImageToStorage("user_posts/$childName",_image!):await uploadImageToStorage("ngo_posts/$childName",_image!);
        await FirebaseFirestore.instance.collection(collection).doc().set({
          "caption":captionController.text,
          "date":formatter,
          "img":imageUrl,
          "likes":0,
          "user_id":userId!,
          'timestamp':DateTime.now().millisecondsSinceEpoch,
        });
        Navigator.pop(context);
      }
      Navigator.pop(context);
    }else{
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No image found"),
        backgroundColor: Colors.red,
      ));
    }
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
      return '';
    }
  }

  void selectImage() async {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder :(context)=> SizedBox(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Add Post', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    children: [

                      if (_image == null)
                        GestureDetector(
                          onTap: selectImage,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: DottedBorder(
                                radius: const Radius.circular(12),
                                borderType: BorderType.RRect,
                                dashPattern: const [8, 8],
                                strokeCap: StrokeCap.round,
                                color: theme.primary,
                                strokeWidth: 2,
                                child: Container(
                                  decoration: BoxDecoration(color: const Color(0xfff1f1f1), borderRadius: BorderRadius.circular(12)),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_rounded, size: 60),
                                        Text('Add Photo', style: TextStyle(fontSize: 28)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_image != null)
                        Center(
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xfff1f1f1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(_image!,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: 'Caption',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(fontSize: 18),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value){
                          if(value!.isEmpty) return "Enter Caption";
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
            padding: const EdgeInsets.all(8),
            child: ButtonFill(text: "Post", onTap: addpost),
          ),
        ],
      ),
    );
  }
}