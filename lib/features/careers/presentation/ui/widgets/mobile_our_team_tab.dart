part of '../pages/careers_page.dart';

class _MobileOurTeamTab extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final bool isRtl;
  final List<OurTeamItem> teams;
  const _MobileOurTeamTab({
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.teams,
  });

  @override
  State<_MobileOurTeamTab> createState() => _MobileOurTeamTabState();
}

class _MobileOurTeamTabState extends State<_MobileOurTeamTab> {
  int? _selectedTeamIndex;

  @override
  Widget build(BuildContext context) {
    // BUG-249: every team is listed — no extra "See All" step that
    // collapses / expands the list (and makes it jump).
    final List<OurTeamItem> displayed = widget.teams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QA-Oct11 #9: no "Meet Our Teams" heading on phones.
        ...displayed.asMap().entries.map(
              (e) => _Reveal(
            delay: Duration(milliseconds: 80 + e.key * 70),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 650),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10), // Figma 10
              child: _MobileTeamCard(
                data: e.value,
                primary: widget.primary,
                secondary: widget.secondary,
                isRtl: widget.isRtl,
                isExpanded: _selectedTeamIndex == e.key,
                onTap: () => setState(() {
                  _selectedTeamIndex =
                  _selectedTeamIndex == e.key ? null : e.key;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
