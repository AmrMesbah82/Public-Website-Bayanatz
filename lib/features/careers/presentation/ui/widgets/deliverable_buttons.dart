part of '../pages/careers_page.dart';

class _DeliverableButtons extends StatefulWidget {
  final List<String> deliverables;
  final Color primary;
  final bool isRtl;
  final bool isExpanded;
  final VoidCallback onTap;

  const _DeliverableButtons({
    required this.deliverables,
    required this.primary,
    required this.isRtl,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_DeliverableButtons> createState() => _DeliverableButtonsState();
}

class _DeliverableButtonsState extends State<_DeliverableButtons> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // QA-Oct11 #9: full card width and start-aligned, so "Deliverables:"
    // lines up with the text above and each line fills before wrapping.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _t('Deliverables:', 'المخرجات:', widget.isRtl),
              // Figma (iPhone): "Deliverables:" SemiBold 14 black.
              style: StyleText.fontSize12Weight600.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            ...List.generate(widget.deliverables.length, (index) {
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedIndex =
                  _selectedIndex == index ? null : index;
                }),
                child: Container(
                  // BUG-249: chips are a lighter caption (smaller, grey, no
                  // border) than the description they follow.
                  // Figma: chips #F1F2ED radius 4, SemiBold 12 / 150 % grey
                  // (13 px kept for readability).
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  decoration: BoxDecoration(
                    color: SiteColors.chipFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.deliverables[index],
                    style: StyleText.fontSize11Weight400.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: SiteColors.description,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════
