import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/common/main.dart';
import '../screens/common/welcome.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  String? userId;
  String? type;

  @override
  initState(){
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    userId = pref.getString("userID");
    type = pref.getString("type");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(userId==null){
      return const Welcome();
    } else {
      return const Main();
    }
  }
}
