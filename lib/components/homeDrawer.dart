import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../screens/common/feedback.dart';
import '../screens/common/inviteFriends.dart';
import '../screens/common/main.dart';
import '../screens/common/terms_conditions.dart';
import '../screens/common/welcome.dart';
import '../screens/ngo/ngoVolunteers.dart';
import '../screens/ngo/ngoDonations.dart';
import '../screens/user/userDonations.dart';
import '../screens/user/userVolunteer.dart';
import 'alerts.dart';
import 'loader.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  Map<String, dynamic> userData = {};
  String? userId;
  String? type;
  String? email;

  final alerts = Alerts();

  @override
  void initState() {
    super.initState();
    getSPData();
    fetchUserData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();

    userId = pref.getString("userID");
    type = pref.getString("type");
    email= pref.getString("email");
    setState(() {});
  }

  Future<void> fetchUserData () async {
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
    return Drawer(
      elevation: 0,
      shape: const BeveledRectangleBorder(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 240,
            child: DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(color: theme.primary),
              child: FutureBuilder(
                future: fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    return const Text('Error fetching user data');
                  } else {
                    return Column(
                      children: [

                        /// Logo
                        if (userData['logo'] != "")
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 60,
                            backgroundImage: NetworkImage(userData['logo']),
                          ),

                        /// Default logo
                        if (userData['logo'] == "")
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/user.jpeg'),
                            radius: 60,
                          ),

                        /// User's Name
                        if(type == "register")
                          Text('${userData['fname']} ${userData['lname']}',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            maxLines: 1,overflow: TextOverflow.ellipsis,
                          ),

                        /// NGO's Name
                        if(type == "registerNGO")
                          Text(userData['nm'] ?? "Name",
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            maxLines: 1,overflow: TextOverflow.ellipsis,
                          ),

                        Text(userData['email'] ?? "Email",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          maxLines: 1,overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          /// Home
          ListTile(
            onTap: (){
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context)=>const Main())
              );
            },
            title: const Text('Home'),
            leading: const Icon(Icons.home_filled),
          ),

          /// Donation
          ListTile(
            title: const Text('Donations'),
            leading: const Icon(Icons.volunteer_activism),
            onTap: (){
              if(type=="registerNGO") {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const NGODonation())
                );
              }else if(type=="register"){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const UserDonations())
                );
              }
            },
          ),

          /// Volunteers
          ListTile(
            title: const Text('Volunteers'),
            leading: const Icon(CupertinoIcons.person_3_fill),
            onTap: (){
              if(type=="registerNGO") {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const NGOVolunteers())
                );
              } else if(type=="register"){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const UserVolunteers())
                );
              }
            },
          ),

          /// Feedback
          ListTile(
            onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FeedbackScreen())
              );
            },
            title: const Text('Feedback'),
            leading: const Icon(Icons.feedback),
          ),

          /// Terms & Condition
          ListTile(
            onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TermsCondition())
              );
            },
            title: const Text('Terms & Condition'),
            leading: const Icon(Icons.privacy_tip),
          ),

          /// Invite Friend
          ListTile(
            onTap: (){
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Contacts())
              );
            },
            title: const Text('Invite Friends'),
            leading: const Icon(Icons.person_add),
          ),

          /// Logout
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout_rounded),
            onTap: () {
              Navigator.pop(context);
              alerts.ActionAlert(context, "Do you want to Logout?", "Logout", () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('userID');
                await prefs.remove('type');
                await prefs.remove('email');
                Get.offAll(() => const Welcome());
              });
            }
          ),
        ],
      ),
    );
  }
}
