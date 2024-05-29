import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../components/alerts.dart';
import '../../components/homeDrawer.dart';
import '../../components/loader.dart';
import '../../components/accordions.dart';

class NGODonation extends StatefulWidget {
  const NGODonation({super.key});

  @override
  State<NGODonation> createState() => _NGODonationState();
}

class _NGODonationState extends State<NGODonation> {

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
    if(type == "registerNGO"){
      setState(() {
        ngoID = pref.getString("userID");
      });
    }
  }

  void reject(id){
    alerts.ActionAlert(context, 'Do yo want to Reject the request become A Volunteer?', "Reject", () {
      FirebaseFirestore.instance.collection('donation').doc(id).update({'status': 'rejected'});
      Navigator.pop(context);
      setState(() {});
    });
  }

  void accept(id){
    alerts.PositiveAlert(context, 'Do yo want to Accept the request become A Volunteer?', "Accept", Colors.green, () {
      FirebaseFirestore.instance.collection('donation').doc(id).update({'status': 'approved'});
      Navigator.pop(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Donations', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),

      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("donation")
            .where("ngo_id",isEqualTo: ngoID)
            .orderBy("timestamp",descending: true)
            .get(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: Loader());
          }
          if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
                final data = snapshot.data!.docs[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8,8,8,0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f1f1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
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
                              ],
                            ),
                          ),
                        );
                      },
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
                                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w700),
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
                              if(data['status']=="pending")
                                GestureDetector(
                                  onTap: ()=>reject(data.id),
                                  child: const Icon(Icons.cancel,color: CupertinoColors.destructiveRed, size: 28),
                                ),

                              const SizedBox(width: 8),

                              if(data['status']=="pending")
                                GestureDetector(
                                  onTap:()=> accept(data.id),
                                  child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                ),

                              if (data['status'] == "rejected")
                                const Text('Rejected', style: TextStyle(color: Colors.red, fontSize: 18)),
                              if (data['status'] == "approved")
                                const Text('Approved', style: TextStyle(color: Colors.green, fontSize: 18))
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
                  Center(child: Text("No donations yet.")),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}