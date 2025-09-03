import 'package:flutter/material.dart';
import 'package:iam/src/widgets/small_text.dart';
import '../constants/colors.dart';
import '../utils/dimensions.dart';


class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({
    super.key,
    required this.text
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {

  late String firstText;
  late String secondHalf;

  bool hiddenText = true;
  double textHeight = Dimensions.screenheight/5.63;

  @override
  void initState() {
    super.initState();
    if(widget.text.length > textHeight){
      firstText = widget.text.substring(0, textHeight.toInt());
      secondHalf = widget.text.substring(textHeight.toInt()+1, widget.text.length);
    } else{
      firstText = widget.text;
      secondHalf='';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty?SmallText(text: firstText,size: Dimensions.font16,color: AppColors.paragraphColor):Column(
        children: [
          SmallText(text: hiddenText?('$firstText...'):(firstText+secondHalf),size: Dimensions.font16, color: AppColors.paragraphColor,height: 1.8,),
          InkWell(
            onTap: (){
              setState(() {
                hiddenText =!hiddenText;
              });
            },
            child: Row(
              children: [
                SmallText(text: 'Show more', color: AppColors.mainColor,),
                Icon(hiddenText?Icons.arrow_drop_down:Icons.arrow_drop_up, color: AppColors.mainColor,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
