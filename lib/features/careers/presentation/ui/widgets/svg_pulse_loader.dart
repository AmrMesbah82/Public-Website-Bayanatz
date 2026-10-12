part of '../pages/careers_page.dart';

// The page loader is the shared site loader: logo centred on the page,
// fading in / out until the data arrives (core/widgets/app_logo_loader.dart).
class _SvgPulseLoader extends StatelessWidget {
  final String? logoUrl;
  final Color   backgroundColor;
  const _SvgPulseLoader({this.logoUrl, required this.backgroundColor});

  @override
  Widget build(BuildContext context) =>
      AppLogoLoader(logoUrl: logoUrl, backgroundColor: backgroundColor);
}
