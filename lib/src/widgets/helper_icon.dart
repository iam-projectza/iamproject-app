import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class HelperIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  const HelperIcon({ super.key,
    required this.icon,
    this.backgroundColor = const Color(0xfffcf4e4),
    this.iconColor = const Color(0xff756d54),
    this.size =40,
    this.iconSize= 16, required Color color,});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: Dimensions.radius20,
        child: Icon(icon, color: Colors.black, size: Dimensions.iconSize16),
      ),
    );
  }
}
