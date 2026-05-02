import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../mb_design_card_default_configs.dart';
import '../mb_design_card_renderer.dart';
import 'mb_design_card_mobile_preview_frame.dart';

// MuthoBazar Design Card Engine V1
// Reusable preview panel:
// real MBProduct + MBCardDesignConfig -> MBDesignCardRenderer.
//
// No old cardConfig fallback.

class MBDesignCardPreviewPanel extends StatelessWidget {
  const MBDesignCardPreviewPanel({
    super.key,
    required this.product,
    this.config,
    this.onProductTap,
    this.onPrimaryCtaTap,
    this.onSecondaryCtaTap,
    this.frameWidth = 390,
    this.frameHeight = 760,
    this.cardWidth = 190,
    this.title = 'Card preview',
    this.subtitle,
    this.showMobileFrame = true,
  });

  final MBProduct product;
  final MBCardDesignConfig? config;

  final VoidCallback? onProductTap;
  final VoidCallback? onPrimaryCtaTap;
  final VoidCallback? onSecondaryCtaTap;

  final double frameWidth;
  final double frameHeight;
  final double cardWidth;

  final String title;
  final String? subtitle;
  final bool showMobileFrame;

  @override
  Widget build(BuildContext context) {
    final effectiveConfig =
        config ?? MBDesignCardDefaultConfigs.heroPosterCircleDiagonalV1();

    final previewContent = Center(
      child: SizedBox(
        width: cardWidth,
        child: MBDesignCardRenderer(
          product: product,
          config: effectiveConfig,
          onTap: onProductTap,
          onPrimaryCtaTap: onPrimaryCtaTap,
          onSecondaryCtaTap: onSecondaryCtaTap,
        ),
      ),
    );

    if (!showMobileFrame) {
      return previewContent;
    }

    return MBDesignCardMobilePreviewFrame(
      width: frameWidth,
      height: frameHeight,
      title: title,
      subtitle: subtitle ?? effectiveConfig.templateId,
      child: previewContent,
    );
  }
}
