part of '../pages/about_us_page.dart';

class _MobileAccordionItem extends StatefulWidget {
  final _MobileTabData tab;
  final List<AboutValueItem> values;
  final bool isExpanded, isRtl;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _MobileAccordionItem({
    required this.tab,
    required this.values,
    required this.isExpanded,
    required this.onTap,
    this.isRtl = false,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_MobileAccordionItem> createState() => _MobileAccordionItemState();
}

class _MobileAccordionItemState extends State<_MobileAccordionItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final List<AboutValueItem> gridValues =
    (widget.tab.tabIndex == 2 && widget.values.length > 1)
        ? widget.values.sublist(1)
        : (widget.tab.tabIndex == 2 ? <AboutValueItem>[] : widget.values);

    final Color hoverBg = _hoverTint(widget.primaryColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? _kSurface
            : (_hovered ? hoverBg : _kSurface),
        borderRadius: BorderRadius.circular(8), // Figma iPhone radius 8
        border: Border.all(
          color: _hovered && !widget.isExpanded
              ? widget.primaryColor.withOpacity(0.25)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                // Figma: padding 10, 48 px icon tile, title Bold 20/22.
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        // Figma: the same light grey tile open or closed
                        // (BUG-214: never the dark #2D2D2D).
                        color: const Color(0x1A797979),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: widget.tab.iconUrl.isNotEmpty
                            ? _netImg(
                          url: widget.tab.iconUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                              widget.primaryColor, BlendMode.srcIn),
                        )
                            : Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.tab.label,
                        style: StyleText.fontSize16Weight600.copyWith(
                          fontSize: 20,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                    if (widget.isExpanded)
                      // Figma: 40×20 primary chip (radius 6) with ⌃.
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tab.tabIndex != 2 &&
                      widget.tab.svgUrl.isNotEmpty) ...[
                    Center(
                      child: _netImg(
                        url: widget.tab.svgUrl,
                        width: MediaQuery.of(context).size.width -
                            16.w * 2 -
                            12.w * 2,
                        height: 150.h,
                        fit: BoxFit.contain,
                        // ✅ FIX: no colorFilter
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  if (widget.tab.tabIndex != 2)
                    // Figma: Cairo SemiBold 14/22 grey.
                    Text(
                      widget.tab.fullText,
                      style: StyleText.fontSize13Weight400.copyWith(
                        fontSize: 14,
                        height: 22 / 14,
                        fontWeight: FontWeight.w600,
                        color: SiteColors.description,
                      ),
                    ),
                  if (widget.tab.tabIndex == 2)
                    _ValuesGridMobile(
                      values: gridValues,
                      isRtl: widget.isRtl,
                      primaryColor: widget.primaryColor,
                      secondaryColor: widget.secondaryColor,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — MOBILE
// ══════════════════════════════════════════════════════════════════════════════
