import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import 'mb_home_gap_filler_models.dart';

// MB Home Gap Filler Widget
// -------------------------
// Renders the selected adaptive filler inside the exact available gap height.

class MBHomeGapFillerWidget extends StatelessWidget {
  const MBHomeGapFillerWidget({
    super.key,
    required this.decision,
  });

  final MBHomeGapFillerDecision decision;

  @override
  Widget build(BuildContext context) {
    final height = decision.renderHeight;
    final definition = decision.definition;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: MBSpacing.xs),
        child: _buildContent(context, definition, height),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MBHomeGapFillerDefinition definition,
    double height,
  ) {
    switch (definition.kind) {
      case MBHomeGapFillerKind.decorativeLine:
        return _DecorativeLine(height: height);
      case MBHomeGapFillerKind.decorativeGradient:
        return _DecorativeGradient(height: height);
      case MBHomeGapFillerKind.deliveryChip:
        return _InfoChip(
          height: height,
          icon: Icons.local_shipping_outlined,
          label: definition.label,
          subtitle: definition.subtitle,
          compact: height < 54,
        );
      case MBHomeGapFillerKind.offerChip:
        return _InfoChip(
          height: height,
          icon: Icons.local_offer_outlined,
          label: definition.label,
          subtitle: definition.subtitle,
          compact: height < 66,
        );
      case MBHomeGapFillerKind.categoryChip:
        return _InfoChip(
          height: height,
          icon: Icons.eco_outlined,
          label: definition.label,
          subtitle: definition.subtitle,
          compact: height < 88,
        );
      case MBHomeGapFillerKind.promoBlock:
        return _PromoBlock(
          height: height,
          label: definition.label,
          subtitle: definition.subtitle,
        );
    }
  }
}

class _DecorativeLine extends StatelessWidget {
  const _DecorativeLine({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: height.clamp(4, 10).toDouble(),
        decoration: BoxDecoration(
          color: MBColors.primaryOrange.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(MBRadius.pill),
        ),
      ),
    );
  }
}

class _DecorativeGradient extends StatelessWidget {
  const _DecorativeGradient({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.circular(MBRadius.md),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(MBRadius.md),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.height,
    required this.icon,
    required this.label,
    this.subtitle,
    this.compact = false,
  });

  final double height;
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 15.0 : 18.0;
    final labelSize = compact ? 10.5 : 11.5;
    final subtitleSize = compact ? 9.0 : 10.0;

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.md),
        border: Border.all(
          color: MBColors.primaryOrange.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 24 : 28,
            height: compact ? 24 : 28,
            decoration: BoxDecoration(
              color: MBColors.primaryOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MBRadius.sm),
            ),
            child: Icon(
              icon,
              color: MBColors.primaryOrange,
              size: iconSize,
            ),
          ),
          SizedBox(width: compact ? 5 : 7),
          Expanded(
            child: _ChipText(
              label: label,
              subtitle: subtitle,
              labelSize: labelSize,
              subtitleSize: subtitleSize,
              showSubtitle: height >= 50 && subtitle != null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBlock extends StatelessWidget {
  const _PromoBlock({
    required this.height,
    required this.label,
    this.subtitle,
  });

  final double height;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isLarge = height >= 135;

    return Container(
      height: height,
      padding: EdgeInsets.all(isLarge ? 11 : 9),
      decoration: BoxDecoration(
        gradient: MBGradients.headerGradient,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.primaryOrange.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              Icons.local_offer_rounded,
              size: isLarge ? 70 : 48,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isLarge ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: Colors.white,
                size: isLarge ? 20 : 17,
              ),
              SizedBox(height: isLarge ? 7 : 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MBAppText.caption(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isLarge ? 12.5 : 11.5,
                ),
              ),
              if (subtitle != null && height >= 118) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: isLarge ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.caption(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: isLarge ? 10.5 : 9.5,
                    height: 1.15,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  const _ChipText({
    required this.label,
    required this.labelSize,
    required this.subtitleSize,
    required this.showSubtitle,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final double labelSize;
  final double subtitleSize;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: MBAppText.caption(context).copyWith(
            color: MBColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: labelSize,
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MBAppText.caption(context).copyWith(
              color: MBColors.textMuted,
              fontSize: subtitleSize,
            ),
          ),
        ],
      ],
    );
  }
}
