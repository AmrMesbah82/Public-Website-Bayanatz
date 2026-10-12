part of '../pages/careers_page.dart';

class _DesktopInternsTab extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final bool isRtl;
  final List<InternModel> interns;
  const _DesktopInternsTab({
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
    required this.interns,
  });

  @override
  Widget build(BuildContext context) {
    if (interns.isEmpty) return const SizedBox.shrink();

    final double screenW = MediaQuery.of(context).size.width;
    final double hPad =
    isTablet ? _tabletHPad() : _desktopHPad(screenW);
    final double totalW = screenW - hPad * 2;
    final int cols = isTablet ? 2 : 3;
    // Figma: 3 cards of 450 per row, 25 px apart (rows 25 apart too).
    final double gapW = isTablet ? 14.w : 25.w;
    final double cardW = (totalW - gapW * (cols - 1)) / cols;

    final List<Widget> rows = [];
    for (int i = 0; i < interns.length; i += cols) {
      final int rowIndex = i ~/ cols;
      final List<Widget> rowChildren = [];
      for (int j = i; j < i + cols; j++) {
        if (j < interns.length) {
          rowChildren.add(
            _DesktopInternCard(
              data: interns[j],
              width: cardW,
              primary: primary,
              isTablet: isTablet,
              isRtl: isRtl,
            ),
          );
        } else {
          rowChildren.add(SizedBox(width: cardW));
        }
        if (j < i + cols - 1) rowChildren.add(SizedBox(width: gapW));
      }
      rows.add(
        _Reveal(
          delay: Duration(milliseconds: 60 + rowIndex * 80),
          direction: _SlideDirection.fromBottom,
          duration: const Duration(milliseconds: 650),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        ),
      );
      if (i + cols < interns.length) rows.add(SizedBox(height: isTablet ? 14.h : 25.w));
    }
    return Column(children: rows);
  }
}
