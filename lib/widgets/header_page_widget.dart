import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../utils/svg_helper.dart';

class HeaderPageWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? rightAction;
  final Color? backgroundColor;

  const HeaderPageWidget({
    super.key,
    required this.title,
    this.onBackPressed,
    this.rightAction,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      color: backgroundColor ?? TBg.main(context),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left back button
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: TBr.neutralSecondary(context),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
              child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.0),
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  child: SvgIconWidget(
                    assetPath: AppIcons.arrowLeft,
                    size: 16.0,
                    color: TCnt.neutralSecond(context),
                  ),
                ),
              ),
            ),
          ),
          
          // Title in center
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.4,
                  letterSpacing: -0.007,
                  fontWeight: FontWeight.w600,
                  color: TCnt.neutralMain(context),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          
          // Right action button
          SizedBox(
            width: 32.0,
            height: 32.0,
            child: rightAction != null
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        // Handle right action tap
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: rightAction!,
                      ),
                    ),
                  )
                : const SizedBox(width: 32.0, height: 32.0),
          ),
        ],
      ),
    );
  }
}
