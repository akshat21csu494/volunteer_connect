import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Alerts{

  void ActionAlert(BuildContext context, String title, String action, Function() actionTap) {
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title, style: GoogleFonts.mulish()),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.mulish()),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              isDefaultAction: true,
              onPressed: actionTap,
              child: Text(action, style: GoogleFonts.mulish()),
            ),
          ],
        ),
      );
    }
  }

  void PositiveAlert(BuildContext context, String title, String action, Color color ,Function() actionTap) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title, style: GoogleFonts.mulish()),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.mulish()),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: actionTap,
            child: Text(action, style: GoogleFonts.mulish().copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  void SimpleAlert(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title,style: GoogleFonts.mulish()),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: ()=> Navigator.pop(context),
            child: Text('Okay',style: GoogleFonts.mulish()),
          ),
        ],
      ),
    );
  }
}