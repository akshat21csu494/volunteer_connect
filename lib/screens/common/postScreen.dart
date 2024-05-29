import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/post.dart';

class PostScreen extends StatefulWidget {
  Map? postData;
  Map? userData;
  String? ngo_id;
  String? docID;
  String? type;

  PostScreen({
    super.key,
    this.postData,
    this.userData,
    this.ngo_id,
    this.docID,
    this.type,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  String? type;

  @override
  initState() {
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();
    type = pref.getString("type");
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text('Post', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Post(
        logo: widget.userData?['logo'] ?? "",
        name: widget.userData?['nm'] == null
            ? '${widget.userData?['fname']} ${widget.userData?['lname']}'
            : '${widget.userData?['nm']}',
        date: widget.postData?['date'],
        image: widget.postData?['img'],
        caption: widget.postData?['caption'],
        pid: widget.postData?['user_id'],
        docID: widget.docID,
        ngo_id: widget.ngo_id,
        ty: widget.type,
      ),
    );
  }
}
