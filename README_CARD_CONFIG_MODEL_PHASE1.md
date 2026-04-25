# MuthoBazar Card Config Model Phase 1

This pack expands the card config model to accept many optional setting groups.

Replace-ready files:
- packages/shared_models/lib/product_cards/config/mb_card_settings_override.dart
- packages/shared_models/lib/product_cards/config/product_card_config.dart

New group files:
- mb_card_layout_settings.dart
- mb_card_background_settings.dart
- mb_card_stock_settings.dart
- mb_card_delivery_settings.dart
- mb_card_rating_settings.dart
- mb_card_quantity_settings.dart
- mb_card_timer_settings.dart
- mb_card_progress_settings.dart
- mb_card_indicator_settings.dart
- mb_card_ribbon_settings.dart
- mb_card_animation_settings.dart

Important:
- This is the sparse model expansion step.
- Existing core groups are not replaced in this pack.
- Next phase should expand existing core groups like surface, typography, media, price, action, badge, borderEffect with more optional fields.
- Resolver/UI can keep working because the old fields remain available.
