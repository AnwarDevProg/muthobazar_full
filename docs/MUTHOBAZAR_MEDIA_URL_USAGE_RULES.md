# MuthoBazar Media URL Usage Rules

## Purpose

MuthoBazar product uploads generate multiple image versions. Each UI surface must use the smallest image that is still visually correct.

## Generated media versions

| Field | Purpose | Typical UI |
|---|---|---|
| `originalUrl` | Backup / future reprocess / zoom source | Do not use in normal lists |
| `fullUrl` | Product details / larger preview | Product details page |
| `cardUrl` | Product cards and grids | Home, category, search, product card widgets |
| `thumbUrl` | Small preview | Cart, order summary, admin lists |
| `tinyUrl` | Very small preview | chips, compact admin rows, tiny history rows |

## General fallback rule

Never read only one field directly. Always use fallback order.

### Product card / grid

```dart
product.resolvedCardImageUrl
```

Fallback order inside model:

```text
primary media cardUrl
→ media fullUrl
→ media thumbUrl
→ legacy imageUrls.first
→ legacy thumbnailUrl
```

### Product details

```dart
product.resolvedFullImageUrl
```

Fallback order:

```text
primary media fullUrl
→ media original/card/thumb fallback
→ legacy imageUrls.first
→ legacy thumbnailUrl
```

### Admin list / cart / order list

```dart
product.resolvedThumbImageUrl
```

Fallback order:

```text
primary media thumbUrl
→ media card/full fallback
→ legacy thumbnailUrl
→ legacy imageUrls.first
```

### Tiny/compact row

```dart
product.resolvedTinyImageUrl
```

Fallback order:

```text
tinyUrl
→ thumbUrl
→ cardUrl
→ fullUrl
→ legacy fallback
```

## Future cart rule

When building a cart item snapshot, do not store only `product.thumbnailUrl`.

Recommended snapshot fields:

```dart
imageThumbUrl: selectedVariation?.effectiveThumbImageUrl.isNotEmpty == true
    ? selectedVariation!.effectiveThumbImageUrl
    : product.resolvedThumbImageUrl,
imageFullUrl: selectedVariation?.effectiveFullImageUrl.isNotEmpty == true
    ? selectedVariation!.effectiveFullImageUrl
    : product.resolvedFullImageUrl,
```

Cart UI should display:

```dart
cartItem.imageThumbUrl
```

Never use `originalUrl` in cart.

## Future order rule

Order item images should be immutable snapshots from checkout time.

Recommended fields:

```dart
imageThumbUrl
imageFullUrl
imageCardUrl
```

Order summary / invoice / history rows should use:

```dart
orderItem.imageThumbUrl
```

Order details may use:

```dart
orderItem.imageFullUrl
```

Never depend on live product media for old orders. Products may be edited or deleted later, but order history should remain visually stable.

## Storage cleanup rule

Whenever permanently deleting product media, delete all storage paths:

```text
storagePath
originalStoragePath
fullStoragePath
cardStoragePath
thumbStoragePath
tinyStoragePath
```

For variation-level image fields, delete:

```text
imageStoragePath
originalImageStoragePath
fullImageStoragePath
thumbImageStoragePath
```

## UI fit rule

- Product card widgets may use `BoxFit.cover` with `resolvedCardImageUrl` because card image is already generated for card use.
- Product details should prefer `BoxFit.contain` with `resolvedFullImageUrl` so the product is not visually cut.
- Admin/cart/order small previews should prefer `BoxFit.contain` to avoid hiding product parts.
