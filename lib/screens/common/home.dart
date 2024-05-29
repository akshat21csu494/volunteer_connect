import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/loader.dart';
import '../../components/post.dart';
import '../../components/homeDrawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userId;
  String? postId;
  String? type;
  String? email;
  Map<String, dynamic> userData = {};
  List posts = [];


  @override
  void initState() {
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("userID");
    type = pref.getString("type");
    email= pref.getString("email");
    setState(() {});
  }

  Future<void> fetchUserData (String email) async {
    final pref = await SharedPreferences.getInstance();
    String? type = pref.getString("type");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(type!)
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        userData = querySnapshot.docs.first.data();
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Home', style: TextStyle(color: theme.onPrimary)),
      ),
      drawer: const HomeDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("postsNGO")
            .orderBy('timestamp',descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: Loader());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){

                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                postId = document.id;

                String _userId = data['user_id'];
                return FutureBuilder(
                  future: FirebaseFirestore.instance.collection('registerNGO').doc(_userId).get(),
                  builder: (context,userSnaps){
                    if(userSnaps.hasError){
                      return Center(child: Text(userSnaps.error.toString()));
                    }
                    if(userSnaps.hasData){
                      Map<String, dynamic> userData = userSnaps.data!.data() as Map<String, dynamic>;
                      return Post(
                        logo: userData['logo'],
                        name:'${userData['nm']}',
                        date: data['date'],
                        image: data['img'],
                        caption: data['caption'],
                        pid: postId,
                        ty: type,
                        ngo_id: _userId,
                      );
                    }
                    return Container();
                  }
                );
              }
            );
          }
          return Container();
        },
      )
    );
  }
}