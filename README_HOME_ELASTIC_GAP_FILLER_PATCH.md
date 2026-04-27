# MuthoBazar Home Elastic Gap Filler Patch

## What this patch implements

1. Pair two half-width cards.
2. Calculate both preferred heights.
3. Check if a filler widget can fit the original gap first.
4. If a filler fits, keep product card heights unchanged.
5. If no filler fits, safely expand the shorter card and/or shrink the taller card.
6. Recalculate remaining gap.
7. Try filler again.
8. Tiny remaining gaps are decorative/absorbed spacing.
9. Full-width cards render only after completed half-width rows.

## New files

apps/customer_app/lib/features/home/widgets/sections/gap_fillers/
  mb_home_card_layout_profile.dart
  mb_home_gap_filler_models.dart
  mb_home_gap_filler_resolver.dart
  mb_home_gap_filler_widget.dart

## Modified file

apps/customer_app/lib/features/home/widgets/sections/mb_home_product_grid_section.dart

## Manual adjustment values

Card height profiles:
apps/customer_app/lib/features/home/widgets/sections/gap_fillers/mb_home_card_layout_profile.dart

Filler definitions:
apps/customer_app/lib/features/home/widgets/sections/gap_fillers/mb_home_gap_filler_resolver.dart

Elastic tuning:
apps/customer_app/lib/features/home/widgets/sections/mb_home_product_grid_section.dart

- `adjustmentNeeded * 65`
  Higher = less likely to resize cards.
  Lower = more likely to resize cards.

- `remaining * 0.62`
  Higher = prefer expanding shorter card.
  Lower = prefer shrinking taller card more.

## Apply

Extract ZIP into repo root:

C:\Users\1\AndroidStudioProjects\MuthoBazar

Run:

powershell -ExecutionPolicy Bypass -File .\tools\patch_home_elastic_gap_filler.ps1
flutter analyze

Then full restart customer app and pull-refresh Home.
