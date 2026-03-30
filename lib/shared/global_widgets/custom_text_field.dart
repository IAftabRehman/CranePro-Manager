import 'package:flutter/material.dart';

class CraneInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final Color? hintTextColor;
  final Color? fillColor;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? prefixText;
  final String? initialValue;
  final Function(String)? onChanged;

  const CraneInput({
    super.key,
    this.controller,
    this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.hintTextColor,
    this.fillColor,
    this.readOnly = false,
    this.onTap,
    this.prefixText,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      autofillHints: autofillHints,
      initialValue: initialValue,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor ?? Colors.blue.withAlpha(128),
        hintStyle: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 13),
        prefixIcon: prefixIcon != null ? IconTheme(data: const IconThemeData(color: Colors.white), child: prefixIcon!) : null,
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.white70),
        suffixIcon: suffixIcon != null ? IconTheme(data: const IconThemeData(color: Colors.white), child: suffixIcon!) : null,
      ),
    );
  }
}
