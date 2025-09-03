import 'package:flutter/material.dart';

class InteractiveFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final Color activeColor;
  final Color inactiveColor;

  const InteractiveFavoriteButton({super.key, required this.isFavorite, required this.onToggle, required this.activeColor, required this.inactiveColor});

  @override
  State<InteractiveFavoriteButton> createState() => _InteractiveFavoriteButtonState();
}

class _InteractiveFavoriteButtonState extends State<InteractiveFavoriteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)).animate(_controller);

  @override
  void didUpdateWidget(covariant InteractiveFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isFavorite ? widget.activeColor : widget.inactiveColor;
    return ScaleTransition(
      scale: _scale,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: widget.onToggle,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(32)),
          child: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border, color: color, size: 22),
        ),
      ),
    );
  }
}
