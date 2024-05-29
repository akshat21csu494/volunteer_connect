import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/homeDrawer.dart';
import '../../components/loader.dart';

class UserDonations extends StatefulWidget {
  const UserDonations({super.key});

  @override
  State<UserDonations> createState() => _UserDonationsState();
}

class _UserDonationsState extends State<UserDonations> {

  String? userID;
  String? type;

  @override
  void initState() {
    getSPData();
    super.initState();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      type = pref.getString("type");
      if (type == "register") {
        userID = pref.getString("userID");
      }
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchDonations() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance
        .collection("donation")
        .where("user_id", isEqualTo: userID)
        .orderBy("timestamp",descending: true)
        .get();

    return snapshot;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchNGO(id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore.instance.collection("registerNGO").doc(id).get();
      return postSnapshot;
    } catch (e) {
      print("Error fetching NGO data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.primary,
        title: const Text('Donations', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),
      body: FutureBuilder(
        future: fetchDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Loader());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data();
                return FutureBuilder(
                  future: fetchNGO(data['ngo_id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    } else if (snapshot.hasError) {
                      return Container(); // You can handle error here
                    } else if (snapshot.hasData) {
                      final ngoData = snapshot.data!.data();
                      if (ngoData != null) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                                          child: Text(ngoData['nm'],
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Text('Donation Type : ${data['type_donation']}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text('Details : ${data['amount']}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
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
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text("No donation activities yet"),
            );
          }
        },
      ),
    );
  }
}