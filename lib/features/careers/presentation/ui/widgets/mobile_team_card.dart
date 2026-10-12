part of '../pages/careers_page.dart';

class _MobileTeamCard extends StatelessWidget {
  final OurTeamItem data;
  final Color primary;
  final Color secondary;
  final bool isRtl;
  final bool isExpanded;
  final VoidCallback onTap;
  const _MobileTeamCard({
    required this.data,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = isRtl ? data.title.ar : data.title.en;
    final String desc = isRtl ? data.description.ar : data.description.en;
    final List<String> deliverables = data.deliverableItems
        .map((d) => isRtl ? d.label.ar : d.label.en)
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      // Figma (iPhone team card): radius 24, padding 25, 10 px gaps; 80 px
      // tile (radius 14); name pill padding 10 SemiBold 16; text SemiBold
      // 14/18 grey centred; deliverables SemiBold 14 + chips SemiBold 12.
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Icon: network SVG if available ─────────────────────────────
          Container(
            // BUG-214: light 10 % grey tint (was the dark CMS secondary).
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0x1A71717A),
            ),
            child: Center(
              child: data.iconUrl.isNotEmpty
                  ? TintedNetworkIcon(
                  url: data.iconUrl,
                  size: 50,
                  color: primary,
                )
                  : const SizedBox(width: 50, height: 50),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: StyleText.fontSize12Weight600.copyWith(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            // BUG-249: description reads stronger than the chips.
            style: StyleText.fontSize12Weight600.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 18 / 14,
              color: SiteColors.description,
            ),
          ),
          const SizedBox(height: 10),
          _DeliverableButtons(
            deliverables: deliverables,
            primary: primary,
            isRtl: isRtl,
            isExpanded: isExpanded,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
