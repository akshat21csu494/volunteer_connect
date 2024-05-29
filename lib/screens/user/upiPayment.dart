import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_india/upi_india.dart';

import '../../components/alerts.dart';

class UPIPayment extends StatefulWidget {

  final double amount;
  final String ngoId;
  final String fname;
  final String lname;
  final String email;
  final String phone;
  final String description;
  final String address;
  final String donationType;

  const UPIPayment({
    super.key,
    required this.amount,
    required this.ngoId,
    required this.description,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
    required this.address,
    required this.donationType
  });

  @override
  State<UPIPayment> createState() => _UPIPaymentState();
}

class _UPIPaymentState extends State<UPIPayment> {

  Future<UpiResponse>? transaction;
  UpiIndia upiIndia = UpiIndia();
  Map<String, dynamic>? ngoData;

  Alerts alerts = Alerts();

  List<UpiApp> apps = [
    UpiApp.paytm,
    UpiApp.googlePay,
    UpiApp.phonePe,
    UpiApp.amazonPay,
  ];

  @override
  void initState() {
    fetchNGOData();
    super.initState();
  }

  void fetchNGOData(){
    FirebaseFirestore.instance
        .collection("registerNGO")
        .doc(widget.ngoId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          ngoData = documentSnapshot.data() as Map<String, dynamic>?;
        });
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {

    final pref = await SharedPreferences.getInstance();
    final userID = pref.getString("userID");

    await FirebaseFirestore.instance.collection("donation").doc().set({
      "ngo_id" :widget.ngoId,
      "user_id" : userID,
      "fname" : widget.fname,
      "lname" : widget.lname,
      "email" : widget.email,
      "phno" : widget.phone,
      "address" : widget.address,
      "type_donation" : widget.donationType,
      "amount" : widget.amount,
      "description" : widget.description,
      "status" : "approved",
      "timestamp" : DateTime.now().millisecondsSinceEpoch,
    });

    return upiIndia.startTransaction(
      app: app,
      receiverUpiId: ngoData?["upi"],
      receiverName: ngoData?["nm"],
      transactionRefId: '',
      transactionNote: widget.description,
      amount: widget.amount,
    );
  }

  String upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app is not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return '';
    }
  }

  void checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.primary,
        title: Text('UPI Payment', style: TextStyle(color: theme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                children: apps.map((UpiApp app){
                  return GestureDetector(
                    onTap: (){
                      transaction = initiateTransaction(app);
                      setState(() {});
                    },
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset('assets/logo/${app.name.replaceAll(' ', '')}.png',
                            height: 90,
                            width: 90,
                          ),
                          Text(app.name,style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }).toList()
              ),
            ),

            Expanded(
              child: FutureBuilder(
                future: transaction,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    if(snapshot.hasError){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(upiErrorHandler(snapshot.error.runtimeType) != '')
                            const Icon(Icons.error,size: 40,color: Colors.red),

                          Text(upiErrorHandler(snapshot.error.runtimeType),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                    UpiResponse upiResponse = snapshot.data!;
                    checkTxnStatus(upiResponse.status!);
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