import 'package:flutter/material.dart';
//purpose of this is to reuse the font and text color


class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;


  SmallText({super.key, this.color =const Color(0xFFccc7c5),
    required this.text,
    this.size=12,
    this.height =1.2
  });


  @override
  Widget build(BuildContext context) {
    return Text(
      text, //text we going to pass, same as color

      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontSize: size,
        height: height,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
