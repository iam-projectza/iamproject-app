import 'package:flutter/material.dart';
import '../utils/dimensions.dart';

class BuildSettingsCardWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget title;
  final Widget? subtitle; // Add subtitle as optional parameter
  final VoidCallback? onTap;

  const BuildSettingsCardWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle, // Make it optional
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height10 / 2,
        ),
        padding: EdgeInsets.all(Dimensions.height15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    SizedBox(height: Dimensions.height10 / 2),
                    subtitle!,
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}