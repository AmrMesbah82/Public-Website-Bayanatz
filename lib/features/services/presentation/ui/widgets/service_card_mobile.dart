part of '../pages/services_page.dart';

class _ServiceCardMobile extends StatelessWidget {
  final JourneyItemModel item;
  final bool             isRtl;
  final Color            primaryColor;
  final Color            secondaryColor;
  const _ServiceCardMobile({
    required this.item,
    this.isRtl = false,
    required this.primaryColor,
    this.secondaryColor = _kGreenLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      // Figma (iPhone): white card radius 8, padding 15, 8 px gaps; 40 px
      // icon; title SemiBold 16/28 #09090B; text Regular 14/24 #666666.
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color:        _kSurface,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _svgIconBox(
                  url:            item.iconUrl,
                  size:           40,
                  radius:         8,
                  primaryColor:   primaryColor,
                  secondaryColor: secondaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(FormatHelper.capitalize(_t(item.title, isRtl)),
                    style: StyleText.fontSize13Weight600.copyWith(
                        fontSize:   16,
                        height:     1.75,
                        fontWeight: FontWeight.w600,
                        color:      SiteColors.title)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_t(item.description, isRtl),
              style: StyleText.fontSize12Weight400.copyWith(
                  fontSize:   14,
                  fontWeight: FontWeight.w400,
                  color:      SiteColors.description,
                  height:     24 / 14)),
        ],
      ),
    );
  }
}

// ─── Service Card – Desktop ───────────────────────────────────────────────────
