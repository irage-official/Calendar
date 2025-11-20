import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../utils/font_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    double sideMargin = 36,
    double bottomMargin = 36,
  }) {
    _timer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final mediaQuery = MediaQuery.of(context);
    final EdgeInsets safe = mediaQuery.padding;
    final bool isPersian = Directionality.of(context) == TextDirection.rtl;

    final entry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomMargin + safe.bottom,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sideMargin),
            child: Center(
              child: _ToastBubble(message: message, isPersian: isPersian),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _currentEntry = entry;

    _timer = Timer(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
      _timer = null;
    });
  }
}

class _ToastBubble extends StatelessWidget {
  final String message;
  final bool isPersian;

  const _ToastBubble({required this.message, required this.isPersian});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ThemeColors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.start,
          style: isPersian
              ? FontHelper.getYekanBakh(
                  color: ThemeColors.white,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.084,
                )
              : GoogleFonts.inter(
                  color: ThemeColors.white,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.084,
                ),
        ),
      ),
    );
  }
}


