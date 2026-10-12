part of '../pages/careers_page.dart';

class _MobileWhyJoinTab extends StatelessWidget {
  final Color primary;
  final bool isRtl;
  final List<CareersSectionItem> items;
  const _MobileWhyJoinTab(
      {required this.primary, required this.isRtl, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final String text =
        isRtl ? item.description.ar : item.description.en;
        final String svgUrl = item.svgUrl;

        return _Reveal(
          delay: Duration(milliseconds: 60 + i * 80),
          direction:
          i.isEven ? _SlideDirection.fromLeft : _SlideDirection.fromRight,
          duration: const Duration(milliseconds: 650),
          child: Padding(
            // BUG-198: compact card; the picture only when one exists.
            // Figma (iPhone): no card — the illustration centred above the
            // text, Cairo SemiBold 14 / 20 grey, centred; 30 px between rows.
            padding: const EdgeInsets.only(bottom: 30),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (svgUrl.isNotEmpty) ...[
                    Center(
                      child: SmartNetworkImage(svgUrl, width: 200, height: 140),
                    ),
                    const SizedBox(height: 15),
                  ],
                  if (i > 0 && (isRtl ? item.title.ar : item.title.en).trim().isNotEmpty) ...[
                    Text(
                      (isRtl ? item.title.ar : item.title.en).trim(),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize15Weight400.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (text.isNotEmpty)
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize15Weight400.copyWith(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: SiteColors.description,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE TAB: OUR INTERNS  (Firebase data via InternModel)
// ═══════════════════════════════════════════════════════════════════════════════
