import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/loader.dart';
import '../common/postScreen.dart';

class UserProfile extends StatefulWidget {

  final QueryDocumentSnapshot<Map> userData;

  const UserProfile({
    super.key,
    required this.userData
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(

      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Profile', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded),)
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("register")
              .where("email", isEqualTo: widget.userData['email'])
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Loader());

            if (snapshot.hasError) return Text(snapshot.error.toString());

            if (snapshot.hasData) {
              final querySnapshot = snapshot.data as QuerySnapshot;
              if (querySnapshot.docs.isEmpty) {
                return const Center(child: Text('No user data found'));
              }
              final data = querySnapshot.docs[0].data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Profile Picture
                      if (data['logo'] != null)
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          backgroundImage: NetworkImage(data['logo']),
                        ),

                      if (data['logo'] == null)
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/user.jpeg'),
                          radius: 60,
                        ),
                      const SizedBox(width: 12),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Name of User
                          SizedBox(
                            width: 212,
                            child: Text('${data['fname']} ${data['lname']}',
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          /// Volunteers
                          const Text('00 Volunteering', style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  /// Description
                  if (data['about'] != null)
                    Text(data['about'], style: const TextStyle(fontSize: 16)),

                  const Divider(),

                  /// All post of ngo will come from here

                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('user_id',isEqualTo: widget.userData['user_id'])
                        .orderBy('timestamp',descending: true)
                        .get(),
                    builder: (context,postSnapshot){
                      if(postSnapshot.connectionState == ConnectionState.waiting) return const Loader();

                      if(postSnapshot.hasData){
                        return Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 1,
                            ),
                            itemCount: postSnapshot.data!.docs.length,
                            itemBuilder: (context, index){
                              Map<String, dynamic> postData = postSnapshot.data!.docs[index].data();
                              return GestureDetector(
                                onTap:()=> Navigator.push(context, MaterialPageRoute(builder:
                                    (context)=> PostScreen(postData: postData, userData: data))),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    postData['img'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          ),
                        );
                      }
                      return Container();
                    }
                  ),
                ],
              );
            }
            return const Center(child: Loader());
          },
        ),
      ),
    );
  }
}