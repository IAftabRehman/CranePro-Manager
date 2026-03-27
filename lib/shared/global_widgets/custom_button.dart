import 'package:flutter/material.dart';
import 'package:extend_crane_services/core/utils/responsive.dart';

class CraneButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const CraneButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    // Determine dimensions responsibly
    final width = Responsive.screenWidth(context) * 0.8;
    final height = Responsive.isMobile(context) ? 50.0 : 65.0;
    final theme = Theme.of(context);

    Widget buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(isOutlined ? theme.colorScheme.secondary : theme.colorScheme.primary),
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 22),
                      const SizedBox(width: 10),
                      Text(text),
                    ],
                  )
                : Text(text),
          );

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.secondary, width: 2),
                foregroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: buttonChild,
            ),
    );
  }
}
