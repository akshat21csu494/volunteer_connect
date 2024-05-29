import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/loader.dart';
import '../common/addPost.dart';
import '../common/postScreen.dart';
import '../user/editUserProfile.dart';

class UserSelfProfile extends StatefulWidget {
  const UserSelfProfile({super.key});

  @override
  State<UserSelfProfile> createState() => _UserSelfProfileState();
}

class _UserSelfProfileState extends State<UserSelfProfile> {

  String? userId;
  String? type;
  String? email;
  String? img;
  String profilePictureUrl= '';
  Map<String, dynamic>? data;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  initState() {
    super.initState();
    getSPData();
    fetchProfileData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("userID");
    type = pref.getString("type");
    email = pref.getString("email");
    setState(() {});
  }

  Future<void> _refresh() async {
    await getSPData();
    await fetchProfileData();
  }

  Future<Map<String, dynamic>?> fetchProfileData() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("userID");

    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
        .collection('register')
        .doc(userId)
        .get();

    if (userData.exists) {
      setState(() {
        profilePictureUrl = userData.data()?['logo'];
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(

      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Profile', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Icon(Icons.add,color: theme.primary),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EditUserProfile(userData: data!)),
              );
              _refresh();
            },
            icon: const Icon(CupertinoIcons.pen),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: FutureBuilder(
            future: (type != null && email != null)
                ? FirebaseFirestore.instance
                .collection(type!)
                .where("email", isEqualTo: email!)
                .get()
                : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Loader());

              if (snapshot.hasError) return Text(snapshot.error.toString());

              if (snapshot.hasData) {
                final querySnapshot = snapshot.data as QuerySnapshot;
                if (querySnapshot.docs.isEmpty) {
                  return const Center(child: Text('No user data found'));
                }
                data = querySnapshot.docs[0].data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// Profile Picture
                        if (data!['logo'] != "")
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 60,
                            backgroundImage: NetworkImage(data!['logo']),
                          ),

                        if (data!['logo'] == "")
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/user.jpeg'),
                            radius: 60,
                          ),
                        const SizedBox(width: 12),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Name of User
                            SizedBox(
                              width: 212,
                              child: Text('${data!['fname']} ${data!['lname']}',
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600,),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),

                    /// Description
                    if (data!['about'] != null)
                      Text(data!['about'], style: const TextStyle(fontSize: 16)),

                    const Divider(),

                    /// All post of ngo will come from here

                    FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('posts')
                          .where('user_id',isEqualTo: userId)
                          .orderBy('timestamp',descending: true)
                          .get(),
                      builder: (context,postSnapshot){
                        if(postSnapshot.connectionState == ConnectionState.waiting) return const Loader();
                        if(postSnapshot.hasData){
                          return Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: postSnapshot.data!.docs.length +1,
                              itemBuilder: (context, index){
                                print("postSnapshot.data!.docs.length ${postSnapshot.data!.docs.length}");
                                if(index==0){
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPost()));
                                      _refresh();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color(0xfff1f1f1),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_rounded, size: 40),
                                          Text('Add Post', style: TextStyle(fontSize: 18))
                                        ],
                                      ),
                                    ),
                                  );
                                } else{
                                  Map<String, dynamic> postData = postSnapshot.data!.docs[index - 1].data();
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                          PostScreen(
                                            postData: postData,
                                            userData: data,
                                            docID: postSnapshot.data!.docs[index - 1].id,
                                            type: "registerNGO",
                                          ),
                                      ));
                                      _refresh();
                                    },
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      child: Image.network(
                                        postData['img'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                              }
                            ),
                          );
                        }
                        return Container();
                      }
                    )
                  ],
                );
              }
              return const Center(child: Loader());
            },
          ),
        ),
      ),
    );
  }
}