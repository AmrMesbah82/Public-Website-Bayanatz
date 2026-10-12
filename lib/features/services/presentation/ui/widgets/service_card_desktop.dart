part of '../pages/services_page.dart';

class _ServiceCardDesktop extends StatefulWidget {
  final JourneyItemModel item;
  final bool             isRtl;
  final Color            primaryColor;
  final Color            secondaryColor;
  const _ServiceCardDesktop({
    required this.item,
    this.isRtl = false,
    required this.primaryColor,
    this.secondaryColor = _kGreenLight,
  });
  @override
  State<_ServiceCardDesktop> createState() => _ServiceCardDesktopState();
}

class _ServiceCardDesktopState extends State<_ServiceCardDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // BUG-182 — Figma: white card radius 8; 40×40 icon tile INLINE, left of
    // the title; title Cairo SemiBold 16 #09090B; description 14 #666666
    // (line height 24).
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:    double.infinity,
        padding:  EdgeInsets.all(15.w), // Figma: padding 15, gap 8
        decoration: BoxDecoration(
            color:        _kSurface,
            borderRadius: BorderRadius.circular(8.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _svgIconBox(
                    url:            widget.item.iconUrl,
                    size:           40.r,
                    radius:         8.r,
                    primaryColor:   widget.primaryColor,
                    secondaryColor: widget.secondaryColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(_t(widget.item.title, widget.isRtl),
                      style: StyleText.fontSize14Weight400.copyWith(
                          fontSize:   16.sp, // Figma SemiBold 16/28
                          height:     1.75,
                          fontWeight: FontWeight.w600,
                          color:      SiteColors.title)),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            Text(_t(widget.item.description, widget.isRtl),
                style: StyleText.fontSize12Weight500.copyWith(
                    color:      SiteColors.description,
                    fontWeight: FontWeight.w400,
                    fontSize:   14.sp, // Figma Regular 14/24 #666666
                    height:     24 / 14)),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Card – Mobile ───────────────────────────────────────────────────────
