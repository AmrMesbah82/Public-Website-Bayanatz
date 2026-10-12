part of '../pages/contact_us_page.dart';

class _OfficeCard extends StatelessWidget {
  final ContactOfficeLocation office;
  final bool  isRtl;
  final Color primaryColor;
  const _OfficeCard(
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

    // Figma country card: #F1F2ED, radius 20, 417×267, padding 25; 140 px
    // icon; name Cairo Bold 24/150 % primary; detail SemiBold 18/150 % grey
    // (20 px between the two lines).
    return InkWell(
      onTap: hasLink ? () => _launchMapLink(office.mapLink) : null,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
          width:  double.infinity,
          constraints: BoxConstraints(minHeight: 267.w),
          padding: EdgeInsets.all(25.w),
          decoration: BoxDecoration(
              color:        const Color(0xFFF1F2ED),
              borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (office.iconUrl.isNotEmpty)
                _officeIcon(
                    office.iconUrl, 140.w, 140.w, primaryColor)
              else
                Icon(Icons.location_on,
                    size: 140.w, color: primaryColor),
              SizedBox(height: 0),
              Text(name,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight700.copyWith(
                      color: primaryColor, fontSize: 24.sp, height: 1.5)),
              SizedBox(height: 20.w),
              Text(text,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize13Weight400.copyWith(
                      color: SiteColors.description, fontSize: 18.sp,
                      height: 1.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
    );
  }
}
