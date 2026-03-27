import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Padding(
        padding: MBScreenPadding.page(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HelpHeaderCard(),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search help topics',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: MBColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MBRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            Text(
              'Quick help',
              style: MBAppText.headline3(context).copyWith(
                color: MBColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.blockGap(context)),
            ..._faqs.map(
                  (faq) => Padding(
                padding: EdgeInsets.only(
                  bottom: MBSpacing.itemGap(context),
                ),
                child: _FaqCard(faq: faq),
              ),
            ),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            const _ContactSupportCard(),
          ],
        ),
      ),
    );
  }
}

class _HelpHeaderCard extends StatelessWidget {
  const _HelpHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
      decoration: BoxDecoration(
        gradient: MBGradients.primaryGradient,
        borderRadius: BorderRadius.circular(MBRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: Colors.white,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: MBAppText.headline3(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Find answers, contact support, and get assistance for orders and payments.',
                  style: MBAppText.bodySmall(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
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

class _FaqCard extends StatelessWidget {
  final _FaqItem faq;

  const _FaqCard({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          faq.question,
          style: MBAppText.body(context).copyWith(
            color: MBColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                faq.answer,
                style: MBAppText.bodySmall(context).copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  const _ContactSupportCard();

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
            'Contact support',
            style: MBAppText.label(context).copyWith(
              color: MBColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.sm),
          _contactTile(
            context,
            icon: Icons.phone_outlined,
            title: 'Call support',
            subtitle: '+8801XXXXXXXXX',
          ),
          MBSpacing.h(MBSpacing.sm),
          _contactTile(
            context,
            icon: Icons.email_outlined,
            title: 'Email support',
            subtitle: 'support@muthobazar.com',
          ),
          MBSpacing.h(MBSpacing.sm),
          _contactTile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Live chat',
            subtitle: 'Start a quick support conversation',
          ),
        ],
      ),
    );
  }

  Widget _contactTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    return Row(
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
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}

const List<_FaqItem> _faqs = [
  _FaqItem(
    question: 'How can I track my order?',
    answer:
    'Go to My Orders and open the order details to see the latest delivery status and progress.',
  ),
  _FaqItem(
    question: 'How do I use a coupon?',
    answer:
    'At checkout, apply a valid coupon code before placing your order. Eligible discounts will be shown instantly.',
  ),
  _FaqItem(
    question: 'Can I change my delivery address after ordering?',
    answer:
    'You may contact support quickly after placing the order. Address changes depend on order processing status.',
  ),
];

