import 'package:flutter/material.dart';

class ButtonFill extends StatelessWidget {
  final String text;
  final void Function() onTap;
  const ButtonFill({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(text,
            style: TextStyle(color: theme.onPrimary, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
