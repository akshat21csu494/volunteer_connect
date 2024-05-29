import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/loader.dart';
import '../../screens/ngo/ngoProfile.dart';

class NGOList extends StatefulWidget {
  const NGOList({super.key});

  @override
  State<NGOList> createState() => _NGOListState();
}

class _NGOListState extends State<NGOList> {

  final searchController = TextEditingController();
  late Stream<QuerySnapshot> ngoStream;
  String? _selectedCategory;
  List categories = [
    "Health & Healthcare",
    "Education",
    "Environment & Conservation",
    "Children & Youth",
    "Poverty Alleviation",
    "Food Distribution",
    "Drug Abuse & Addiction",
    "Global Development",
    "Orphanage",
    "Democracy & Governance",
    "Mental Health Counseling",
    "Animal Welfare",
    "Old Age Home",
    "Bird Welfare",
    "Economic Development",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    ngoStream = FirebaseFirestore.instance.collection('registerNGO').where('status',isEqualTo: "approved").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.primary,
        title: Text('NGO List',style: TextStyle(color: theme.onPrimary)),
      ),
      body: SafeArea(
        child: Column(
          children: [

            /// Search text field
            Container(
              height: 60,
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                style: GoogleFonts.mulish(),
                onChanged: (value){
                  setState(() {
                    ngoStream = FirebaseFirestore.instance.collection('registerNGO')
                        .where('status', isEqualTo: "approved")
                        .where('nm', isGreaterThanOrEqualTo: value)
                        .where('nm', isLessThan: '$value\uf8ff')
                        .snapshots();
                  });
                }
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(String category in categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selectedColor: theme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          selected: category == _selectedCategory,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                              if (_selectedCategory == "All") {
                                ngoStream = FirebaseFirestore.instance
                                    .collection('registerNGO')
                                    .where('status', isEqualTo: "approved")
                                    .snapshots();
                              } else {
                                ngoStream = FirebaseFirestore.instance
                                    .collection('registerNGO')
                                    .where('activities', isEqualTo: _selectedCategory)
                                    .where('status', isEqualTo: "approved")
                                    .snapshots();
                              }
                            });
                          },
                          labelStyle: TextStyle(color: category == _selectedCategory? Colors.white : Colors.black),
                        ),
                      ),
                  ],
                ),
            ),

            /// NGO List
            Expanded(
              child: StreamBuilder(
                stream: ngoStream,
                builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Loader());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final ngoList = snapshot.data?.docs ?? [];
                  if (ngoList.isNotEmpty) {
                    return ListView.separated(
                      itemCount: ngoList.length,
                      separatorBuilder: (context,position) => const Divider(
                        thickness: 0.5, height: 10,
                        color: CupertinoColors.systemGrey,
                      ),
                      itemBuilder: (context,index){
                        final ngoData = ngoList[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(ngoData['nm']),
                          leading: ngoData['logo'] != ""
                              ? CircleAvatar(backgroundImage: NetworkImage(ngoData['logo']))
                              : const CircleAvatar(backgroundImage: AssetImage('assets/user.jpeg')),
                          onTap:() {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => NGOProfile(ngoData: ngoData)),
                            );
                          }
                        );
                      },
                    );
                  }
                  if(ngoList.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Image(image:AssetImage('assets/nodata.png'),height:100),
                          SizedBox(height: 12),
                          Text('No NGO Found',style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
