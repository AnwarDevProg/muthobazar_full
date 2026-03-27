import 'package:flutter/material.dart';
import '../responsive/mb_responsive_container.dart';
import '../responsive/mb_spacing.dart';

class MBAppLayout extends StatelessWidget {
  final Widget child;

  // Optional sections
  final Widget? header;
  final Widget? footer;

  // Layout modes
  final bool scrollable;
  final bool sliverMode;
  final bool pinnedHeader;

  // Refresh
  final Future<void> Function()? onRefresh;

  // States
  final bool isLoading;
  final bool isEmpty;
  final bool hasError;

  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  // Background
  final Gradient? topGradient;
  final Color? backgroundColor;

  // Safe area
  final bool safeTop;
  final bool safeBottom;

  // Width / padding
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  // Scaffold features
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const MBAppLayout({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.scrollable = true,
    this.sliverMode = false,
    this.pinnedHeader = false,
    this.onRefresh,
    this.isLoading = false,
    this.isEmpty = false,
    this.hasError = false,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.topGradient,
    this.backgroundColor,
    this.safeTop = true,
    this.safeBottom = true,
    this.padding,
    this.maxWidth,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = _buildStateAwareContent(context);

    if (topGradient != null) {
      content = Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: topGradient,
              ),
            ),
          ),
          content,
        ],
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: content,
      ),
    );
  }

  Widget _buildStateAwareContent(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (hasError) {
      return errorWidget ??
          const Center(
            child: Text('Something went wrong'),
          );
    }

    if (isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text('No data available'),
          );
    }

    return _buildLayout(context);
  }

  Widget _buildLayout(BuildContext context) {
    if (sliverMode) {
      return _buildSliverLayout(context);
    }

    return _buildStandardLayout(context);
  }

  Widget _buildStandardLayout(BuildContext context) {
    final resolvedPadding = padding ?? MBSpacing.pagePadding(context);

    final contentColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        if (header != null) MBSpacing.h(MBSpacing.blockGap(context)),
        Padding(
          padding: resolvedPadding,
          child: child,
        ),
        if (footer != null) footer!,
      ],
    );

    Widget body;

    if (scrollable) {
      body = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: contentColumn,
      );
    } else {
      body = MBResponsiveContainer(
        padding: EdgeInsets.zero,
        maxWidth: maxWidth,
        child: contentColumn,
      );
    }

    if (scrollable) {
      body = MBResponsiveContainer(
        padding: EdgeInsets.zero,
        maxWidth: maxWidth,
        child: body,
      );
    }

    if (onRefresh != null) {
      body = RefreshIndicator(
        onRefresh: onRefresh!,
        child: body,
      );
    }

    return body;
  }

  Widget _buildSliverLayout(BuildContext context) {
    final resolvedPadding = padding ?? MBSpacing.pagePadding(context);

    final List<Widget> slivers = [];

    if (header != null) {
      slivers.add(
        SliverToBoxAdapter(
          child: header,
        ),
      );

      slivers.add(
        SliverToBoxAdapter(
          child: MBSpacing.h(MBSpacing.blockGap(context)),
        ),
      );
    }

    slivers.add(
      SliverPadding(
        padding: resolvedPadding,
        sliver: SliverToBoxAdapter(
          child: child,
        ),
      ),
    );

    if (footer != null) {
      slivers.add(
        SliverToBoxAdapter(
          child: footer,
        ),
      );
    }

    Widget scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );

    if (onRefresh != null) {
      scrollView = RefreshIndicator(
        onRefresh: onRefresh!,
        child: scrollView,
      );
    }

    return MBResponsiveContainer(
      padding: EdgeInsets.zero,
      maxWidth: maxWidth,
      child: scrollView,
    );
  }
}











