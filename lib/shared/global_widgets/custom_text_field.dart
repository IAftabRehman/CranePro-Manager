import 'package:flutter/material.dart';

class CraneInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
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
    this.readOnly = false,
    this.onTap,
    this.prefixText,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: prefixIcon != null ? IconTheme(data: const IconThemeData(color: Colors.white70), child: prefixIcon!) : null,
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            suffixIcon: suffixIcon != null ? IconTheme(data: const IconThemeData(color: Colors.white70), child: suffixIcon!) : null,
          ),
        );
      },
    );
  }
}
