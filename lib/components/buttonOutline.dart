import 'package:flutter/material.dart';

class ButtonOutline extends StatelessWidget {
  final String text;
  final void Function() onTap;
  const ButtonOutline({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: theme.primary, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Text(text,
            style: TextStyle(color: theme.primary, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
