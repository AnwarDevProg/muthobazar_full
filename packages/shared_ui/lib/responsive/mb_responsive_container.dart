import 'package:flutter/material.dart';
import 'mb_breakpoints.dart';
import 'mb_responsive.dart';
import 'mb_spacing.dart';

class MBResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Alignment alignment;
  final bool useSafeArea;
  final bool topSafe;
  final bool bottomSafe;
  final Color? backgroundColor;

  const MBResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.useSafeArea = false,
    this.topSafe = true,
    this.bottomSafe = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? MBBreakpoints.contentMaxWidth(context.mbWidth),
        ),
        child: Padding(
          padding: padding ?? MBSpacing.pagePadding(context),
          child: child,
        ),
      ),
    );

    if (useSafeArea) {
      content = SafeArea(
        top: topSafe,
        bottom: bottomSafe,
        child: content,
      );
    }

    if (backgroundColor != null) {
      content = ColoredBox(
        color: backgroundColor!,
        child: content,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: content,
    );
  }
}

extension MBResponsiveContainerX on Widget {
  Widget mbResponsive({
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    Alignment alignment = Alignment.topCenter,
    bool useSafeArea = false,
    bool topSafe = true,
    bool bottomSafe = true,
    Color? backgroundColor,
  }) {
    return MBResponsiveContainer(
      padding: padding,
      maxWidth: maxWidth,
      alignment: alignment,
      useSafeArea: useSafeArea,
      topSafe: topSafe,
      bottomSafe: bottomSafe,
      backgroundColor: backgroundColor,
      child: this,
    );
  }
}