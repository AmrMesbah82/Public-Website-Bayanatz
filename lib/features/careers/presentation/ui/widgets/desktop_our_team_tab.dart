part of '../pages/careers_page.dart';

class _DesktopOurTeamTab extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final bool isTablet;
  final bool isRtl;
  final List<OurTeamItem> teams;
  const _DesktopOurTeamTab({
    required this.primary,
    required this.secondary,
    this.isTablet = false,
    required this.isRtl,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const SizedBox.shrink();

    final double screenW = MediaQuery.of(context).size.width;
    final double hPad =
    isTablet ? _tabletHPad() : _desktopHPad(screenW);
    final double totalW = screenW - hPad * 2;
    // Figma: 3 cards of 450 per row, 25 px apart.
    final double gapW = isTablet ? 14.w : 25.w;
    final double cardW = (totalW - gapW * 2) / 3;

    final List<Widget> rows = [];
    for (int i = 0; i < teams.length; i += 3) {
      final int rowIndex = i ~/ 3;
      final List<Widget> rowChildren = [];
      for (int j = i; j < i + 3; j++) {
        if (j < teams.length) {
          rowChildren.add(
            _DesktopTeamCard(
              data: teams[j],
              width: cardW,
              primary: primary,
              secondary: secondary,
              isTablet: isTablet,
              isRtl: isRtl,
            ),
          );
        } else {
          rowChildren.add(SizedBox(width: cardW));
        }
        if (j < i + 2) rowChildren.add(SizedBox(width: gapW));
      }
      rows.add(
        _Reveal(
          delay: Duration(milliseconds: 80 + rowIndex * 80),
          direction: _SlideDirection.fromBottom,
          duration: const Duration(milliseconds: 650),
          // Equal-height cards WITHOUT IntrinsicHeight: IntrinsicHeight
          // guessed the height from the chips' intrinsic widths, which on web
          // under-estimates wrapped text → the card was too short and its
          // bottom overflowed (the diagonal yellow/black overflow stripes).
          child: _EqualHeightRow(children: rowChildren),
        ),
      );
      if (i + 3 < teams.length) rows.add(SizedBox(height: isTablet ? 14.h : 25.w));
    }

    return Column(
      children: [
        // QA-Oct11 #28: the "Meet Our Teams" heading is removed.
        ...rows,
      ],
    );
  }
}

/// Lays its children out side by side at their own widths, measures their
/// REAL heights (actual layout, not intrinsic estimates), then gives every
/// child the height of the tallest one — equal-height cards that can never
/// overflow, whatever their content wraps to.
class _EqualHeightRow extends MultiChildRenderObjectWidget {
  const _EqualHeightRow({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(textDirection: Directionality.of(context));

  @override
  void updateRenderObject(
          BuildContext context, _RenderEqualHeightRow renderObject) =>
      renderObject.textDirection = Directionality.of(context);
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  _RenderEqualHeightRow({required TextDirection textDirection})
      : _textDirection = textDirection;

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) {
      child.parentData = _EqualHeightParentData();
    }
  }

  @override
  void performLayout() {
    // Pass 1: natural size of every child (width from the child itself —
    // the cards / gaps are fixed-width SizedBoxes).
    double maxH = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true);
      if (child.size.height > maxH) maxH = child.size.height;
      child = childAfter(child);
    }
    // Pass 2: same width, the row's (tallest) height.
    double total = 0;
    child = firstChild;
    while (child != null) {
      final double w = child.size.width;
      child.layout(BoxConstraints.tightFor(width: w, height: maxH),
          parentUsesSize: true);
      total += w;
      child = childAfter(child);
    }
    final double width = constraints.constrainWidth(total);
    size = constraints.constrain(Size(width, maxH));
    // Position (mirrored in RTL, like a Row).
    double x = _textDirection == TextDirection.rtl ? width : 0;
    child = firstChild;
    while (child != null) {
      final pd = child.parentData! as _EqualHeightParentData;
      if (_textDirection == TextDirection.rtl) {
        x -= child.size.width;
        pd.offset = Offset(x, 0);
      } else {
        pd.offset = Offset(x, 0);
        x += child.size.width;
      }
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
