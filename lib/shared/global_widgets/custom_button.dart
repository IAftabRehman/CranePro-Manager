import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';

class CraneButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? loaderColor;

  const CraneButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.loaderColor,
  });
  @override
  @override
  Widget build(BuildContext context) {
    final width = Responsive.screenWidth(context) * 0.5; // Thoda width barha di
    final height = Responsive.isMobile(context) ? 60.0 : 70.0; // Height bhi thodi barha di
    final theme = Theme.of(context);

    Widget buttonChild = isLoading
        ? SizedBox(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
            loaderColor ?? (isOutlined ? theme.colorScheme.secondary : theme.colorScheme.primary)),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 26),
          const SizedBox(width: 12),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.secondary, width: 2.5),
          foregroundColor: theme.colorScheme.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8,
          shadowColor: theme.colorScheme.secondary,
        ),
        child: buttonChild,
      ),
    );
  }
}
