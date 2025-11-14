import 'package:flutter/material.dart';
import '../config/theme_colors.dart';
import '../config/theme_roles.dart';
import '../config/app_icons.dart';
import '../utils/svg_helper.dart';

class ContentBottomSheet extends StatefulWidget {
  final String title;
  final String? description;
  final Widget content;
  final VoidCallback? onClose;
  final IconData? titleIcon;
  final String? titleIconEmoji;

  const ContentBottomSheet({
    super.key,
    required this.title,
    this.description,
    required this.content,
    this.onClose,
    this.titleIcon,
    this.titleIconEmoji,
  });

  @override
  State<ContentBottomSheet> createState() => _ContentBottomSheetState();
}

class _ContentBottomSheetState extends State<ContentBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bool next = _scrollController.hasClients && _scrollController.offset > 8;
    if (next != _isCollapsed) {
      setState(() {
        _isCollapsed = next;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow overflow for drag handle
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: TBg.bottomSheet(context),
            borderRadius: const BorderRadius.all(Radius.circular(32)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  _buildHeader(),
                  
                  // Content section
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.3,
                        maxHeight: constraints.maxHeight - 100, // Reserve space for header
                      ),
                      child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: widget.content,
                      ),
                    ),
                    // Bottom fade (always on) to soften overflow at the bottom of the sheet
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TBg.bottomSheet(context).withOpacity(0.0),
                                TBg.bottomSheet(context).withOpacity(0.7),
                                TBg.bottomSheet(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_isCollapsed)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: IgnorePointer(
                          child: SizedBox(
                            height: 40,
                            child: Column(
                              children: [
                                // Solid white cover for the initial 16px gap
                                Container(height: 16, color: TBg.bottomSheet(context)),
                                // Then a soft fade starting exactly at content top
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          TBg.bottomSheet(context),
                                          TBg.bottomSheet(context).withOpacity(0.7),
                                          TBg.bottomSheet(context).withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Drag handle - floating outside the box with overflow
        // 12px gap between handle and top of bottom sheet
        Positioned(
          top: -16, // -4 (handle height) - 12 (gap) = -16
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColors.white.withOpacity(0.5), // White with 50% opacity for both light and dark
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        layoutBuilder: (currentChild, previousChildren) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentChild != null) currentChild,
            ...previousChildren,
          ],
        ),
        child: _isCollapsed
            ? _buildCollapsedHeader()
            : _buildExpandedHeader(),
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    return Row(
      key: const ValueKey('collapsed'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.titleIconEmoji != null) ...[
                Text(
                  widget.titleIconEmoji!,
                  style: const TextStyle(fontSize: 24, height: 1.0),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.0,
                    letterSpacing: -0.44,
                    color: TCnt.neutralMain(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.onClose != null) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(2),
              child: SvgIconWidget(
                assetPath: AppIcons.xCircle,
                size: 28,
                color: TCnt.neutralSecond(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedHeader() {
    return Column(
      key: const ValueKey('expanded'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.titleIconEmoji != null) ...[
                    Text(widget.titleIconEmoji!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    widget.title,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.6,
                      letterSpacing: -0.44,
                      color: TCnt.neutralMain(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null) ...[
              const SizedBox(width: 24),
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(2),
                  child: SvgIconWidget(
                    assetPath: AppIcons.xCircle,
                    size: 28,
                    color: TCnt.neutralSecond(context),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              letterSpacing: -0.098,
              color: TCnt.neutralTertiary(context),
            ),
          ),
        ],
      ],
    );
  }
}
