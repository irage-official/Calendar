import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/app_provider.dart';
import '../config/theme_roles.dart';
import 'empty_state_widget.dart';
import 'event_card_widget.dart';
import '../utils/calendar_utils.dart';

/// Widget to display list of events for the selected date
class EventListWidget extends StatefulWidget {
  const EventListWidget({super.key});

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.hasClients && _scrollController.offset > 0;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<EventProvider, CalendarProvider, AppProvider>(
      builder: (context, eventProvider, calendarProvider, appProvider, child) {
        final selectedDate = calendarProvider.selectedDate;
        final language = appProvider.language;
        final isPersian = language == 'fa';
        final calendarSystem = appProvider.calendarSystem;

        // Get events for the selected date
        List<Event> events;
        if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
          final jalali = CalendarUtils.gregorianToJalali(selectedDate);
          events = eventProvider.getEventsForSolarDate(
            jalali.year,
            jalali.month,
            jalali.day,
          );
        } else {
          events = eventProvider.getEventsForDate(selectedDate);
        }

        // Padding values as specified:
        // - Left/Right: 24px
        // - Top: 20px
        // - Bottom: 36px
        const double horizontalPadding = 24.0;
        const double topPadding = 20.0;
        const double bottomPadding = 36.0;

        Widget listWidget;
        if (events.isEmpty) {
          listWidget = Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: EmptyStateWidget(isPersian: isPersian),
            ),
          );
        } else {
          listWidget = ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: topPadding,
              bottom: bottomPadding,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventCard(
                event: events[index],
                language: language,
                isPersian: isPersian,
              );
            },
          );
        }

        return Stack(
          children: [
            listWidget,
            // Top gradient with reverse blur - only show when scrolled
            // Smooth blur transition like iOS 16 - more layers with smaller blur increments for smoother fade
            if (_isScrolled)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // Base gradient container (reverse of bottom gradient)
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TBg.home(context),
                                TBg.home(context).withOpacity(0.7),
                                TBg.home(context).withOpacity(0.3),
                                TBg.home(context).withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                        // Gradient blur layers - reverse order (blur 5 at top, 0 at bottom)
                        // More layers with smaller increments for smoother transition
                        // Layer 1: Top 4.5px with blur 5
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 2: Next 4.5px with blur 4.5
                        Positioned(
                          top: 4.5,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 3: Next 4.5px with blur 4
                        Positioned(
                          top: 9,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 4: Next 4.5px with blur 3.5
                        Positioned(
                          top: 13.5,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 5: Next 4.5px with blur 3
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 6: Next 4.5px with blur 2.5
                        Positioned(
                          top: 22.5,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 7: Next 4.5px with blur 2
                        Positioned(
                          top: 27,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Layer 8: Next 4.5px with blur 1
                        Positioned(
                          top: 31.5,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Container(
                                height: 4.5,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        // Bottom 0px has no blur (blur 0) - smooth fade out
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

