import 'package:flutter/material.dart';
import '../config/theme_colors.dart';

/// A loading animation widget showing three horizontal lines that animate in sequence
class LoadingLinesAnimation extends StatefulWidget {
  final double strokeWidth;
  final double gap;
  final Color activeColor;
  final Color inactiveColor;
  final double activeLineWidth;
  final double inactiveLineWidth;

  LoadingLinesAnimation({
    super.key,
    this.strokeWidth = 3.0,
    this.gap = 5.0,
    this.activeColor = ThemeColors.gray900,
    Color? inactiveColor,
    this.activeLineWidth = 24.0,
    this.inactiveLineWidth = 8.0,
  }) : inactiveColor = inactiveColor ?? ThemeColors.gray900.withOpacity(0.2);

  @override
  State<LoadingLinesAnimation> createState() => _LoadingLinesAnimationState();
}

class _LoadingLinesAnimationState extends State<LoadingLinesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 3.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentLine = _animation.value.floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final isActive = index == currentLine;
            return Padding(
              padding: EdgeInsets.only(
                right: index < 2 ? widget.gap : 0,
              ),
              child: Container(
                width: isActive ? widget.activeLineWidth : widget.inactiveLineWidth,
                height: widget.strokeWidth,
                decoration: BoxDecoration(
                  color: isActive ? widget.activeColor : widget.inactiveColor,
                  borderRadius: BorderRadius.circular(widget.strokeWidth / 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
