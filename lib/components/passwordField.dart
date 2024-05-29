import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  final String label;

  const PasswordField(
      {super.key, required this.controller, required this.label});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: widget.controller,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelText: widget.label,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.error, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primaryContainer,
        suffixIcon: IconButton(
          icon: Icon(passwordVisible
              ? CupertinoIcons.eye_slash_fill
              : CupertinoIcons.eye_fill,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            setState(() => passwordVisible = !passwordVisible);
          },
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value!.isEmpty) return 'Enter Password';
        if (value.length < 8) return 'Password should be at least 8 character';
        return null;
      },
      cursorColor: Theme.of(context).colorScheme.primary,
      obscureText: !passwordVisible,
      keyboardType: TextInputType.visiblePassword,
    );
  }
}
