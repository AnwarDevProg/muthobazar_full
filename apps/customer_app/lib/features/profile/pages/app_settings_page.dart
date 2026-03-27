import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool orderNotifications = true;
  bool promoNotifications = true;
  bool smsAlerts = false;
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          'App Settings',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Padding(
        padding: MBScreenPadding.page(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SettingsHeaderCard(),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: language,
                  trailing: DropdownButton<String>(
                    value: language,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Bangla',
                        child: Text('Bangla'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        language = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.blockGap(context)),
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SwitchTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Order updates',
                  value: orderNotifications,
                  onChanged: (value) {
                    setState(() {
                      orderNotifications = value;
                    });
                  },
                ),
                const _SettingsDivider(),
                _SwitchTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions and offers',
                  value: promoNotifications,
                  onChanged: (value) {
                    setState(() {
                      promoNotifications = value;
                    });
                  },
                ),
                const _SettingsDivider(),
                _SwitchTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS alerts',
                  value: smsAlerts,
                  onChanged: (value) {
                    setState(() {
                      smsAlerts = value;
                    });
                  },
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.blockGap(context)),
            const _SettingsSection(
              title: 'Privacy and Security',
              children: [
                _SimpleTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy policy',
                  subtitle: 'Read how your data is handled',
                ),
                _SettingsDivider(),
                _SimpleTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Account security',
                  subtitle: 'Phone verification and account safety',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeaderCard extends StatelessWidget {
  const _SettingsHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: MBColors.primaryOrange,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize your experience',
                  style: MBAppText.label(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Control notifications, language, and account preferences.',
                  style: MBAppText.bodySmall(context).copyWith(
                    color: MBColors.textSecondary,
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBAppText.label(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MBColors.primaryOrange),
        MBSpacing.w(MBSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MBAppText.body(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                subtitle,
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MBColors.primaryOrange),
        MBSpacing.w(MBSpacing.md),
        Expanded(
          child: Text(
            title,
            style: MBAppText.body(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MBColors.primaryOrange),
        MBSpacing.w(MBSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MBAppText.body(context).copyWith(
                  color: MBColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                subtitle,
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: MBColors.textMuted,
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 20,
      color: MBColors.divider.withValues(alpha: 0.90),
    );
  }
}

