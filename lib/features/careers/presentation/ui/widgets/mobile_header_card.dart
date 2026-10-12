part of '../pages/careers_page.dart';

class _MobileHeaderCard extends StatelessWidget {
  final Color primary;
  final bool isRtl;
  final String description;
  final String btnLabel;
  const _MobileHeaderCard({
    required this.primary,
    required this.isRtl,
    required this.description,
    required this.btnLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Figma (iPhone): white card radius 15, padding 10; text Cairo
      // Medium 14 / 23 grey; "Apply Now" 100×36 radius 8, SemiBold 14.
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty)
            Text(
              description,
              style: StyleText.fontSize13Weight400.copyWith(
                fontSize: 14,
                height: 23 / 14,
                fontWeight: FontWeight.w500,
                color: SiteColors.description,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              if (btnLabel.isNotEmpty)
                GestureDetector(
                  onTap: () => context.go('/jobs'),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 100, minHeight: 36),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      btnLabel,
                      style: StyleText.fontSize12Weight600.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
