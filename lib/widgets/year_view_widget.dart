import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_data.dart'; // For MonthData
import 'package:google_fonts/google_fonts.dart';

/// Year view widget showing all 12 months
class YearViewWidget extends StatelessWidget {
  final int year;
  final String calendarType;
  final Function(int month) onMonthSelected;

  const YearViewWidget({
    super.key,
    required this.year,
    required this.calendarType,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    // Year view doesn't need full CalendarData, just show the grid
    // Each month card will load its own data

    return Container(
      padding: const EdgeInsets.all(16),
      color: TBg.bottomSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _formatYear(year, appProvider.language),
              style: appProvider.language == 'fa'
                  ? FontHelper.getYekanBakh(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _getYearHeaderColor(context, year, calendarType),
                    )
                  : GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _getYearHeaderColor(context, year, calendarType),
                    ),
            ),
          ),
          
          // Month grid
          Expanded(
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                return _buildMonthCard(
                  context,
                  appProvider,
                  year,
                  month,
                  calendarType,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(
    BuildContext context,
    AppProvider appProvider,
    int year,
    int month,
    String calendarType,
  ) {
    return FutureBuilder<MonthData>(
      future: CalendarUtils.getMonthDataFromCalculations(
        year: year,
        month: month,
        calendarType: calendarType,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final monthData = snapshot.data!;
        final monthName = _getMonthName(monthData, appProvider.language, calendarType);

        // Determine active/selected month for coloring in Solar Hijri
        final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
        final bool isSolar = calendarType == 'solar';
        bool isActiveMonth = false;
        if (isSolar) {
          final displayedJalali = CalendarUtils.gregorianToJalali(calendarProvider.displayedMonth);
          isActiveMonth = (displayedJalali.year == year && displayedJalali.month == month);
        } else {
          isActiveMonth = (calendarProvider.displayedMonth.year == year && calendarProvider.displayedMonth.month == month);
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onMonthSelected(month),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: Text(
                      monthName,
                      style: appProvider.language == 'fa'
                          ? FontHelper.getYekanBakh(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActiveMonth ? TCnt.brandMain(context) : TCnt.neutralSecond(context),
                            )
                          : GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActiveMonth ? TCnt.brandMain(context) : TCnt.neutralSecond(context),
                            ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mini calendar grid
                  Flexible(
                    child: _buildMiniCalendar(context, monthData, isActiveMonth),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniCalendar(BuildContext context, MonthData monthData, bool isActiveMonth) {
    // Show first week as preview
    if (monthData.weeks.isEmpty) {
      return const SizedBox();
    }

    final firstWeek = monthData.weeks[0];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth / 7).floorToDouble();
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
          ),
          child: Table(
            columnWidths: {
              for (int i = 0; i < 7; i++) i: FixedColumnWidth(cellWidth),
            },
            children: [
              TableRow(
                children: firstWeek.days.take(7).map((day) {
                  // Weekend detection: Saturday/Sunday for both systems
                  final bool isWeekend = monthData.weekStartDay == 0
                      ? (day.dayOfWeek == 0 || day.dayOfWeek == 1) // Solar: 0=Sat,1=Sun
                      : (day.dayOfWeek == DateTime.saturday || day.dayOfWeek == DateTime.sunday);

                  Color dayColor;
                  if (!day.isCurrentMonth) {
                    dayColor = TCnt.neutralTertiary(context);
                  } else if (isActiveMonth) {
                    dayColor = isWeekend ? TCnt.neutralTertiary(context) : TCnt.neutralSecond(context);
                  } else {
                    dayColor = TCnt.neutralTertiary(context);
                  }
                  return SizedBox(
                    width: cellWidth,
                    child: Center(
                      child: Text(
                        day.date.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: day.isCurrentMonth ? FontWeight.w600 : FontWeight.w400,
                          color: dayColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getYearHeaderColor(BuildContext context, int year, String calendarType) {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    bool isActive = false;
    if (calendarType == 'solar') {
      final selectedJ = CalendarUtils.gregorianToJalali(calendarProvider.selectedDate);
      final todayJ = CalendarUtils.gregorianToJalali(DateTime.now());
      isActive = (selectedJ.year == year) || (todayJ.year == year);
    } else {
      isActive = (calendarProvider.selectedDate.year == year) || (DateTime.now().year == year);
    }
    return isActive ? TCnt.brandMain(context) : TCnt.neutralMain(context);
  }

  String _getMonthName(MonthData monthData, String language, String calendarType) {
    if (language == 'fa') {
      return monthData.monthName; // Persian name
    } else {
      // For Solar Hijri, use Latin name
      if (calendarType == 'solar' && monthData.monthNameLatin != null) {
        return monthData.monthNameLatin!;
      }
      // For Gregorian, use full name or short name
      return monthData.monthNameShort ?? monthData.monthName;
    }
  }

  String _formatYear(int year, String language) {
    if (language == 'fa') {
      // Convert to Persian digits
      const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
      const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      
      String result = year.toString();
      for (int i = 0; i < englishDigits.length; i++) {
        result = result.replaceAll(englishDigits[i], persianDigits[i]);
      }
      return result;
    }
    return year.toString();
  }
}

