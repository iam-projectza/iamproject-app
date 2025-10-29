import 'package:flutter/material.dart';

import '../utils/dimensions.dart';
import 'big_text.dart';


class AppColumn extends StatelessWidget {

  final String text;
  const AppColumn({
    super.key,
    required this.text,

  }
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BigText(
          text: text,
          size: Dimensions.font16, // Reduced font size
          color: Colors.white,
        ),
        SizedBox(height: Dimensions.height15), // Reduced spacing

      ],
    );
  }
}
