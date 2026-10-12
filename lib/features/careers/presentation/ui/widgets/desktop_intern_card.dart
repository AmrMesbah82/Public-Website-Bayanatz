part of '../pages/careers_page.dart';

class _DesktopInternCard extends StatelessWidget {
  final InternModel data;
  final double width;
  final Color primary;
  final bool isTablet;
  final bool isRtl;
  const _DesktopInternCard({
    required this.data,
    required this.width,
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    // Figma intern card (450×216, radius 24, padding 15): 80 px photo,
    // name SemiBold 20/28, degree SemiBold 14/28 (grey), position chip
    // SemiBold 16 white on primary (radius 8); right column at x 214:
    // joined date SemiBold 14, "What Have I Learned" SemiBold 16 black,
    // text SemiBold 14/22 grey.
    final double avatarSz = isTablet ? 70.w : 80.w;
    final double leftColW = isTablet ? 110.w : 172.w;
    final double nameFz = isTablet ? 11.sp : 20.sp;
    final double degFz = isTablet ? 9.sp : 14.sp;
    final double joinFz = isTablet ? 9.sp : 14.sp;
    final double titleFz = isTablet ? 12.sp : 16.sp;
    final double bodyFz = isTablet ? 10.sp : 14.sp;
    final double cardPad = isTablet ? 14.w : 15.w;

    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.all(cardPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 14.r : 24.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftColW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: avatarSz,
                    height: avatarSz,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isTablet
                          ? Border.all(color: primary, width: 1.5)
                          : null,
                    ),
                    child: ClipOval(
                      child: data.photoUrl.isNotEmpty
                          ? Image.network(
                        data.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(
                              'assets/images/careers/person.png',
                              fit: BoxFit.cover,
                            ),
                      )
                          : Image.asset(
                        'assets/images/careers/person.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    data.fullNameFor(isRtl), // BUG-74
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight700.copyWith(
                      fontSize: nameFz,
                      height: isTablet ? null : 1.4,
                      fontWeight: isTablet ? null : FontWeight.w600,
                      color: isTablet ? Colors.black87 : SiteColors.description,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    data.degreesFor(isRtl),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize11Weight600.copyWith(
                      fontSize: degFz,
                      color: const Color(0xFF666666) /* Figma grey */,
                      height: isTablet ? 1.4 : 2.0,
                    ),
                  ),
                  // ── Position ─────────────────────────────────────────
                  if (data.positionFor(isRtl).isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: isTablet
                          ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h)
                          : EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.5.w),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(isTablet ? 6.r : 8.r),
                      ),
                      child: Text(
                        data.positionFor(isRtl),
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize13Weight600.copyWith(
                          color: Colors.white,
                          fontSize: isTablet ? null : 16.sp,
                          height: isTablet ? null : 1.5,
                          fontWeight: isTablet ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 5.w,
                    runSpacing: 3.h,
                    alignment: WrapAlignment.center,
                    children: data.tags
                        .map(
                          (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius:
                          BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          tag,
                          style:
                          StyleText.fontSize11Weight600.copyWith(
                            fontSize: degFz,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 14.w : 27.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      Text(
                        _t('Joined as Intern: ', 'انضم كمتدرب: ', isRtl),
                        style: StyleText.fontSize12Weight600.copyWith(
                          fontSize: joinFz,
                          color: isTablet ? AppColors.secondaryText : SiteColors.description,
                        ),
                      ),

                      Text(
                        data.joinDateLabelFor(isRtl),
                        style: StyleText.fontSize11Weight600.copyWith(
                          fontSize: joinFz,
                          color: isTablet ? AppColors.text : SiteColors.description,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 10.h : 37.w),
                  Text(
                    _t('What Have I Learned', 'ماذا تعلمت', isRtl),
                    style: StyleText.fontSize16Weight700.copyWith(
                      fontSize: titleFz,
                      fontWeight: isTablet ? null : FontWeight.w600,
                      height: isTablet ? null : 1.75,
                      color: isTablet ? Colors.black87 : Colors.black,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6.h : 5.w),
                  Text(
                    data.whatHaveILearnedFor(isRtl),
                    style: StyleText.fontSize14Weight600.copyWith(
                      fontSize: bodyFz,
                      height: isTablet ? 1.6 : 22 / 14,
                      color: isTablet ? Colors.black54 : SiteColors.description,
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP TAB: OUR TEAM  (Firebase data via OurTeamItem)
// ═══════════════════════════════════════════════════════════════════════════════
