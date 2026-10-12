import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../custom/circle_progress.dart';

/// Legacy name — delegates to the shared [CircleProgress]
/// (Firebase primary colour).
class CircleProgressMaster extends StatelessWidget {
  const CircleProgressMaster({super.key});

  @override
  Widget build(BuildContext context) => CircleProgress(size: 40.sp);
}
