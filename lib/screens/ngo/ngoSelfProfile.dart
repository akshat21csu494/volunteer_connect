import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../components/loader.dart';
import '../common/addPost.dart';
import '../common/postScreen.dart';
import 'editNGOProfile.dart';

class NGOSelfProfile extends StatefulWidget {
  const NGOSelfProfile({super.key});

  @override
  State<NGOSelfProfile> createState() => _NGOSelfProfileState();
}

class _NGOSelfProfileState extends State<NGOSelfProfile> {

  String? email;
  String? userId;
  String? type;
  String profilePictureUrl= '';
  String? img;
  Map<String, dynamic>? data;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  initState(){
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

  void onContactPress(data){
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      constraints: const BoxConstraints.expand(),
      backgroundColor: Colors.white,
      builder: (context)=> Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Contact Details',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
          ListTile(
            onTap: (){
              launcher.launchUrl(
                Uri.parse('mailto:${data['email']}'),
              );
            },
            leading: const Icon(CupertinoIcons.mail),
            title: Text(data['email']),
          ),
          ListTile(
            onTap: (){
              launcher.launchUrl(
                Uri.parse('tel:+91 ${data['phno']}'),
              );
            },
            leading: const Icon(CupertinoIcons.phone),
            title: Text(data['phno']),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?>  fetchProfileData() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("userID");
    print(userId);

    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
        .collection('registerNGO')
        .doc(userId)
        .get();

    if (userData.exists) {
      setState(() {
        profilePictureUrl = userData.data()?['logo'];
      });
      return userData.data();
    }
    return null;
  }

  Future<void> _refresh() async {
    await getSPData();
    await fetchProfileData();
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
        actions: [
          IconButton(
            onPressed:() async {
              final fetchedData = await fetchProfileData();
              if (fetchedData != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    EditNGOProfile(ngoData: fetchedData)),
                ).then((_){
                  _refresh();
                });
              } else {
                print("No data found");
              }
              _refresh();
            },
            icon: const Icon(CupertinoIcons.pen),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8,8,8,0),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: FutureBuilder(
              future:  (type != null && type!.isNotEmpty && email != null && email!.isNotEmpty)
                  ? FirebaseFirestore.instance
                  .collection(type!)
                  .where("email", isEqualTo: email!)
                  .get()
                  : null,
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loader());
                }
                if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                  final querySnapshot = snapshot.data as QuerySnapshot;
                  Map<String, dynamic>? data = querySnapshot.docs[0].data() as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Profile Picture
                          if(data['logo'] != "")
                            CircleAvatar(
                              backgroundColor: theme.primary,
                              radius: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(500),
                                child: Image.network(
                                  data['logo'], width: 120, height: 120, fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          if(data['logo'] == "")
                            const CircleAvatar(
                              backgroundImage: AssetImage('assets/user.jpeg'),
                              radius: 60
                            ),

                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// NGO Name
                              SizedBox(
                                width: 212,
                                child: Text(data['nm'],
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600,),
                                ),
                              ),

                              /// Location
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.primary),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(CupertinoIcons.map_pin,size: 18),
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 184),
                                        child: Text(data['address'],
                                          style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// Volunteers
                              Text('${data['offline_vol']} Volunteers',style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18))
                            ],
                          )
                        ],
                      ),

                      /// Description
                      if(data['about'] != null)
                        Text(data['about'],style: const TextStyle(fontSize: 16)),
                      if(data['about'] == null)
                        const SizedBox(height: 4),

                      /// Website URL link
                      if(data['link'].isNotEmpty)
                        GestureDetector(
                          onTap: (){
                            launcher.launchUrl(
                              Uri.parse(data['link']),
                              mode: launcher.LaunchMode.inAppBrowserView,
                            );
                          },
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: data['link']))
                                .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('URL Copied into Clipboard')))
                            );
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xfff1f1f1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.link,size: 16,color: Colors.blue),
                                const SizedBox(width: 4),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 60,
                                  ),
                                  child: Text(data['link'],
                                    style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600, color: Colors.blue),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      /// NGO Category
                      Chip(
                        label: Text(data['activities']),
                        padding: const EdgeInsets.all(4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),

                      const Divider(),

                      /// All post of ngo will come from here

                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('postsNGO')
                            .where('user_id',isEqualTo: userId)
                            .orderBy("timestamp",descending: true)
                            .get(),
                        builder: (context,postSnapshot){
                          if(postSnapshot.connectionState == ConnectionState.waiting) return const Loader();
                          return Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: postSnapshot.data!.docs.length +1,
                              itemBuilder: (BuildContext context, int index) {
                                if(index==0){
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPost()));
                                      _refresh();
                                    },
                                    child: Container(
                                      color: const Color(0xfff1f1f1),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_rounded,size: 40,),
                                          Text('Add Post',style: TextStyle(fontSize: 18))
                                        ],
                                      ),
                                    ),
                                  );
                                }else{
                                  Map<String, dynamic> postData = postSnapshot.data!.docs[index - 1].data();
                                  return GestureDetector(
                                    onTap:() async {
                                      await Navigator.of(context).push(MaterialPageRoute(builder:
                                          (context)=> PostScreen(
                                            postData: postData,
                                            userData: data, docID: postSnapshot.data!.docs[index-1].id,
                                          ))
                                      );
                                      _refresh();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
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
                      ),
                    ],
                  );
                }
                return const Center(child: Loader());
              }
          ),
        ),
      ),
    );
  }
}