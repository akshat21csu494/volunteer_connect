import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../components/accordions.dart';
import '../../components/loader.dart';
import '../../components/homeDrawer.dart';
import '../../components/alerts.dart';
import '../../components/buttonOutline.dart';
import '../../screens/user/userProfile.dart';

class NGOVolunteers extends StatefulWidget {
  const NGOVolunteers({super.key});

  @override
  State<NGOVolunteers> createState() => _NGOVolunteersState();
}

class _NGOVolunteersState extends State<NGOVolunteers> {
  String? ngoID;
  String? type;

  Alerts alerts = Alerts();

  @override
  void initState() {
    getSPData();
    super.initState();
  }

  getSPData() async {
    final pref = await SharedPreferences.getInstance();
    type = pref.getString("type");
    if (type == "registerNGO") {
      setState(() {
        ngoID = pref.getString("userID");
      });
    }
  }

  void reject(id) {
    alerts.ActionAlert(context, 'Do yo want to Reject the request become A Volunteer?', "Reject", () {
      FirebaseFirestore.instance.collection('volunteers').doc(id).update({'status': 'rejected'});
      Navigator.pop(context);
      setState(() {}); // Refresh the screen
    });
  }

  void accept(id) {
    alerts.PositiveAlert(context, 'Do yo want to Accept the request become A Volunteer?', "Accept", Colors.green, () async {
      await FirebaseFirestore.instance.collection('volunteers').doc(id).update({'status': 'approved'});
      final pref = await SharedPreferences.getInstance();
      final ngoid = pref.getString("userID");
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('registerNGO').doc(ngoid).get();
      final data = docSnapshot.data();
      int offlineVol = int.parse(data!['offline_vol'].toString());
      offlineVol +=1;

      await FirebaseFirestore.instance.collection('registerNGO').doc(ngoid).update({'offline_vol': offlineVol});
      Navigator.pop(context);
      setState(() {});
    });
  }



  Future<QuerySnapshot<Map<String, dynamic>>> fetchVolunteers() async {

    QuerySnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore.instance
        .collection("volunteers")
        .where("ngo_id", isEqualTo: ngoID)
        .orderBy("timestamp",descending: true)
        .get();

    return postSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.primary,
        title: const Text('Volunteers', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),
      body: FutureBuilder(
        future: fetchVolunteers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Loader());
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];

                return GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                      context: context,
                      elevation: 0,
                      showDragHandle: true,
                      backgroundColor: Colors.white,
                      constraints: const BoxConstraints.expand(),
                      builder: (context)=>Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            const Text('Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8,),
                            Accordion(
                              title: const Text('Contact Details',style: TextStyle(fontSize: 18),),
                              subTitles: [
                                ListTile(
                                  onTap: () {
                                    launcher.launchUrl(Uri.parse('mailto:${data['email']}'));
                                  },
                                  leading: const Icon(CupertinoIcons.mail),
                                  title: Text(data['email']),
                                ),
                                ListTile(
                                  onTap: () {
                                    launcher.launchUrl(Uri.parse('tel:+91 ${data['phno']}'));
                                  },
                                  leading: const Icon(CupertinoIcons.phone),
                                  title: Text(data['phno']),
                                ),
                              ],
                            ),
                            const SizedBox(height:12),
                            Accordion(
                              title: const Text('Address',style: TextStyle(fontSize: 18)),
                              subTitles: [
                                Text(data['address'],style: const TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height:12),
                            ButtonOutline(
                              text: "View Profile",
                              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfile(userData: data))),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f1f1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Text('${data['fname']} ${data['lname']}',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text('Education : ${data['education']}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              if (data['status'] == "pending")
                                GestureDetector(
                                  onTap: () => reject(data.id),
                                  child: const Icon(Icons.cancel, color: Colors.red, size: 28),
                                ),

                              const SizedBox(width: 8),
                              if (data['status'] == "pending")
                                GestureDetector(
                                  onTap: () => accept(data.id),
                                  child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                ),

                              if (data['status'] == "rejected")
                                const Text('Rejected', style: TextStyle(color: Colors.red, fontSize: 18)),

                              if (data['status'] == "approved")
                                const Text('Approved', style: TextStyle(color: Colors.green, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Days in Week : ${data['days_in_week']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Text("    ||    "),
                              Text('Hours in Week : ${data['time_hr_inweek']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("No volunteers activities yet.")),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}