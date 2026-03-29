import 'package:flutter/material.dart';
import 'package:shared_models/home/mb_home_section.dart';
import 'package:shared_ui/shared_ui.dart';


// MB Home Unknown Section
// -----------------------

class MBHomeUnknownSection extends StatelessWidget {
  final MBHomeSection section;

  const MBHomeUnknownSection({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MBScreenPadding.page(context).left,
        0,
        MBScreenPadding.page(context).right,
        MBSpacing.lg,
      ),
      child: Text(
        'Unknown section: ${section.sectionType}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}