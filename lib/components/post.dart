import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/user/donateNGO.dart';
import 'alerts.dart';

class Post extends StatefulWidget {
  String? pid;
  String? name;
  String? date;
  String? logo;
  String? image;
  String? ngo_id;
  String? caption;
  String? ty;
  String? docID;

  Post({
    super.key,
    this.name,
    this.date,
    this.logo,
    this.image,
    this.ngo_id,
    this.caption,
    this.pid,
    this.ty,
    this.docID
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String? userId;
  String? type;
  String? email;

  final alerts = Alerts();

  @override
  void initState() {
    super.initState();
    getSPData();
  }

  Future<void> getSPData() async {
    final pref = await SharedPreferences.getInstance();

    userId = pref.getString("userID");
    type = pref.getString("type");
    email= pref.getString("email");
    setState(() {});
  }

  void onClick(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>DonateNGO(ngoID:widget.ngo_id! )));
  }

  void delete(){
    alerts.ActionAlert(context, "Do you want to delete Post?", "Delete", () async {
      if(type=="register"){
        await FirebaseFirestore.instance.collection("posts").doc(widget.docID).delete();
      }
      if(type=="registerNGO"){
        await FirebaseFirestore.instance.collection("postsNGO").doc(widget.docID).delete();
      }
      print("deleted");
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                /// Profile Picture
                if(widget.logo == "")
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/user.jpeg'),
                  ),

                if(widget.logo != "")
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.logo!),
                  ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Name
                    SizedBox(
                      width: userId == widget.pid ? 295 : 320,
                      child: Text(widget.name ?? "",
                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600,),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// Date
                    Text(widget.date ?? "",style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const Spacer(),

                if(userId == widget.pid)
                  IconButton(onPressed: delete, icon: const Icon(CupertinoIcons.delete))
              ],
            ),
            const SizedBox(height: 8),

            /// Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.image ?? "",
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8,),

            /// Caption
            Text(widget.caption ?? "",
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16),
            ),

           widget.ty == 'register' ? const Divider() : const SizedBox.shrink(),

            widget.ty == 'register' ? Center(
              child: TextButton.icon(
                onPressed: onClick,
                icon: const Icon(Icons.volunteer_activism_rounded), label: const Text('Donate'),
              ),
            ): const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
