part of '../pages/about_us_page.dart';

class _ValuesGridDesktop extends StatefulWidget {
  final List<AboutValueItem> values;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _ValuesGridDesktop({
    required this.values,
    required this.primaryColor,
    required this.secondaryColor,
    this.isRtl = false,
  });
  @override
  State<_ValuesGridDesktop> createState() => _ValuesGridDesktopState();
}

class _ValuesGridDesktopState extends State<_ValuesGridDesktop> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty)
      return Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            'No values added yet.',
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    final int idx = _selectedIndex.clamp(0, widget.values.length - 1);
    final selected = widget.values[idx];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Green gradient cards container ──
        // BUG-230: the grid container spans the SAME width as the detail card
        // below it. BUG-228: tiles share the height of the tallest tile in
        // their row, titles are never cut with "…", text ≥ 13 px.
        // Figma: white tile panel (radius 15) with a soft green glow, value
        // tiles 6 per row, 85 px square, radius 12, soft shadow.
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 45.w),
          decoration: BoxDecoration(
            color: Colors.white,
            // Soft brand glow centred in the panel, fading to white at the
            // edges. Tiles are fully opaque, so it never tints them.
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Color.alphaBlend(
                    widget.primaryColor.withOpacity(.18), Colors.white),
                Colors.white,
              ],
              stops: const [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(15.r),
          ),
          // No LayoutBuilder here: this grid sits inside the About row's
          // IntrinsicHeight (LayoutBuilder can't report intrinsic sizes).
          child: Builder(builder: (context) {
            final double hGap = 20.w; // between cards in a row
            final double vGap = 20.w; // between rows
            // Tablet (600–1023, incl. iPad vertical): 5 tiles per row;
            // desktop keeps the Figma 6.
            final int perRow =
                MediaQuery.sizeOf(context).width < 1024 ? 5 : 6;
            final rows = <List<int>>[];
            for (int i = 0; i < widget.values.length; i += perRow) {
              rows.add([
                for (int j = i; j < i + perRow && j < widget.values.length; j++) j
              ]);
            }
            return Column(
              children: [
                for (int r = 0; r < rows.length; r++) ...[
                  if (r > 0) SizedBox(height: vGap),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int slot = 0; slot < perRow; slot++) ...[
                          if (slot > 0) SizedBox(width: hGap),
                          Expanded(
                            child: slot < rows[r].length
                                ? _ValueGridCard(
                                    title: _ab(widget.values[rows[r][slot]].title, widget.isRtl),
                                    iconUrl: widget.values[rows[r][slot]].iconUrl,
                                    isSelected: rows[r][slot] == idx,
                                    primaryColor: widget.primaryColor,
                                    width: double.infinity,
                                    iconSize: 40.w,
                                    fontSize: 11,
                                    padding: 6.w,
                                    figmaTile: true,
                                    onTap: () => setState(() => _selectedIndex = rows[r][slot]),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
        // ── Detail panel OUTSIDE the green container ──
        SizedBox(height: 20.w),
        _ValueDetailPanel(
          value: selected,
          isRtl: widget.isRtl,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
          figmaDesktop: true,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Value Grid Card
// ══════════════════════════════════════════════════════════════════════════════
