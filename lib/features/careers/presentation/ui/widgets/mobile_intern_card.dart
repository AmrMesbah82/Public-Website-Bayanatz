part of '../pages/careers_page.dart';

class _MobileInternCard extends StatelessWidget {
  final InternModel data;
  final Color primary;
  final bool isRtl;
  const _MobileInternCard({
    required this.data,
    required this.primary,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Figma (iPhone intern card): radius 15, padding 15; 65 px photo;
      // name SemiBold 18/28, degree SemiBold 12/28 grey, chip SemiBold 16
      // white (radius 8); right: title SemiBold 14 black, text 12/22 grey.
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Photo: network if available, asset fallback ────────────
                Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: data.photoUrl.isNotEmpty
                        ? Image.network(
                      data.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
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
                SizedBox(height: 6.h),
                Text(
                  data.fullNameFor(isRtl), // BUG-74
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight500.copyWith(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w600,
                    color: SiteColors.description,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  data.degreesFor(isRtl),
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize10Weight400.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF666666) /* Figma grey */,
                    height: 28 / 12,
                  ),
                ),
                // ── Position ───────────────────────────────────────────
                if (data.positionFor(isRtl).isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5.5),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data.positionFor(isRtl),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize10Weight400.copyWith(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 3.w,
                  runSpacing: 3.h,
                  alignment: WrapAlignment.center,
                  children: data.tags
                      .map(
                        (tag) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        tag,
                        style: StyleText.fontSize10Weight700
                            .copyWith(fontSize: 9.sp),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                Row(
                  children: [
                    Text(
                      _t('Joined as intern: ', 'انضم كمتدرب: ', isRtl),
                      style: StyleText.fontSize11Weight400.copyWith(
                        fontSize: 12,
                        color: SiteColors.description,
                      ),
                    ),

                    Text(
                      data.joinDateLabelFor(isRtl),
                      style: StyleText.fontSize11Weight400.copyWith(
                        fontSize: 12,
                        color: SiteColors.description,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  _t('What Have I Learned', 'ماذا تعلمت', isRtl),
                  style: StyleText.fontSize13Weight600.copyWith(
                    fontSize: 14,
                    height: 2.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  data.whatHaveILearnedFor(isRtl),
                  style: StyleText.fontSize12Weight600.copyWith(
                    fontSize: 12,
                    height: 22 / 12,
                    color: SiteColors.description,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE TAB: OUR TEAM  (Firebase data via OurTeamItem)
// ═══════════════════════════════════════════════════════════════════════════════
