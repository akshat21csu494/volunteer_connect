import 'package:flutter/material.dart';

class NormalField extends StatelessWidget {
  final TextEditingController controller ;
  final String label;
  final TextInputType textType;
  final int? maxLine;
  final Widget? suffix;
  final Widget? prefix;
  final void Function()? onTap;
  final bool? typeable;
  final String? Function(String?)? validator;

  const NormalField({
    super.key,
    required this.controller,
    required this.label,
    required this.textType,
    this.maxLine,
    this.suffix,
    this.onTap,
    this.typeable =true,
    this.validator,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return TextFormField(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: !typeable!,
      onTap: onTap,
      cursorColor: theme.primary,
      controller: controller,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
        labelText: label,
        counterText: '',
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.error, width: 2,),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: theme.primaryContainer,
      ),
      maxLength: maxLine,
      keyboardType: textType,
    );
  }
}
