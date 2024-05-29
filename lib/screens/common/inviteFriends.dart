import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/homeDrawer.dart';
import '../../components/loader.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContacts() async {
    contacts = await ContactsService.getContacts();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primary,
        centerTitle: true,
        title: Text('Invite Friends', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const HomeDrawer(),

      body: isLoading
          ? const Center(child: Loader())
          : ListView.separated(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          if (index >= contacts.length) {
            return null;
          }
          String givenName = contacts[index].givenName ?? '';
          String phoneNumber = contacts[index].phones?.isNotEmpty ?? false
              ? contacts[index].phones![0].value ?? ''
              : '';

          if (phoneNumber.isNotEmpty) {
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                child: Text(givenName.isNotEmpty ? givenName[0] : "C",
                  style: TextStyle(fontSize: 20, color: theme.primary,),
                ),
              ),
              title: Text(givenName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(phoneNumber,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing:CircleAvatar(
                backgroundColor: theme.primary,
                child: IconButton(
                  onPressed: () {
                    launch('sms:$phoneNumber?body=${Uri.encodeComponent("Discover Sevasanskriti, a platform uniting NGOs and volunteers! Donate to causes you care about, or become a volunteer today. Download the app now:https://play.google.com/store/apps/details?id=com.sevasanskriti.android&hl=en_IN&gl=US. Let's make a difference together! #Sevasanskriti")}');
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            );
          } else {
            return Container();
          }
        }, separatorBuilder: (BuildContext context, int index) => const Divider(
              height: 1,
              color: Colors.grey,
              thickness: 0.5,
           ),
      ),
    );
  }
}
