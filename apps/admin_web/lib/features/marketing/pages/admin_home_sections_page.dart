import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminHomeSectionsPage extends StatelessWidget {
  const AdminHomeSectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MBSpacing.lg),
      children: [
        _HomeSectionsHeader(
          onAddPressed: () => showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const _StaticHomeSectionDialog(),
          ),
        ),
        MBSpacing.h(MBSpacing.lg),
        const _PhaseInfoCard(),
        MBSpacing.h(MBSpacing.lg),
        const _EmptyHomeSectionsState(),
      ],
    );
  }
}

class _HomeSectionsHeader extends StatelessWidget {
  const _HomeSectionsHeader({
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home Sections',
                      style: MBTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.xxs),
                    Text(
                      'Static phase only. Page and dialog are now isolated from controller and repository logic.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Section'),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          Wrap(
            spacing: MBSpacing.sm,
            runSpacing: MBSpacing.sm,
            children: const [
              _SummaryChip(label: 'Total', value: '0'),
              _SummaryChip(label: 'Active', value: '0'),
              _SummaryChip(label: 'Inactive', value: '0'),
              _SummaryChip(label: 'Manual', value: '0'),
              _SummaryChip(label: 'Dynamic', value: '0'),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          Wrap(
            spacing: MBSpacing.md,
            runSpacing: MBSpacing.md,
            children: const [
              _DisabledSearchField(),
              _DisabledDropdownField(
                width: 180,
                label: 'Status',
                value: 'All',
              ),
              _DisabledDropdownField(
                width: 220,
                label: 'Section Type',
                value: 'All',
              ),
              _DisabledDropdownField(
                width: 220,
                label: 'Data Source',
                value: 'All',
              ),
              _DisabledDropdownField(
                width: 180,
                label: 'Layout',
                value: 'All',
              ),
              _DisabledResetButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseInfoCard extends StatelessWidget {
  const _PhaseInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Phase',
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xs),
          Text(
            'Step 1: Static page and static dialog only.\n'
                'Next: repository CRUD one by one.\n'
                'Controller will be added later in a controlled way.',
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.md,
        vertical: MBSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.pill),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: MBTextStyles.caption.copyWith(
            color: MBColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledSearchField extends StatelessWidget {
  const _DisabledSearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: TextField(
        enabled: false,
        decoration: const InputDecoration(
          hintText: 'Search sections, titles, ids, source ids...',
          prefixIcon: Icon(Icons.search_rounded),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _DisabledDropdownField extends StatelessWidget {
  const _DisabledDropdownField({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _DisabledResetButton extends StatelessWidget {
  const _DisabledResetButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: null,
      child: const Text('Reset'),
    );
  }
}

class _EmptyHomeSectionsState extends StatelessWidget {
  const _EmptyHomeSectionsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(MBSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.view_quilt_outlined,
              size: 44,
              color: MBColors.primaryOrange,
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'No Home Sections Found',
              style: MBTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xs),
            Text(
              'Static phase is ready. Next step is repository-based loading and CRUD.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticHomeSectionDialog extends StatelessWidget {
  const _StaticHomeSectionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(MBSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.xl),
      ),
      child: Container(
        width: 920,
        constraints: const BoxConstraints(maxHeight: 820),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: MBColors.border.withValues(alpha: 0.85),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Home Section',
                          style: MBTextStyles.sectionTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        MBSpacing.h(MBSpacing.xxs),
                        Text(
                          'Static dialog only. No repository or controller submission yet.',
                          style: MBTextStyles.body.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MBSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DialogSectionCard(
                      title: 'Basic Information',
                      subtitle: 'Static preview fields for section titles.',
                      child: _StaticBasicFields(),
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    const _DialogSectionCard(
                      title: 'Layout',
                      subtitle: 'Static preview fields for section type and layout style.',
                      child: _StaticLayoutFields(),
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    const _DialogSectionCard(
                      title: 'Source Mapping',
                      subtitle: 'Static preview fields for ids and source setup.',
                      child: _StaticSourceFields(),
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    const _DialogSectionCard(
                      title: 'Settings',
                      subtitle: 'Static preview fields for item limit, sort order and visibility.',
                      child: _StaticSettingsFields(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MBSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: MBColors.border.withValues(alpha: 0.85),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  MBSpacing.w(MBSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Static OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogSectionCard extends StatelessWidget {
  const _DialogSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxs),
          Text(
            subtitle,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _StaticBasicFields extends StatelessWidget {
  const _StaticBasicFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _DisabledInputField(label: 'Title (English)'),
            ),
            SizedBox(width: MBSpacing.md),
            Expanded(
              child: _DisabledInputField(label: 'Title (Bangla)'),
            ),
          ],
        ),
        SizedBox(height: MBSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DisabledInputField(
                label: 'Subtitle (English)',
                maxLines: 3,
              ),
            ),
            SizedBox(width: MBSpacing.md),
            Expanded(
              child: _DisabledInputField(
                label: 'Subtitle (Bangla)',
                maxLines: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StaticLayoutFields extends StatelessWidget {
  const _StaticLayoutFields();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _DisabledInputField(label: 'Section Type', initialValue: 'product_grid'),
        ),
        SizedBox(width: MBSpacing.md),
        Expanded(
          child: _DisabledInputField(label: 'Layout Style', initialValue: 'standard'),
        ),
      ],
    );
  }
}

class _StaticSourceFields extends StatelessWidget {
  const _StaticSourceFields();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DisabledInputField(label: 'Data Source Type', initialValue: 'manual'),
            ),
            SizedBox(width: MBSpacing.md),
            Expanded(
              child: _DisabledInputField(label: 'Source Category ID'),
            ),
            SizedBox(width: MBSpacing.md),
            Expanded(
              child: _DisabledInputField(label: 'Source Brand ID'),
            ),
          ],
        ),
        SizedBox(height: MBSpacing.md),
        _DisabledInputField(
          label: 'Product / Banner / Offer / Category / Brand IDs',
          maxLines: 5,
        ),
      ],
    );
  }
}

class _StaticSettingsFields extends StatelessWidget {
  const _StaticSettingsFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _DisabledInputField(label: 'Item Limit', initialValue: '8'),
            ),
            SizedBox(width: MBSpacing.md),
            Expanded(
              child: _DisabledInputField(label: 'Sort Order', initialValue: '0'),
            ),
          ],
        ),
        SizedBox(height: MBSpacing.md),
        _StaticSwitchRow(label: 'Show View All', value: true),
        _StaticSwitchRow(label: 'Active', value: true),
      ],
    );
  }
}

class _DisabledInputField extends StatelessWidget {
  const _DisabledInputField({
    required this.label,
    this.initialValue = '',
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      enabled: false,
      minLines: maxLines > 1 ? maxLines : 1,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _StaticSwitchRow extends StatelessWidget {
  const _StaticSwitchRow({
    required this.label,
    required this.value,
  });

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: null,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: MBTextStyles.body,
      ),
    );
  }
}