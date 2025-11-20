import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../config/constants.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../widgets/event_detail_bottom_sheet.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_provider.dart';
import '../utils/calendar_utils.dart';
import '../utils/font_helper.dart';
import 'package:google_fonts/google_fonts.dart';

/// Event card widget for displaying event information
class EventCard extends StatelessWidget {
  final Event event;
  final String language;
  final bool isPersian;

  const EventCard({
    super.key,
    required this.event,
    required this.language,
    required this.isPersian,
  });

  String _getTypeLabel(String type) {
    final labels = {
      'celebration': {'en': 'celebration', 'fa': 'جشن'},
      'awareness': {'en': 'awareness', 'fa': 'همبستگی'},
      'holiday': {'en': 'holiday', 'fa': 'تعطیل'},
      'observance': {'en': 'observance', 'fa': 'مراسم'},
      'memorial': {'en': 'memorial', 'fa': 'یادبود'},
      'historical': {'en': 'historical', 'fa': 'تاریخی'},
      'anniversary': {'en': 'anniversary', 'fa': 'سالگرد'},
    };
    
    return labels[type.toLowerCase()]?[language] ?? type.toLowerCase();
  }

  String _getOriginLabel(String origin) {
    final labels = {
      'iranian': {'en': 'iranian', 'fa': 'ایرانی'},
      'international': {'en': 'international', 'fa': 'بین المللی'},
      'mixed': {'en': 'mixed', 'fa': 'مشترک'},
      'local': {'en': 'local', 'fa': 'محلی'},
    };
    
    return labels[origin.toLowerCase()]?[language] ?? origin.toLowerCase();
  }

  /// Get combined origin and type label with proper formatting
  String _getOriginTypeLabel(String origin, String type) {
    if (language == 'fa') {
      // Persian: Smart translations for natural Persian phrases
      final originKey = origin.toLowerCase();
      final typeKey = type.toLowerCase();
      
      // Special combinations for natural Persian
      final specialCombinations = {
        'iranian_historical': 'تاریخی ایران',
        'iranian_anniversary': 'سالگرد ایران',
        'iranian_celebration': 'جشن ایرانی',
        'iranian_awareness': 'همبستگی ایرانی',
        'iranian_memorial': 'یادبود ایرانی',
        'iranian_holiday': 'تعطیل ایرانی',
        'iranian_observance': 'مراسم ایرانی',
        'international_celebration': 'جشن بین المللی',
        'international_awareness': 'همبستگی بین المللی',
        'international_memorial': 'یادبود بین المللی',
        'international_holiday': 'تعطیل بین المللی',
        'international_observance': 'مراسم بین المللی',
        'international_anniversary': 'سالگرد بین المللی',
        'international_historical': 'تاریخی بین المللی',
        'mixed_anniversary': 'سالگرد مشترک',
        'mixed_celebration': 'جشن مشترک',
        'mixed_awareness': 'همبستگی مشترک',
        'mixed_memorial': 'یادبود مشترک',
        'mixed_holiday': 'تعطیل مشترک',
        'mixed_observance': 'مراسم مشترک',
        'mixed_historical': 'تاریخی مشترک',
        'local_anniversary': 'سالگرد محلی',
        'local_celebration': 'جشن محلی',
        'local_awareness': 'همبستگی محلی',
        'local_memorial': 'یادبود محلی',
        'local_holiday': 'تعطیل محلی',
        'local_observance': 'مراسم محلی',
        'local_historical': 'تاریخی محلی',
      };
      
      final key = '${originKey}_${typeKey}';
      if (specialCombinations.containsKey(key)) {
        return specialCombinations[key]!;
      }
      
      // Fallback: type + origin
      final originLabel = _getOriginLabel(origin);
      final typeLabel = _getTypeLabel(type);
      return '$typeLabel $originLabel';
    } else {
      // English: "Iranian anniversary" (origin + type, first letter of origin capital, type all lowercase)
      final originLabel = _getOriginLabel(origin);
      final typeLabel = _getTypeLabel(type);
      final originCapitalized = originLabel.isNotEmpty 
          ? originLabel[0].toUpperCase() + originLabel.substring(1).toLowerCase()
          : originLabel;
      return '$originCapitalized $typeLabel';
    }
  }

