import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final RenderObject? renderObject = _textKey.currentContext?.findRenderObject();
    if (renderObject is RenderParagraph) {
      final TextPainter textPainter = renderObject.text as TextPainter;
      final bool doesOverflow = textPainter.didExceedMaxLines;
      if (doesOverflow != _needsExpansion) {
        setState(() {
          _needsExpansion = doesOverflow;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Text(
                widget.text,
                key: _textKey,
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: AppColors.paragraphColor,
                  height: 1.8,
                ),
                maxLines: _isExpanded ? null : widget.maxLines,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              );
            },
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
      ),
    );
  }
}