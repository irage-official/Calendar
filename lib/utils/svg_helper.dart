import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'dart:math' as math;

class SvgIconWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final BoxFit fit;
  final bool flipInRtl;

  const SvgIconWidget({
    Key? key,
    required this.assetPath,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
    this.flipInRtl = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Widget picture = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );

    if (flipInRtl && isRtl) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(math.pi),
        child: picture,
      );
    }

    return picture;
  }
}


