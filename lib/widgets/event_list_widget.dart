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
  bool _canScroll = false;

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
    _checkScrollState();
  }

  void _checkScrollState() {
    if (!_scrollController.hasClients) return;
    
    // Check if content can actually scroll (has overflow)
    final canScroll = _scrollController.position.maxScrollExtent > 0;
    
    // Only show gradient if content can scroll AND user has scrolled
    final isScrolled = canScroll && _scrollController.offset > 0;
    
    if (isScrolled != _isScrolled || canScroll != _canScroll) {
      setState(() {
        _isScrolled = isScrolled;
        _canScroll = canScroll;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<EventProvider, CalendarProvider, AppProvider>(
      builder: (context, eventProvider, calendarProvider, appProvider, child) {
        // Check scroll state after layout changes (e.g., when calendar bottom sheet state changes)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkScrollState();
        });
        
        final selectedDate = calendarProvider.selectedDate;
        final language = appProvider.language;
        final isPersian = language == 'fa';
        final calendarSystem = appProvider.calendarSystem;

        // Get events for the selected date
        List<Event> allEvents;
        if (calendarSystem == 'solar' || calendarSystem == 'shahanshahi') {
          final jalali = CalendarUtils.gregorianToJalali(selectedDate);
          allEvents = eventProvider.getEventsForSolarDate(
            jalali.year,
            jalali.month,
            jalali.day,
          );
        } else {
          allEvents = eventProvider.getEventsForDate(selectedDate);
        }

        // Filter events based on enabled origins and event types for home screen
        // If an origin is disabled, hide all events from that origin
        // If an event type is disabled, hide events of that type
        final enabledOrigins = appProvider.enabledOrigins ??
            ['iranian', 'international', 'mixed', 'local'];
        final enabledEventTypes = appProvider.enabledEventTypes;
        
        // All possible event types
        const allEventTypes = ['celebration', 'historical', 'anniversary', 'memorial', 'awareness'];
        
        final Set<String> allowedOrigins = enabledOrigins
            .map((origin) => origin.toLowerCase())
            .toSet();
        
        // Check if all event types are enabled (user hasn't disabled any)
        // If enabledEventTypes contains all types, don't filter by type
        final bool allTypesEnabled = enabledEventTypes.length == allEventTypes.length &&
            allEventTypes.every((type) => enabledEventTypes.contains(type));
        
        final Set<String>? allowedTypes = allTypesEnabled
            ? null // Don't filter by type if all types are enabled
            : enabledEventTypes.map((type) => type.toLowerCase()).toSet();

        // Debug: Print filtering info
        // print('DEBUG: enabledOrigins = $enabledOrigins');
        // print('DEBUG: allowedOrigins = $allowedOrigins');
        // print('DEBUG: enabledEventTypes = $enabledEventTypes');
        // print('DEBUG: allTypesEnabled = $allTypesEnabled');
        // print('DEBUG: allEvents count = ${allEvents.length}');
        // for (final event in allEvents) {
        //   print('DEBUG: event origin=${event.origin}, type=${event.type}');
        // }

        final List<Event> events = allEvents.where((event) {
          final String origin = event.origin.toLowerCase();
          final String type = event.type.toLowerCase();

          // Check if origin is enabled
          final bool originAllowed = allowedOrigins.contains(origin);
          if (!originAllowed) {
            // print('DEBUG: Filtered out event ${event.id} - origin $origin not allowed');
            return false;
          }

          // Check if event type is enabled (only if not all types are enabled)
          if (allowedTypes != null) {
            final bool typeAllowed = allowedTypes.contains(type);
            if (!typeAllowed) {
              // print('DEBUG: Filtered out event ${event.id} - type $type not allowed');
              return false;
            }
          }

          return true;
        }).toList();
        
        // print('DEBUG: Filtered events count = ${events.length}');

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
            // Offset from top to avoid clipping logo (6px offset)
            if (_isScrolled) ...[
              // Fill empty space above blur with home background color
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 6,
                    color: TBg.home(context),
                  ),
                ),
              ),
              // Blur effect starting from 6px offset
              Positioned(
                top: 6,
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
          ],
        );
      },
    );
  }
}

