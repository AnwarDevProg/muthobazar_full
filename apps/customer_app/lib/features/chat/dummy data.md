# Phase 1 — Product Card Preview Lab

## Goal

Create one centralized product-card system, isolated shared dummy product data, and a temporary customer-app preview lab on the Chat page.

## Repo decisions for Phase 1

### 1) Single source of truth for product cards

Keep all active card implementations inside:

* `packages/shared_ui/lib/widgets/common/product_cards/`

Use these as the product-card center:

* `mb_product_card_renderer.dart`
* `mb_product_card_standard.dart`
* `mb_product_card_compact.dart`
* `mb_product_card_deal.dart`
* `mb_product_card_featured.dart`

Keep `packages/shared_ui/lib/widgets/common/mb_product_card.dart` only as a thin compatibility wrapper.

### 2) Keep dummy data isolated

Do **not** mix preview fixtures into production repositories or model files.

Create a temporary preview-only area under customer app:

* `apps/customer_app/lib/features/chat/data/product_card_preview_dummy_data.dart`
* `apps/customer_app/lib/features/chat/models/product_card_preview_option.dart`
* `apps/customer_app/lib/features/chat/widgets/product_card_preview_toolbar.dart`
* `apps/customer_app/lib/features/chat/widgets/product_card_preview_section.dart`

### 3) Use the real shared product model

Do not create a fake product model.
Use `MBProduct` with realistic mock values.

### 4) Preview all card styles in one page

Temporarily convert Chat page into a product-card preview lab.

Controls:

* Category dropdown
* Product dropdown
* Optional card family filter later

Preview area:

* Selected product shown in all available card styles
* Vertical preview list for now
* Easy to extend later for grid / horizontal contexts

---

## Phase 1 exact file actions

## A. Shared models

### 1. Update

`packages/shared_models/lib/catalog/mb_product_card_layout.dart`

#### Purpose

Expand from current small enum set into a scalable layout registry for preview work.

#### Phase 1 target

Add enough layout IDs to support upcoming card rollout, even if not all widgets are built yet.

Suggested initial set:

* standard
* compact
* deal
* featured
* card01
* card02
* card03
* card04
* card05
* card06
* card07
* card08
* card09
* card10
* card11
* card12
* card13
* card14
* card15
* card16
* card17
* card18
* card19
* card20

Also keep helper methods:

* `value`
* `label`
* `isGridSafe`
* `isHorizontalSafe`
* `parse`
* `normalize`
* `isValid`
* `allowedValues`

---

## B. Shared UI — centralized product card system

### 2. Update

`packages/shared_ui/lib/widgets/common/product_cards/mb_product_card_renderer.dart`

#### Purpose

Make renderer the single routing point for all card types.

#### Phase 1 target

* Read `product.cardLayoutType`
* Route to current built styles
* Fallback safely to standard
* Prepare clean structure for adding styles 05–20 later

### 3. Update

`packages/shared_ui/lib/widgets/common/mb_product_card.dart`

#### Purpose

Turn old entry widget into compatibility wrapper only.

#### Phase 1 target

Internally delegate to renderer.
No independent product-card design logic should remain here.

### 4. Optional small export cleanup

`packages/shared_ui/lib/shared_ui.dart`

#### Purpose

Ensure renderer, wrapper, and future preview helpers export cleanly if needed.

---

## C. Customer app — temporary preview lab

### 5. Create

`apps/customer_app/lib/features/chat/data/product_card_preview_dummy_data.dart`

#### Purpose

Hold isolated preview-only dummy catalog.

#### Data scope

* 6 categories
* 10 products each
* total 60 products
* mixed prices, discount states, stock labels, badges
* some products with 4 images
* use online image URLs for now

Suggested categories:

* Grocery
* Fruits & Vegetables
* Personal Care
* Electronics
* Home & Kitchen
* Baby & Kids

### 6. Create

`apps/customer_app/lib/features/chat/models/product_card_preview_option.dart`

#### Purpose

Simple UI helper model for preview selection.

### 7. Create

`apps/customer_app/lib/features/chat/widgets/product_card_preview_toolbar.dart`

#### Purpose

Category and product dropdown selectors.

### 8. Create

`apps/customer_app/lib/features/chat/widgets/product_card_preview_section.dart`

#### Purpose

Render one selected product through all card styles.

Suggested output block pattern:

* Section title
* Card style label
* Rendered product card

### 9. Update

`apps/customer_app/lib/features/chat/pages/chat_page.dart`

#### Purpose

Temporary Product Card Preview Lab.

#### Phase 1 target UI

* Page title: Product Card Preview Lab
* Category dropdown
* Product dropdown
* Preview list showing selected product in all current card styles
* Responsive spacing using shared design tokens

---

## D. Dummy data rules

For each dummy product try to vary:

* name length
* price length
* discount presence
* thumbnail composition
* image count
* stock / badge status
* simple vs variable product

At least some products should include:

* `thumbnailUrl`
* `imageUrls`
* `mediaItems`
* `cardLayoutType`
* category data
* brand data where available
* short/long titles

Keep all dummy fixtures clearly marked as preview-only.

---

## Phase 1 delivery order

### Step 1

Update `mb_product_card_layout.dart`

### Step 2

Update `mb_product_card_renderer.dart`

### Step 3

Update `mb_product_card.dart`

### Step 4

Create preview dummy-data file

### Step 5

Create preview widgets

### Step 6

Replace Chat page with preview lab

---

## Notes

* This phase does **not** write to Firestore.
* This phase does **not** modify admin create/edit yet.
* This phase is only for centralization + preview lab + isolated dummy product dataset.
* Later we can delete the preview dataset cleanly without touching product model or repositories.
