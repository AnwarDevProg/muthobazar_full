import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_defaults.dart';

// MuthoBazar Design Card Engine V1
// File: mb_design_indicator_dots_element.dart
//
// Purpose:
// Decorative indicator dots element.

class MBDesignIndicatorDotsElement extends StatelessWidget {
  const MBDesignIndicatorDotsElement({
    super.key,
    this.element,
    this.count = 3,
  });

  final MBCardElementConfig? element;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (!(element?.visible ?? true)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(count, (index) {
        return Container(
          width: index == 0 ? 14 : 5,
          height: 5,
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 4),
          decoration: BoxDecoration(
            color: index == 0
                ? MBDesignCardDefaults.orange
                : MBDesignCardDefaults.orange.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
