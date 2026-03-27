import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';


class AuthFormIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthFormIntro({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MBAppText.headline2(context).copyWith(
            color: MBColors.textPrimary,
          ),
        ),
        MBSpacing.h(MBSpacing.xs),
        Text(
          subtitle,
          style: MBAppText.body(context).copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}