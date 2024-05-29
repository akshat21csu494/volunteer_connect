import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../components/buttonOutline.dart';
import '../../components/accordions.dart';
import '../../components/loader.dart';
import '../user/donateNGO.dart';
import '../../screens/common/postScreen.dart';
import '../../screens/user/becomeVolunteer.dart';

class NGOProfile extends StatefulWidget {
  final Map ngoData;

  const NGOProfile({
    super.key,
    required this.ngoData,
  });

  @override
  State<NGOProfile> createState() => _NGOProfileState();
}

class _NGOProfileState extends State<NGOProfile> {
  String? ngoId;

  Future<void> getNGOQS(email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("registerNGO")
        .where("email", isEqualTo: email)
        .get();

    ngoId = querySnapshot.docs.first.id;
  }

  @override
  void initState() {
    getNGOQS(widget.ngoData["email"]);
    super.initState();
  }

  Future<QuerySnapshot> fetchPosts(email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("registerNGO")
        .where("email", isEqualTo: email)
        .get();

    ngoId = querySnapshot.docs.first.id;

    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('postsNGO')
        .where('user_id', isEqualTo: ngoId)
        .orderBy('timestamp',descending: true)
        .get();

    return postSnapshot;
  }

  void onJoinUs() {
    showModalBottomSheet(
      elevation: 0,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const Text('Join Us', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const Divider(),
              const SizedBox(height: 12),
              ButtonOutline(
                text: 'Donate',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DonateNGO(ngoID: ngoId!)));
                },
              ),
              const SizedBox(height: 12),
              ButtonOutline(
                text: 'Become a Volunteer',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BecomeVolunteer(ngoID: ngoId!)));
                },
              ),
              const SizedBox(height: 12),

              Accordion(
                title: const Text('Contact Details', style: TextStyle(fontSize: 18)),
                subTitles: [
                  ListTile(
                    onTap: () {
                      launcher.launchUrl(Uri.parse('mailto:${widget.ngoData['email']}'));
                    },
                    leading: const Icon(CupertinoIcons.mail),
                    title: Text(widget.ngoData['email']),
                  ),
                  ListTile(
                    onTap: () {
                      launcher.launchUrl(Uri.parse('tel:+91 ${widget.ngoData['phno']}'));
                    },
                    leading: const Icon(CupertinoIcons.phone),
                    title: Text(widget.ngoData['phno']),
                  ),
                ],
                borderColor: Theme.of(context).colorScheme.primary,
                titleBackgroundColor: const Color(0xfff5f5f5),
                subtitleBackgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 12)
            ],
          ),
        ),
      ),
    );
  }

  void showMoreDetails() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('More', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600))),
            const Divider(),
            const SizedBox(height: 12),
            Accordion(
              title: const Text('Founders of NGO', style: TextStyle(fontSize: 18)),
              subTitles: [
                Text(widget.ngoData['fn'], style: const TextStyle(fontSize: 16)),
              ],
              borderColor: Theme.of(context).colorScheme.primary,
              titleBackgroundColor: const Color(0xfff5f5f5),
              subtitleBackgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 12),
            Accordion(
              title: const Text('Establishment', style: TextStyle(fontSize: 18)),
              subTitles: [
                Text(widget.ngoData['yr'], style: const TextStyle(fontSize: 16)),
              ],
              borderColor: Theme.of(context).colorScheme.primary,
              titleBackgroundColor: const Color(0xfff5f5f5),
              subtitleBackgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('NGO Profile', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: showMoreDetails,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Profile Picture
                if (widget.ngoData['logo'] != "")
                  CircleAvatar(
                    backgroundColor: theme.primary,
                    radius: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(500),
                      child: Image.network(
                        widget.ngoData['logo'], width: 120, height: 120, fit: BoxFit.cover,
                      ),
                    ),
                  ),

                if (widget.ngoData['logo'] == "")
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/user.jpeg'),
                    radius: 60,
                  ),

                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// NGO Name
                    SizedBox(
                      width: 208,
                      child: Text(widget.ngoData['nm'],
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),

                    /// Location
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-4),
                      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                      decoration: BoxDecoration(border: Border.all(color: theme.primary), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.map_pin, size: 18),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(widget.ngoData['address'],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Volunteers
                    Text('${widget.ngoData['offline_vol']} Volunteers', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18))
                  ],
                ),
              ],
            ),

            /// Description
            if (widget.ngoData['about'].isNotEmpty)
              Text(widget.ngoData['about'], style: const TextStyle(fontSize: 16)),

            if (widget.ngoData['about'].isEmpty) const SizedBox(height: 4),

            /// Website URL link
            if (widget.ngoData['link'].isNotEmpty)
              GestureDetector(
                onTap: () {
                  launcher.launchUrl(
                    Uri.parse(widget.ngoData['link']),
                    mode: launcher.LaunchMode.inAppBrowserView,
                  );
                },
                onLongPress: () => {
                  Clipboard.setData(ClipboardData(text: widget.ngoData['link'])).then(
                        (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL Copied into Clipboard'))),
                  )
                },
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xfff1f1f1)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.link, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 60),
                        child: Text(
                          widget.ngoData['link'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            /// NGO Category
            Chip(
              label: Text(widget.ngoData['activities']),
              padding: const EdgeInsets.all(4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),

            /// Join Us Button
            GestureDetector(
              onTap: onJoinUs,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: theme.primary),
                child: Center(
                  child: Text('Join Us',
                    style: TextStyle(color: theme.onPrimary, fontSize: 16),
                  ),
                ),
              ),
            ),
            const Divider(),

            /// All post of ngo will come from here
            FutureBuilder(
              future: fetchPosts(widget.ngoData["email"]),
              builder: (context, postSnapshot) {
                if (postSnapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                if (postSnapshot.hasError) {
                  return Center(child: Text("Error fetching posts: ${postSnapshot.error}"));
                }
                if (postSnapshot.hasData && postSnapshot.data!.docs.isNotEmpty) {
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1,
                      ),
                      itemCount: postSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> postData = postSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              PostScreen(
                                  postData: postData,
                                  userData: widget.ngoData,
                                  ngo_id: ngoId,
                                  type: "register",
                                ),
                              )),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              postData['img'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  // Either data is null or there are no posts
                  return const Column(
                    children: [
                      SizedBox(height: 100,),
                      Center(child: Text("No posts from this NGO yet")),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