  bool get _isUserEvent => event.source.toLowerCase() != 'system';

  String? _getTypeIcon(String type) {
    final iconMap = {
      'celebration': AppIcons.partyPopper,
      'historical': AppIcons.library,
      'anniversary': AppIcons.birthdayCake,
      'memorial': AppIcons.candle,
      'awareness': AppIcons.leaves,
      'holiday': AppIcons.partyPopper, // fallback
      'observance': AppIcons.leaves, // fallback
    };
    
    return iconMap[type.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    final originColor = AppColors.getEventTypeColor(event.origin);
    final originTypeLabel = _getOriginTypeLabel(event.origin, event.type);
    final typeIcon = _getTypeIcon(event.type);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;
    
    return GestureDetector(
      onTap: () {
        // Minimize calendar when opening event detail
        final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
        calendarProvider.minimizeCalendar();
        
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.3),
          isScrollControlled: true,
          builder: (context) => EventDetailBottomSheet(
            event: event,
            language: language,
            isPersian: isPersian,
          ),
        ).then((_) {
          // Restore calendar when event detail is closed
          calendarProvider.restoreCalendar();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TBg.card1(context),
          border: isDark ? null : Border.all(
            color: TBr.neutralTertiary(context).withOpacity(0.6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Decorative icon in bottom right (or left for RTL)
              if (typeIcon != null)
                Positioned(
                  right: isPersian ? null : -24,
                  left: isPersian ? -24 : null,
                  bottom: -34,
                  child: Transform.rotate(
                    angle: (isPersian ? 15 : -15) * (3.14159 / 180), // 15 degrees right for Persian, -15 left for English
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(isPersian ? -1.0 : 1.0, 1.0, 1.0), // Flip horizontally for Persian
                      child: SvgPicture.asset(
                        typeIcon,
                        width: 128,
                        height: 128,
                        colorFilter: ColorFilter.mode(
                          iconColor.withOpacity(0.03),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Origin type + More action row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Origin dot + label
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: originColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              originTypeLabel,
                              style: isPersian
                                  ? FontHelper.getYekanBakh(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: TCnt.neutralTertiary(context),
                                      height: 1.4,
                                      letterSpacing: -0.084, // -0.7% of 12
                                    )
                                  : GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: TCnt.neutralTertiary(context),
                                      height: 1.4,
                                      letterSpacing: -0.084, // -0.7% of 12
                                    ),
                            ),
                          ],
                        ),
                        // Right: More action button (only for user events)
                        if (_isUserEvent)
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2),
                            child: SvgPicture.asset(
                              AppIcons.menuHorizontal,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                TCnt.neutralFourth(context),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Title
                    Text(
                      event.title.getText(language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TCnt.neutralMain(context),
                              height: 1.2,
                              letterSpacing: -0.32, // -2% of 16
                            )
                          : GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TCnt.neutralMain(context),
                              height: 1.2,
                              letterSpacing: -0.32, // -2% of 16
                            ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Description
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        final calendarSystem = appProvider.calendarSystem;
                        String descriptionText = event.description.getText(language);
                        
                        // Convert dates based on language and calendar system
                        descriptionText = CalendarUtils.convertDatesInText(descriptionText, language, calendarSystem);
                        
                        return Text(
                          descriptionText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: isPersian
                              ? FontHelper.getYekanBakh(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: TCnt.neutralSecond(context).withOpacity(isDark ? 0.75 : 1.0),
                                  height: 1.6,
                                  letterSpacing: -0.084, // -0.7% of 12
                                )
                              : GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: TCnt.neutralSecond(context).withOpacity(isDark ? 0.75 : 1.0),
                                  height: 1.6,
                                  letterSpacing: -0.084, // -0.7% of 12
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


