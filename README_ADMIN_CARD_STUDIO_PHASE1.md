# Admin Product Card Studio Integration Phase 1

This patch integrates the new Card Studio into:

apps/admin_web/lib/features/products/widgets/admin_product_form_dialog.dart

It also installs:

apps/admin_web/lib/features/products/widgets/card_studio/admin_product_card_studio_dialog.dart

Run from repo root:

powershell -ExecutionPolicy Bypass -File .\tools\patch_admin_product_card_studio_phase1.ps1

Then:

flutter analyze

Expected product dialog behavior:
- Product dialog shows a clean Customer App Card Style section.
- Select card opens the new wide Card Studio in selection mode.
- Edit card opens the same Card Studio in configure mode.
- Right side preview stays open while selecting/configuring.
- Returned MBCardInstanceConfig is stored and used by final product save.
