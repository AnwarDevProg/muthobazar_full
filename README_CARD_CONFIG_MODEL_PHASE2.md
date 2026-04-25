# MuthoBazar Card Config Model Phase 2

This pack upgrades the existing core setting groups so they can hold more optional parameters for future card variants.

Replaced shared_models config files:
- mb_card_surface_settings.dart
- mb_card_typography_settings.dart
- mb_card_media_settings.dart
- mb_card_price_settings.dart
- mb_card_action_settings.dart
- mb_card_badge_settings.dart
- mb_card_border_effect_settings.dart
- mb_card_accent_settings.dart
- mb_card_meta_settings.dart

Replaced shared_ui resolver:
- packages/shared_ui/lib/widgets/common/product_cards/system/mb_card_config_resolver.dart

Important:
- Existing fields are preserved.
- New fields are added with safe defaults.
- Existing compact01 and ChatPage should still compile.
- Resolver merge now copies the new core fields.
- Phase 1 group files are still required for the large sparse model.
