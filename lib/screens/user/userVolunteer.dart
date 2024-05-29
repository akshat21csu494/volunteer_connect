import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/alerts.dart';
import '../../components/homeDrawer.dart';
import '../../components/loader.dart';

class UserVolunteers extends StatefulWidget {
  const UserVolunteers({super.key});

  @override
  State<UserVolunteers> createState() => _UserVolunteersState();
}

class _UserVolunteersState extends State<UserVolunteers> {
  String? userID;
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
    if (type == "register") {
      setState(() {
        userID = pref.getString("userID");
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchVolunteers() async {
    final pref = await SharedPreferences.getInstance();
    final id = pref.getString("userID");

    QuerySnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore.instance
        .collection("volunteers")
        .where("user_id", isEqualTo: id)
        .orderBy("timestamp",descending: true)
        .get();
    return postSnapshot;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchNGO(id) async {

    DocumentSnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore.instance.collection("registerNGO").doc(id).get();

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
                final data = snapshot.data!.docs[index].data();
                return FutureBuilder(
                  future: fetchNGO(data['ngo_id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final ngoData = snapshot.data!.data(); // Get the data from the DocumentSnapshot
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8,8,8,0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xfff1f1f1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Text(ngoData!['nm'],
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,maxLines: 2,
                                    ),
                                  ),
                                  const Spacer(),

                                  if (data['status'] == "pending")
                                    const Text('Pending', style: TextStyle(color: Colors.blue, fontSize: 18)),

                                  if (data['status'] == "rejected")
                                    const Text('Rejected', style: TextStyle(color: Colors.red, fontSize: 18)),

                                  if (data['status'] == "approved")
                                    const Text('Approved', style: TextStyle(color: Colors.green, fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Days in Week : ${data['days_in_week']}', style: const TextStyle(fontSize: 16)),
                                  const Text("    ||    "),
                                  Text('Hours in Week : ${data['time_hr_inweek']}', style: const TextStyle(fontSize: 16)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("No volunteering activities yet.")),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
