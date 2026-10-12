part of '../pages/careers_page.dart';

class _DesktopDeliverableButtons extends StatelessWidget {
  final List<String> deliverables;
  final Color primary;
  final bool isRtl;
  final double fontSize;
  /// "Deliverables:" size (Figma desktop SemiBold 18 black); null = [fontSize].
  final double? labelFontSize;
  final int? selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const _DesktopDeliverableButtons({
    required this.deliverables,
    required this.primary,
    required this.isRtl,
    required this.fontSize,
    this.labelFontSize,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool figma = labelFontSize != null;
    // QA-Oct11 #21: the chips flow side by side and only start a new line
    // when the current one is full; the block spans the whole card width
    // and starts at the same edge as the text.
    return SizedBox(
      width: double.infinity,
      child: Wrap(
      spacing: figma ? 8.w : 6.w,
      runSpacing: figma ? 8.w : 6.h,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _t('Deliverables:', 'المخرجات:', isRtl),
          // Figma: Cairo SemiBold 18 / 28, black.
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            height: figma ? 28 / 18 : null,
            fontWeight: FontWeight.w600,
            color: figma ? Colors.black : SiteColors.description,
          ),
        ),
        ...List.generate(deliverables.length, (index) {
          return GestureDetector(
            onTap: () => onSelectIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // Figma chip: 26 tall, 16 px side padding, radius 4.
              // QA-Oct11 #21: no `alignment` here — an aligned Container
              // grows to the full Wrap width, which stacked every chip on
              // its own full-width line. The chip now hugs its label.
              padding: figma
                  ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.w)
                  : EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              // BUG-249: lighter / smaller caption chips.
              decoration: BoxDecoration(
                color: SiteColors.chipFill,
                borderRadius: BorderRadius.circular(figma ? 4.r : 6.r),
              ),
              child: Text(
                deliverables[index],
                // Figma: Cairo SemiBold 15 / 150 %, grey.
                style: GoogleFonts.cairo(
                  fontSize: fontSize,
                  height: figma ? 1.5 : null,
                  fontWeight: figma ? FontWeight.w600 : FontWeight.w500,
                  color: SiteColors.description,
                ),
              ),
            ),
          );
        }),
      ],
      ),
    );
  }
}

// ─── Desktop helper text widgets ─────────────────────────────────────────────
