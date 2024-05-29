import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/buttonFill.dart';
import '../../components/homeDrawer.dart';
import '../../components/normalField.dart';
import '../../components/loader.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {

  final nameController = TextEditingController();
  final msgController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> submitFeedback() async {
    if(_formKey.currentState!.validate()){
      /// Show Circular progress bar
      showDialog(context: context, builder: (context)=>const Center(child: Loader()));

      await FirebaseFirestore.instance.collection("feedback").doc().set({
        "nm":nameController.text,
        "msg":msgController.text,
        'timestamp':DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted')),
      );
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
        title: Text('Feedback', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),
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

                      /// Name Field
                      NormalField(
                        controller: nameController,
                        label: "Name",
                        textType: TextInputType.name,
                        validator: (value){
                          if(value!.isEmpty) return "Enter your Name";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      /// Msg field
                      TextFormField(
                        controller: msgController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          hintText: 'Your Feedback...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value){
                          if(value!.isEmpty)return "Enter your Feedback";
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
            child: ButtonFill(text: 'Submit Feedback', onTap: submitFeedback),
          ),

        ],
      ),
    );
  }
}
