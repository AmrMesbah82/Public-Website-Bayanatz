part of '../pages/contact_us_page.dart';

class _OfficeCardMobile extends StatelessWidget {
  final ContactOfficeLocation office;
  final bool  isRtl;
  final Color primaryColor;
  const _OfficeCardMobile(
      {required this.office,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String name = isRtl && office.locationName.ar.isNotEmpty
        ? office.locationName.ar
        : office.locationName.en;
    final String text = isRtl && office.text1.ar.isNotEmpty
        ? office.text1.ar
        : office.text1.en;

    final bool hasLink = office.mapLink.isNotEmpty;

    return GestureDetector(
      onTap: hasLink ? () => _launchMapLink(office.mapLink) : null,
      child: MouseRegion(
        cursor:
        hasLink ? SystemMouseCursors.click : MouseCursor.defer,
        child: Container(
          width:   double.infinity,
          // Figma (iPhone): #F1F2ED card, radius 4, padding 25; 140 px
          // icon; name Bold 24/150 %; detail SemiBold 18/150 % grey.
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color:        const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(4)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (office.iconUrl.isNotEmpty)
                _officeIcon(
                    office.iconUrl, 140, 140, primaryColor)
              else
                Icon(Icons.location_on,
                    size: 140, color: primaryColor),
              Text(name,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight700.copyWith(
                      color: primaryColor, fontSize: 24, height: 1.5)),
              const SizedBox(height: 20),
              Text(text,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: SiteColors.description, fontSize: 18,
                      height: 1.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _officeIcon(
    String url, double w, double h, Color primaryColor) =>
    Image.network(
      url,
      width: w, height: h, fit: BoxFit.contain,
      loadingBuilder: (_, child, p) =>
      p == null ? child : SizedBox(width: w, height: h),
      errorBuilder: (_, __, ___) => SvgPicture.network(
        url,
        width: w, height: h, fit: BoxFit.contain,
      ),
    );

// ═══════════════════════════════════════════════════════════════════════════════
// SOCIAL ICONS
// ═══════════════════════════════════════════════════════════════════════════════
