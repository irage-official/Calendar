import 'package:flutter/material.dart';
import '../config/theme_roles.dart';

class DayWidgetGregorian extends StatelessWidget {
  final String mainDate; // Gregorian day
  final String? equivalentDate; // Jalali day
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final int weekday; // DateTime.weekday 1=Mon ... 7=Sun
  final bool isOffDay; // generic off day flag (e.g., public holiday)
  final List<Color> eventIndicatorColors;

  const DayWidgetGregorian({
    super.key,
    required this.mainDate,
    this.equivalentDate,
    required this.weekday,
    this.isSelected = false,
    this.isToday = false,
    this.isCurrentMonth = true,
    this.isOffDay = false,
    this.eventIndicatorColors = const [],
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                mainDate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: _getMainColor(context),
                  height: 1.0,
                ),
              ),
              if (equivalentDate != null)
                Positioned(
                  top: 2,
                  right: isSelected ? 4 : 2,
                  child: Text(
                    equivalentDate!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: _getEquivalentColor(context),
                      height: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildIndicators(),
      ],
    );

    return isCurrentMonth ? content : Opacity(opacity: 0.5, child: content);
  }

  bool get _isSaturdayOrSunday => weekday == DateTime.saturday || weekday == DateTime.sunday;

  Color _getBackgroundColor(BuildContext context) {
    if (isSelected) return TCnt.brandMain(context);
    if (isToday && !isSelected) return TCnt.brandTint(context);
    return Colors.transparent;
  }

  Color _getMainColor(BuildContext context) {
    if (isSelected) return TCnt.unsurface(context);
    if (!isCurrentMonth) return TCnt.neutralTertiary(context);
    if (isOffDay) return TCnt.neutralSecond(context);
    return TCnt.neutralMain(context); // normal
  }

  Color _getEquivalentColor(BuildContext context) {
    if (isSelected) {
      return TCnt.unsurface(context).withOpacity(0.85);
    }
    if (isToday) {
      return TCnt.neutralSecond(context);
    }
    return TCnt.neutralTertiary(context); // normal
  }

  Widget _buildIndicators() {
    if (eventIndicatorColors.isEmpty) return const SizedBox(height: 4);
    final colors = eventIndicatorColors.take(4).toList(); // Support up to 4 event types
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors[i], width: 1.2),
            ),
          ),
        ],
      ],
    );
  }
}


