import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: CupertinoActivityIndicator(
          color: Theme.of(context).colorScheme.primary,
          radius: 20,
        ),
      ),
    );
  }
}
