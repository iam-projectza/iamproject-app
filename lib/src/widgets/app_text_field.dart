import 'package:flutter/material.dart';

import '../constants/colors.dart';
class AppTextField extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final IconData icon;
  bool isObscure;

  AppTextField({super.key,
    required this.textController,
    required this.hintText, required this.icon, this.isObscure=false});

  @override
  Widget build(BuildContext context) {
    return  Container(
      //margin: EdgeInsets.only(left: Dimensions.height20, right: Dimensions.height20),
      decoration: BoxDecoration(

      ),
      child: TextField(
        obscureText: isObscure?true:false,
        controller: textController,
        decoration: InputDecoration(
          hintText:hintText,
          prefixIcon: Icon(icon,color: AppColors.paragraphColor,),
          focusedBorder:OutlineInputBorder(

            borderSide: const BorderSide(
              width: 1.0,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(

            borderSide: const BorderSide(
              width: 1.0,
              color: Colors.white,
            ),
          ),
          border: OutlineInputBorder(


          ),
        ),
      ),
    );
  }
}
