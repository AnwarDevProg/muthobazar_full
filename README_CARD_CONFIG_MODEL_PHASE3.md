# MuthoBazar Card Config Model Phase 3

This phase wires the expanded card config model into the live compact01 design workflow.

Files included:
- packages/shared_models/lib/product_cards/config/product_card_config.dart
- packages/shared_models/lib/product_cards/config/mb_card_render_defaults.dart
- packages/shared_ui/lib/widgets/common/product_cards/system/mb_card_config_resolver.dart
- packages/shared_ui/lib/widgets/common/product_cards/variants/mb_product_card_compact01.dart
- apps/customer_app/lib/features/chat/pages/chat_page.dart

What changed:
- MBCardRenderDefaults now supports the expanded optional groups.
- MBResolvedCardConfig now exposes layout/background/stock/delivery/rating/quantity/timer/progress/indicator/ribbon/animation.
- compact01 reads current manual values from config where possible:
  - resolved.layout.aspectRatio
  - resolved.background diagonal values
  - resolved.typography title/price sizing values
  - resolved.media image size/top/ring values
  - resolved.price savingsDisplayMode
  - resolved.actions.ctaText and showBuyNow
- Customer ChatPage now exposes compact01 manual layout controls as cardConfig settings.

Install:
Extract this zip at repo root after Phase 1 and Phase 2 are already applied.
Then run:
flutter analyze
