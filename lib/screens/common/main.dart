import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/ngo/ngoSelfProfile.dart';
import '../../../screens/auth/login.dart';
import '../../../screens/user/userSelfProfile.dart';
import '../ngo/ngoList.dart';
import 'home.dart';

class Main extends StatefulWidget {

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int currentPageIndex = 0;

  String? userId;
  String? type;
  String? email;
  @override
  initState(){
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      userId = pref.getString("userID");
      type = pref.getString("type");
      email= pref.getString("email");
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.primary,
        currentIndex: currentPageIndex,
        elevation: 0,
        unselectedFontSize: 14,
        unselectedItemColor: Colors.white, // Color(0xFFEDC9AF)
        selectedItemColor: const Color(0xFFEDC9AF),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'NGOs'
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_solid),
            label: 'Profile'
          ),
        ],
      ),
      body: [
        const Home(),
        const NGOList(),
        if(type=="register")
          const UserSelfProfile(),
        if(type=="registerNGO")
          const NGOSelfProfile()
      ][currentPageIndex],
    );
  }
}
