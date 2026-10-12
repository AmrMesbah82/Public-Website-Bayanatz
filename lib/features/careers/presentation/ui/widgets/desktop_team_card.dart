part of '../pages/careers_page.dart';

class _DesktopTeamCard extends StatefulWidget {
  final OurTeamItem data;
  final double width;
  final Color primary;
  final Color secondary;
  final bool isTablet;
  final bool isRtl;

  const _DesktopTeamCard({
    required this.data,
    required this.width,
    required this.primary,
    required this.secondary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  State<_DesktopTeamCard> createState() => _DesktopTeamCardState();
}

class _DesktopTeamCardState extends State<_DesktopTeamCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Figma team card (450 wide, radius 24, padding 25, 20 px gaps):
    // 80×80 icon tile (10 % #71717A, radius 14) with a 50 px glyph; name on
    // a primary pill (padding 15, radius 8, SemiBold 22 white); description
    // SemiBold 20/28 grey, centred; "Deliverables:" SemiBold 18 + chips
    // SemiBold 15 on #F1F2ED (radius 4). BUG-249 hierarchy kept.
    final double iconBoxSz = widget.isTablet ? 60.w : 80.w;
    final double iconSz = widget.isTablet ? 30.w : 50.w;
    final double nameFz = widget.isTablet ? 15.sp : 22.sp;
    final double descFz = widget.isTablet ? 14.sp : 20.sp;
    final double cardPad = widget.isTablet ? 14.w : 25.w;
    final double gap = widget.isTablet ? 10.h : 20.w;

    final String name =
    widget.isRtl ? widget.data.title.ar : widget.data.title.en;
    final String desc = widget.isRtl
        ? widget.data.description.ar
        : widget.data.description.en;
    final List<String> deliverables = widget.data.deliverableItems
        .map((d) => widget.isRtl ? d.label.ar : d.label.en)
        .where((s) => s.isNotEmpty)
        .toList();

    return SizedBox(
      width: widget.width,
      child: Container(
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.isTablet ? 12.r : 24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon: network SVG ──────────────────────────────────────
            Container(
              width: iconBoxSz,
              height: iconBoxSz,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isTablet ? 8.r : 14.r),
                // BUG-214: Figma only has a very light 10 % grey tint behind
                // the icon — it was the CMS "Secondary" colour (#2D2D2D).
                color: const Color(0x1A71717A),
              ),
              child: Center(
                child: widget.data.iconUrl.isNotEmpty
                    ? TintedNetworkIcon(
                  url: widget.data.iconUrl,
                  size: iconSz,
                  color: widget.primary,
                )
                    : SizedBox(width: iconSz, height: iconSz),
              ),
            ),
            SizedBox(height: gap),
            Container(
              padding: widget.isTablet
                  ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h)
                  : EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: widget.primary,
                borderRadius: BorderRadius.circular(widget.isTablet ? 6.r : 8.r), // Figma 8
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                // Figma: Cairo SemiBold, white (Cairo set explicitly so the
                // weight renders even when the CMS font has no SemiBold).
                style: GoogleFonts.cairo(
                  fontSize: nameFz,
                  height: 24 / 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    // Figma: Cairo SemiBold 20 / 28, grey, centred.
                    style: GoogleFonts.cairo(
                      fontSize: descFz,
                      height: 28 / 20,
                      fontWeight: FontWeight.w600,
                      color: SiteColors.description,
                    ),
                  ),
                  SizedBox(height: gap),
                  _DesktopDeliverableButtons(
                    deliverables: deliverables,
                    primary: widget.primary,
                    isRtl: widget.isRtl,
                    fontSize: widget.isTablet ? descFz - 2 : 15.sp,
                    labelFontSize: widget.isTablet ? null : 18.sp,
                    selectedIndex: _selectedIndex,
                    onSelectIndex: (index) => setState(() {
                      _selectedIndex =
                      _selectedIndex == index ? null : index;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
