import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart';
import '../config/constants.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../services/date_converter_service.dart';
import '../utils/calendar_utils.dart';
import '../utils/svg_helper.dart';
import '../utils/font_helper.dart';
import '../providers/app_provider.dart';
import '../widgets/alert_message_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetailBottomSheet extends StatefulWidget {
  final Event event;
  final String language;
  final bool isPersian;

  const EventDetailBottomSheet({
    super.key,
    required this.event,
    required this.language,
    required this.isPersian,
  });

  @override
  State<EventDetailBottomSheet> createState() => _EventDetailBottomSheetState();
}

class _EventDetailBottomSheetState extends State<EventDetailBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _imageRetryKey = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bool next = _scrollController.hasClients && _scrollController.offset > 8;
    if (next != _isScrolled) {
      setState(() {
        _isScrolled = next;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Event get event => widget.event;
  String get language => widget.language;
  bool get isPersian => widget.isPersian;

  /// Check if image is a URL or asset path
  bool _isImageUrl(String imagePath) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://');
  }

  /// Build image error state widget with empty state style
  Widget _buildImageErrorState(BuildContext context, {String? imageUrl}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeColors.gray100.withOpacity(0.05)
            : ThemeColors.gray900.withOpacity(0.06),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 48.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon - image, 32x32, neutral tertiary
            SvgPicture.asset(
              AppIcons.image,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                TCnt.neutralTertiary(context),
                BlendMode.srcIn,
              ),
            ),
            
            // Spacing between icon and title - 12 pixels
            const SizedBox(height: 12),
            
            // Title - font size 14, semi-bold, neutral secondary, line height 140%, letter spacing -2%
            Text(
              isPersian ? 'نمی‌توان تصویر را بارگذاری کرد' : 'Cannot load image',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TCnt.neutralSecond(context),
                      height: 1.4,
                      letterSpacing: -0.28, // -2% of 14px
                    )
                  : GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TCnt.neutralSecond(context),
                      height: 1.4,
                      letterSpacing: -0.28, // -2% of 14px
                    ),
              textAlign: TextAlign.center,
            ),
            
            // Gap between title and description - 4 pixels
            const SizedBox(height: 4),
            
            // Description - font size 12, neutral tertiary, line height 140%, letter spacing -0.7%
            Text(
              isPersian 
                  ? 'نمی‌توانیم تصویر یا ویدیو را بارگذاری کنیم. لطفاً دوباره تلاش کنید.' 
                  : 'We couldn\'t load photo or video. Please try again.',
              style: isPersian
                  ? FontHelper.getYekanBakh(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: TCnt.neutralTertiary(context),
                      height: 1.4,
                      letterSpacing: -0.084, // -0.7% of 12px
                    )
                  : GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: TCnt.neutralTertiary(context),
                      height: 1.4,
                      letterSpacing: -0.084, // -0.7% of 12px
                    ),
              textAlign: TextAlign.center,
            ),
            
            // Gap between description and retry button - 16 pixels
            const SizedBox(height: 16),
            
            // Retry button
            if (imageUrl != null)
              GestureDetector(
                onTap: () {
                  // Force rebuild with new key to retry loading the image
                  setState(() {
                    _imageRetryKey++;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/icons/refresh-right.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        ThemeColors.primary500,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPersian ? 'تلاش مجدد' : 'Retry',
                      style: isPersian
                          ? FontHelper.getYekanBakh(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.primary500,
                              height: 1.4,
                              letterSpacing: -0.28, // -2% of 14px
                            )
                          : GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.primary500,
                              height: 1.4,
                              letterSpacing: -0.28, // -2% of 14px
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build network image widget with proper error handling
  Widget _buildNetworkImage(String imageUrl, BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey('image_${_imageRetryKey}_$imageUrl'),
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      httpHeaders: const {
        'Accept': 'image/*',
        'User-Agent': 'Mozilla/5.0',
      },
      memCacheWidth: 1200,
      memCacheHeight: 800,
      maxWidthDiskCache: 1200,
      maxHeightDiskCache: 800,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => Container(
        color: TBg.card2(context),
        child: Center(
          child: CircularProgressIndicator(
            color: TCnt.neutralTertiary(context),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('CachedNetworkImage error: $error for URL: $url');
        // Show empty state with image icon
        return _buildImageErrorState(context, imageUrl: url);
      },
    );
  }

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

  String? _getTypeIcon(String type) {
    final iconMap = {
      'celebration': 'assets/images/icons/party-popper-circle.svg',
      'historical': 'assets/images/icons/library-circle.svg',
      'anniversary': 'assets/images/icons/birthday-cake-circle.svg',
      'memorial': 'assets/images/icons/candle-circle.svg',
      'awareness': 'assets/images/icons/leaves-circle.svg',
      'holiday': 'assets/images/icons/party-popper-circle.svg',
      'observance': 'assets/images/icons/leaves-circle.svg',
    };
    
    return iconMap[type.toLowerCase()];
  }

  String _formatGregorianDate(DateTime date, String language) {
    final dateConverter = DateConverterService();
    if (language == 'fa') {
      // Persian: "۳۱ اکتبر ۲۰۲۵" - with Persian numerals
      final monthName = dateConverter.getGregorianMonthNameFa(date.month);
      final dayStr = CalendarUtils.englishToPersianDigits(date.day.toString());
      final yearStr = CalendarUtils.englishToPersianDigits(date.year.toString());
      return '$dayStr $monthName $yearStr';
    } else {
      // English: "October 31, 2025"
      final monthName = dateConverter.getGregorianMonthName(date.month);
      return '$monthName ${date.day}, ${date.year}';
    }
  }

  String _formatSolarDate(String solarDateStr, String language) {
    final parts = solarDateStr.split('-');
    if (parts.length != 3) return solarDateStr;
    
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final dateConverter = DateConverterService();
    
    if (language == 'fa') {
      // Persian: "۹ آبان ۱۴۰۴" - with Persian numerals
      final monthName = dateConverter.getJalaliMonthNameFa(month);
      final dayStr = CalendarUtils.englishToPersianDigits(day.toString());
      final yearStr = CalendarUtils.englishToPersianDigits(year.toString());
      return '$dayStr $monthName $yearStr';
    } else {
      // English: "9 Aban 1404"
      final monthName = dateConverter.getJalaliMonthNameEn(month);
      return '$day $monthName $year';
    }
  }

  String _formatShahanshahiDate(String solarDateStr, String language) {
    final parts = solarDateStr.split('-');
    if (parts.length != 3) return solarDateStr;
    
    final jalaliYear = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    final dateConverter = DateConverterService();
    final shahanshahiYear = dateConverter.getShahanshahiYear(jalaliYear);
    
    if (language == 'fa') {
      // Persian: "۹ آبان ۲۵۸۴" - with Persian numerals
      final monthName = dateConverter.getJalaliMonthNameFa(month);
      final dayStr = CalendarUtils.englishToPersianDigits(day.toString());
      final yearStr = CalendarUtils.englishToPersianDigits(shahanshahiYear.toString());
      return '$dayStr $monthName $yearStr';
    } else {
      // English: "9 Aban 2584"
      final monthName = dateConverter.getJalaliMonthNameEn(month);
      return '$day $monthName $shahanshahiYear';
    }
  }

  /// Get primary and equivalent date strings based on language and calendar type
  /// Returns a map with 'primary' and 'equivalent' date strings
  Map<String, String> _getEventDates(String calendarType) {
    final gregorianDate = event.gregorianDate;
    final formattedGregorian = _formatGregorianDate(gregorianDate, language);
    final formattedSolar = _formatSolarDate(event.date.solar, language);
    final formattedShahanshahi = _formatShahanshahiDate(event.date.solar, language);
    
    final isSolar = calendarType == 'solar';
    final isShahanshahi = calendarType == 'shahanshahi';
    
    if (language == 'fa') {
      // Persian language
      if (isSolar) {
        // Persian - Solar Hijri: primary = "۹ آبان ۱۴۰۴", equivalent = "۳۱ اکتبر ۲۰۲۵"
        return {'primary': formattedSolar, 'equivalent': formattedGregorian};
      } else if (isShahanshahi) {
        // Persian - Shahanshahi: primary = "۹ آبان ۲۵۸۴", equivalent = "۳۱ اکتبر ۲۰۲۵"
        return {'primary': formattedShahanshahi, 'equivalent': formattedGregorian};
      } else {
        // Persian - Gregorian: primary = "۳۱ اکتبر ۲۰۲۵", equivalent = "۹ آبان ۲۵۸۴" (Shahanshahi)
        return {'primary': formattedGregorian, 'equivalent': formattedShahanshahi};
      }
    } else {
      // English language
      if (isSolar) {
        // English - Solar Hijri: primary = "9 Aban 1404", equivalent = "October 31, 2025"
        return {'primary': formattedSolar, 'equivalent': formattedGregorian};
      } else if (isShahanshahi) {
        // English - Shahanshahi: primary = "9 Aban 2584", equivalent = "October 31, 2025"
        return {'primary': formattedShahanshahi, 'equivalent': formattedGregorian};
      } else {
        // English - Gregorian: primary = "October 31, 2025", equivalent = "9 Aban 2584" (Shahanshahi)
        return {'primary': formattedGregorian, 'equivalent': formattedShahanshahi};
      }
    }
  }

  String _formatTime(EventTime time, String language) {
    if (!time.isActive || time.start == null) {
      return language == 'fa' ? 'نامشخص' : 'Unspecified';
    }
    
    // Format time if available
    return time.start!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              // Prevent closing when tapping inside
            },
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: BoxDecoration(
                color: TBg.bottomSheet(context),
                borderRadius: const BorderRadius.all(Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sticky header: Origin + Type badge and X circle
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: _buildTopSection(context),
                  ),
                  
                  // Scrollable content with shadow gradient
                  Flexible(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Image section (only if image exists)
                                if (event.image != null && event.image!.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: AspectRatio(
                                      aspectRatio: 3 / 2,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.transparent
                                              : TBg.card2(context),
                                        ),
                                        child: _isImageUrl(event.image!)
                                            ? _buildNetworkImage(event.image!, context)
                                            : Image.asset(
                                                event.image!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? Colors.transparent
                                                        : TBg.card2(context),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                  // 16px gap after image
                                  const SizedBox(height: 16),
                                ],
                                
                                // Headline section
                                _buildHeadline(context),
                                
                                // 16px gap before description
                                const SizedBox(height: 16),
                                
                                // Description section
                                _buildDescription(context),
                                
                                // 16px gap before detail
                                const SizedBox(height: 16),
                                
                                // Detail section (Date + Time)
                                _buildDetailSection(context),
                                
                                // 16px gap before alert message
                                if (event.significance != null &&
                                    (event.significance!.fa != null || event.significance!.en != null))
                                  ...[
                                    const SizedBox(height: 16),
                                    _buildSignificanceSection(context),
                                  ],
                              ],
                            ),
                          ),
                        ),
                        // Shadow gradient when scrolled (floating above content, doesn't affect layout)
                        if (_isScrolled)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.4, 1.0],
                                    colors: [
                                      TBg.bottomSheet(context),
                                      TBg.bottomSheet(context).withOpacity(0.7),
                                      TBg.bottomSheet(context).withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Drag handle
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColors.white.withOpacity(0.75), // White with 75% opacity for both light and dark
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    final originColor = AppColors.getEventTypeColor(event.origin);
    final originTypeLabel = _getOriginTypeLabel(event.origin, event.type);
    final typeIcon = _getTypeIcon(event.type);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Origin + Type badge
        Container(
          padding: const EdgeInsets.all(4), // 4px padding on all sides
          decoration: BoxDecoration(
            color: originColor.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (typeIcon != null) ...[
                SvgPicture.asset(
                  typeIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    originColor,
                    BlendMode.srcIn,
                  ),
                ),
                // No gap between icon and label
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6), // 6px padding left and right of label
                child: Text(
                  originTypeLabel,
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: -0.084, // -0.7% of 12
                          color: originColor,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: -0.084, // -0.7% of 12
                          color: originColor,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ],
          ),
        ),
        
        // Flexible spacer for automatic gap
        Expanded(child: Container()),
        
        // Right: X circle button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(2),
            child: SvgPicture.asset(
              AppIcons.xCircle,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                TCnt.neutralSecond(context),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          event.title.getText(language),
          style: isPersian
              ? FontHelper.getYekanBakh(
                  fontSize: 20,
                  height: 1.4, // 140%
                  letterSpacing: -0.4, // -2% of 20
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w700,
                )
              : GoogleFonts.inter(
                  fontSize: 20,
                  height: 1.4, // 140%
                  letterSpacing: -0.4, // -2% of 20
                  color: TCnt.neutralMain(context),
                  fontWeight: FontWeight.w700,
                ),
        ),
        
        // Location
        const SizedBox(height: 6),
        Text(
          event.location.getText(language),
          style: isPersian
              ? FontHelper.getYekanBakh(
                  fontSize: 12,
                  height: 1.4, // 140%
                  letterSpacing: -0.084, // -0.7% of 12
                  color: TCnt.neutralFourth(context),
                )
              : GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4, // 140%
                  letterSpacing: -0.084, // -0.7% of 12
                  color: TCnt.neutralFourth(context),
                ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final calendarSystem = appProvider.calendarSystem;
    String descriptionText = event.description.getText(language);
    
    // Convert dates based on language and calendar system
    descriptionText = CalendarUtils.convertDatesInText(descriptionText, language, calendarSystem);
    
    return Text(
      descriptionText,
      style: isPersian
          ? FontHelper.getYekanBakh(
              fontSize: 14,
              height: 1.6, // 160%
              letterSpacing: -0.098, // -0.7% of 14
              color: TCnt.neutralSecond(context),
            )
          : GoogleFonts.inter(
              fontSize: 14,
              height: 1.6, // 160%
              letterSpacing: -0.098, // -0.7% of 14
              color: TCnt.neutralSecond(context),
            ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final calendarType = appProvider.calendarSystem;
    final dates = _getEventDates(calendarType);
    final formattedTime = _formatTime(event.time, language);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date column
        Expanded(
          child: _buildDetailItem(
            context,
            icon: AppIcons.calendar,
            label: language == 'fa' ? 'تاریخ' : 'Date',
            value: dates['primary']!,
            equivalentValue: dates['equivalent'],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Time column
        Expanded(
          child: _buildDetailItem(
            context,
            icon: AppIcons.clockCircle,
            label: language == 'fa' ? 'زمان' : 'Time',
            value: formattedTime,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    String? equivalentValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              TCnt.neutralFourth(context),
              BlendMode.srcIn,
            ),
          ),
          
          // Gap with context
          const SizedBox(height: 6),
          
          // Label
          Text(
            label,
            style: isPersian
                ? FontHelper.getYekanBakh(
                    fontSize: 12,
                    height: 1.4, // 140%
                    letterSpacing: -0.084, // -0.7% of 12
                    color: TCnt.neutralFourth(context),
                  )
                : GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4, // 140%
                    letterSpacing: -0.084, // -0.7% of 12
                    color: TCnt.neutralFourth(context),
                  ),
          ),
          
          // Value
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: isPersian
                      ? FontHelper.getYekanBakh(
                          fontSize: 14,
                          height: 1.4, // 140%
                          letterSpacing: -0.28, // -2% of 14
                          color: TCnt.neutralMain(context),
                          fontWeight: FontWeight.w700,
                        )
                      : GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.4, // 140%
                          letterSpacing: -0.28, // -2% of 14
                          color: TCnt.neutralMain(context),
                          fontWeight: FontWeight.w700,
                        ),
                ),
                if (equivalentValue != null) ...[
                  TextSpan(
                    text: ' ($equivalentValue)',
                    style: isPersian
                        ? FontHelper.getYekanBakh(
                            fontSize: 12,
                            height: 1.4, // 140%
                            letterSpacing: -0.084, // -0.7% of 12
                            color: TCnt.neutralFourth(context),
                          )
                        : GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.4, // 140%
                            letterSpacing: -0.084, // -0.7% of 12
                            color: TCnt.neutralFourth(context),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignificanceSection(BuildContext context) {
    final significanceText = event.significance?.getText(language);
    if (significanceText == null || significanceText.isEmpty) {
      return const SizedBox.shrink();
    }

    return AlertMessageWidget(
      type: AlertType.warning,
      title: language == 'fa' ? 'اهمیت' : 'Significance',
      description: significanceText,
      isPersian: isPersian,
    );
  }
}

