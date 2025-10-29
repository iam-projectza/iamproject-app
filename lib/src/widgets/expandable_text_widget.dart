import 'package:flutter/material.dart';
import 'package:iam/src/widgets/small_text.dart';
import '../constants/colors.dart';
import '../utils/dimensions.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;
  bool _needsExpansion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: Dimensions.font16,
          color: AppColors.paragraphColor,
          height: 1.8,
        ),
      ),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 48); // Account for padding

    final bool doesOverflow = textPainter.didExceedMaxLines;
    if (doesOverflow != _needsExpansion) {
      setState(() {
        _needsExpansion = doesOverflow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: TextStyle(
            fontSize: Dimensions.font16,
            color: AppColors.paragraphColor,
            height: 1.8,
          ),
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (_needsExpansion) SizedBox(height: Dimensions.height10),
        if (_needsExpansion)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmallText(
                  text: _isExpanded ? 'Show less' : 'Show more',
                  color: AppColors.mainColor,
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: AppColors.mainColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}