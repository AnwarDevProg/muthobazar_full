import 'package:admin_web/app/shell/admin_web_shell.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminFeaturePlaceholderPage extends StatelessWidget {
  const AdminFeaturePlaceholderPage({
    super.key,
    required this.title,
    this.description,
    this.statusLabel = 'Coming Soon',
    this.icon = Icons.construction_rounded,
  });

  final String title;
  final String? description;
  final String statusLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AdminWebShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlaceholderPageHeader(title: title),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(MBSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        title: title,
                        description: description ??
                            '$title module is registered, routed, protected, and ready for implementation.',
                        statusLabel: statusLabel,
                        icon: icon,
                      ),
                      MBSpacing.h(MBSpacing.xl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isWide = constraints.maxWidth >= 980;

                          if (!isWide) {
                            return Column(
                              children: [
                                _InfoCard(
                                  title: 'Current Status',
                                  icon: Icons.info_outline_rounded,
                                  child: const _StatusList(),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _InfoCard(
                                  title: 'What Is Ready',
                                  icon: Icons.check_circle_outline_rounded,
                                  child: _ReadyList(title: title),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _InfoCard(
                                  title: 'Suggested Next Steps',
                                  icon: Icons.arrow_forward_rounded,
                                  child: _NextStepsList(title: title),
                                ),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  title: 'Current Status',
                                  icon: Icons.info_outline_rounded,
                                  child: const _StatusList(),
                                ),
                              ),
                              MBSpacing.w(MBSpacing.lg),
                              Expanded(
                                child: _InfoCard(
                                  title: 'What Is Ready',
                                  icon: Icons.check_circle_outline_rounded,
                                  child: _ReadyList(title: title),
                                ),
                              ),
                              MBSpacing.w(MBSpacing.lg),
                              Expanded(
                                child: _InfoCard(
                                  title: 'Suggested Next Steps',
                                  icon: Icons.arrow_forward_rounded,
                                  child: _NextStepsList(title: title),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      MBSpacing.h(MBSpacing.xl),
                      _ImplementationNoteCard(title: title),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPageHeader extends StatelessWidget {
  const _PlaceholderPageHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: MBTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Admin Panel / $title',
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.icon,
  });

  final String title;
  final String description;
  final String statusLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.xl),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
          MBSpacing.w(MBSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MBTextStyles.pageTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  description,
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.45,
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                Wrap(
                  spacing: MBSpacing.sm,
                  runSpacing: MBSpacing.sm,
                  children: [
                    _HeroBadge(
                      label: statusLabel,
                    ),
                    const _HeroBadge(
                      label: 'Route Ready',
                    ),
                    const _HeroBadge(
                      label: 'Binding Ready',
                    ),
                    const _HeroBadge(
                      label: 'Permission Guard Ready',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: MBTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: MBColors.primaryOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(MBRadius.md),
                ),
                child: Icon(
                  icon,
                  color: MBColors.primaryOrange,
                  size: 20,
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _StatusList extends StatelessWidget {
  const _StatusList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FeatureRow(
          label: 'Page registered',
          value: 'Yes',
          isPositive: true,
        ),
        _FeatureRow(
          label: 'GetPage connected',
          value: 'Yes',
          isPositive: true,
        ),
        _FeatureRow(
          label: 'Binding attached',
          value: 'Yes',
          isPositive: true,
        ),
        _FeatureRow(
          label: 'Permission guard attached',
          value: 'Yes',
          isPositive: true,
        ),
        _FeatureRow(
          label: 'Business logic implemented',
          value: 'Not yet',
          isPositive: false,
          isLast: true,
        ),
      ],
    );
  }
}

class _ReadyList extends StatelessWidget {
  const _ReadyList({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BulletLine(text: '$title route is active in the admin app.'),
        _BulletLine(text: 'Sidebar navigation is already connected.'),
        _BulletLine(text: 'Topbar title and breadcrumbs work automatically.'),
        _BulletLine(text: 'Permission gate can protect unauthorized access.'),
        _BulletLine(text: 'This page can now be upgraded module-by-module.'),
      ],
    );
  }
}

class _NextStepsList extends StatelessWidget {
  const _NextStepsList({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BulletLine(text: 'Create $title controller.'),
        _BulletLine(text: 'Create repository and data source methods.'),
        _BulletLine(text: 'Design list page and details flow.'),
        _BulletLine(text: 'Add create/edit dialogs if needed.'),
        _BulletLine(text: 'Connect activity log write actions.'),
      ],
    );
  }
}

class _ImplementationNoteCard extends StatelessWidget {
  const _ImplementationNoteCard({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MBColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: MBColors.warning,
              size: 24,
            ),
          ),
          MBSpacing.w(MBSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Implementation Note',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBColors.textPrimary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  'This placeholder keeps the route usable and visually consistent until the real $title feature is implemented. It prevents broken navigation and lets you build each module one by one.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.value,
    required this.isPositive,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isPositive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: MBSpacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: (isPositive ? MBColors.success : MBColors.warning)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.pill),
            ),
            child: Text(
              value,
              style: MBTextStyles.caption.copyWith(
                color: isPositive ? MBColors.success : MBColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: MBColors.primaryOrange,
              shape: BoxShape.circle,
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}