import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";

import {
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
  requireObjectRecord,
} from "../utils/callable-parsers";

const db = admin.firestore();

type JsonMap = Record<string, unknown>;

type CreateProductRequest = {
  product?: JsonMap;
  reason?: string | null;
};

type CreateProductResponse = {
  success: true;
  productId: string;
  auditLogId: string;
};

function sanitizeFirestoreValue(value: unknown): unknown {
  if (value === undefined) return undefined;

  if (
    value === null ||
    typeof value === "string" ||
    typeof value === "number" ||
    typeof value === "boolean"
  ) {
    return value;
  }

  if (
    value instanceof Date ||
    value instanceof admin.firestore.Timestamp ||
    value instanceof admin.firestore.GeoPoint ||
    value instanceof admin.firestore.DocumentReference ||
    value instanceof admin.firestore.FieldValue
  ) {
    return value;
  }

  if (Array.isArray(value)) {
    return value
      .map((item) => sanitizeFirestoreValue(item))
      .filter((item) => item !== undefined);
  }

  if (typeof value === "object") {
    const input = value as JsonMap;
    const output: JsonMap = {};

    for (const [key, rawValue] of Object.entries(input)) {
      if (key.startsWith("clear")) continue;

      const sanitized = sanitizeFirestoreValue(rawValue);
      if (sanitized !== undefined) {
        output[key] = sanitized;
      }
    }

    return output;
  }

  return undefined;
}

function sanitizeProductInput(input: JsonMap): JsonMap {
  const sanitized = sanitizeFirestoreValue(input);
  if (!sanitized || typeof sanitized !== "object" || Array.isArray(sanitized)) {
    return {};
  }
  return sanitized as JsonMap;
}

function asBool(value: unknown, fallback = false): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function asNumber(value: unknown, fallback = 0): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function asStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => asTrimmedString(item))
    .filter((item) => item.length > 0);
}

function isJsonMap(value: unknown): value is JsonMap {
  return (
    !!value &&
    typeof value === "object" &&
    !Array.isArray(value)
  );
}

function isValidNewCardVariantId(value: string): boolean {
  return /^(compact|price|horizontal|premium|wide|featured|promo|flash)0[1-5]$/.test(
    value,
  );
}

function familyIdFromVariantId(variantId: string): string {
  if (variantId.startsWith("compact")) return "compact";
  if (variantId.startsWith("price")) return "price";
  if (variantId.startsWith("horizontal")) return "horizontal";
  if (variantId.startsWith("premium")) return "premium";
  if (variantId.startsWith("wide")) return "wide";
  if (variantId.startsWith("featured")) return "featured";
  if (variantId.startsWith("promo")) return "promo";
  if (variantId.startsWith("flash")) return "flash_sale";
  if (isValidAdvancedCardLayoutId(variantId)) return "advanced_v3";

  throw new HttpsError(
    "invalid-argument",
    `Invalid card variant id: ${variantId}`,
  );
}

function isValidAdvancedCardLayoutId(value: string): boolean {
  const advancedLayoutIds = new Set<string>([
    "advanced_v3",
    "hero_poster_circle",
    "hero_poster_circle_diagonal_v1",
    "orange_gradient_poster_v1",
    "advanced_orange_phone_card_v1",
  ]);

  return advancedLayoutIds.has(value);
}

function normalizeCardVariantId(value: unknown): string {
  const normalized = asTrimmedString(value).toLowerCase();

  if (normalized.length === 0) {
    return "compact01";
  }

  if (!isValidNewCardVariantId(normalized) && !isValidAdvancedCardLayoutId(normalized)) {
    throw new HttpsError(
      "invalid-argument",
      `Invalid card variant id: ${normalized}. Use legacy ids like compact01, horizontal03, wide02, promo05, or V3 ids like hero_poster_circle_diagonal_v1 when cardDesignJson is provided.`,
    );
  }

  return normalized;
}

function sanitizeCardSettings(value: unknown): JsonMap {
  if (!isJsonMap(value)) return {};

  const sanitized = sanitizeFirestoreValue(value);
  if (!isJsonMap(sanitized)) return {};

  return sanitized;
}

function normalizeCardConfig(
  value: unknown,
  fallbackLayoutType: unknown,
): JsonMap {
  const input = isJsonMap(value) ? value : {};

  const variantId = normalizeCardVariantId(
    input.variantId ?? fallbackLayoutType,
  );

  return {
    familyId: familyIdFromVariantId(variantId),
    variantId,
    presetId:
      asTrimmedString(input.presetId).length > 0
        ? asTrimmedString(input.presetId)
        : null,
    settings: sanitizeCardSettings(input.settings),
  };
}

function normalizeCardLayoutType(value: unknown): string {
  return normalizeCardVariantId(value);
}




function asNullableString(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length > 0 ? normalized : null;
}

function asNullableNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function asInteger(value: unknown, fallback = 0): number {
  return Math.trunc(asNumber(value, fallback));
}

function sanitizeJsonMap(value: unknown): JsonMap {
  const sanitized = sanitizeFirestoreValue(value);
  if (!isJsonMap(sanitized)) return {};
  return sanitized;
}

function normalizeObjectList(value: unknown): JsonMap[] {
  if (!Array.isArray(value)) return [];

  return value
    .map((item) => sanitizeFirestoreValue(item))
    .filter((item): item is JsonMap => isJsonMap(item));
}
function normalizeRootMediaItems(
  value: unknown,
  productType: unknown,
): JsonMap[] {
  const productTypeText = asTrimmedString(productType).toLowerCase();
  const isVariableProduct = productTypeText === "variable";

  return normalizeObjectList(value).map((item, index) => {
    const normalized: JsonMap = {
      ...item,
      sortOrder: asInteger(item.sortOrder, index),
    };

    if (isVariableProduct) {
      normalized.role = "gallery";
      normalized.isPrimary = false;
      return normalized;
    }

    const role = asTrimmedString(item.role);
    normalized.role = role.length > 0 ? role : index === 0 ? "thumbnail" : "gallery";
    normalized.isPrimary = asBool(item.isPrimary, index === 0);
    return normalized;
  });
}

function normalizePurchaseOptions(value: unknown): JsonMap[] {
  return normalizeObjectList(value);
}

function normalizeOptionalCardConfig(
  value: unknown,
  fallbackLayoutType: unknown,
): JsonMap | null {
  const rawLayoutType = asTrimmedString(fallbackLayoutType).toLowerCase();
  const hasConfig = isJsonMap(value);
  const hasLayout = rawLayoutType.length > 0;

  if (!hasConfig && !hasLayout) {
    return null;
  }

  return normalizeCardConfig(value, hasLayout ? rawLayoutType : "compact01");
}

function normalizeStatus(value: unknown, isEnabled: boolean): string {
  const normalized = asTrimmedString(value).toLowerCase();

  if (normalized.length > 0) {
    return normalized;
  }

  return isEnabled ? "active" : "inactive";
}

function nullableRawTimestamp(value: unknown): unknown {
  return value === undefined ? null : value;
}

function normalizeVariations(
  value: unknown,
  existingValue: unknown,
  actorUid: string,
  now: admin.firestore.Timestamp,
  rootData: JsonMap,
  reason?: string | null,
): JsonMap[] {
  const inputVariations = normalizeObjectList(value);
  const existingVariations = normalizeObjectList(existingValue);
  const existingById = new Map<string, JsonMap>();

  for (const item of existingVariations) {
    const id = asTrimmedString(item.id);
    if (id.length > 0) {
      existingById.set(id, item);
    }
  }

  return inputVariations.map((input, index) => {
    const requestedId = asTrimmedString(input.id);
    const existing =
      requestedId.length > 0 ? existingById.get(requestedId) ?? {} : {};
    const merged: JsonMap = {
      ...existing,
      ...input,
    };

    const id =
      requestedId.length > 0
        ? requestedId
        : asTrimmedString(existing.id).length > 0
          ? asTrimmedString(existing.id)
          : `variation_${index + 1}`;

    const isEnabled = asBool(merged.isEnabled, true);
    const wasDeleted = asBool(existing.isDeleted, false);
    const wantsDeleted = asBool(merged.isDeleted, false);

    let deletedAt = merged.deletedAt ?? null;
    let deletedBy = asNullableString(merged.deletedBy);
    let deleteReason = asNullableString(merged.deleteReason);

    if (!wasDeleted && wantsDeleted) {
      deletedAt = now;
      deletedBy = actorUid;
      deleteReason = deleteReason ?? reason ?? null;
    }

    if (wasDeleted && !wantsDeleted) {
      deletedAt = null;
      deletedBy = null;
      deleteReason = null;
    }

    const normalizedCardConfig = normalizeOptionalCardConfig(
      merged.cardConfig,
      merged.cardLayoutType,
    );

    return {
      ...merged,
      id,
      titleEn: asTrimmedString(merged.titleEn),
      titleBn: asTrimmedString(merged.titleBn),
      shortDescriptionEn: asTrimmedString(merged.shortDescriptionEn),
      shortDescriptionBn: asTrimmedString(merged.shortDescriptionBn),
      descriptionEn: asTrimmedString(merged.descriptionEn),
      descriptionBn: asTrimmedString(merged.descriptionBn),

      sku: asNullableString(merged.sku),
      barcode: asNullableString(merged.barcode),

      price: asNumber(merged.price, asNumber(rootData.price, 0)),
      salePrice: asNullableNumber(merged.salePrice),
      costPrice: asNullableNumber(merged.costPrice),
      saleStartsAt: nullableRawTimestamp(merged.saleStartsAt),
      saleEndsAt: nullableRawTimestamp(merged.saleEndsAt),

      stockQty: asInteger(merged.stockQty, 0),
      reservedQty: asInteger(merged.reservedQty, 0),
      reorderLevel: asInteger(merged.reorderLevel, 0),

      quantityType:
        asTrimmedString(merged.quantityType).length > 0
          ? asTrimmedString(merged.quantityType)
          : asTrimmedString(rootData.quantityType).length > 0
            ? asTrimmedString(rootData.quantityType)
            : "pcs",
      quantityValue: asNumber(merged.quantityValue, 0),
      unitLabelEn: asNullableString(merged.unitLabelEn),
      unitLabelBn: asNullableString(merged.unitLabelBn),
      toleranceType:
        asTrimmedString(merged.toleranceType).length > 0
          ? asTrimmedString(merged.toleranceType)
          : asTrimmedString(rootData.toleranceType).length > 0
            ? asTrimmedString(rootData.toleranceType)
            : "g",
      tolerance: asNumber(merged.tolerance, 0),
      isToleranceActive: asBool(merged.isToleranceActive, false),

      trackInventory: asBool(
        merged.trackInventory,
        asBool(rootData.trackInventory, true),
      ),
      supportsInstantOrder: asBool(
        merged.supportsInstantOrder,
        asBool(rootData.supportsInstantOrder, true),
      ),
      supportsScheduledOrder: asBool(
        merged.supportsScheduledOrder,
        asBool(rootData.supportsScheduledOrder, false),
      ),
      allowBackorder: asBool(
        merged.allowBackorder,
        asBool(rootData.allowBackorder, false),
      ),
      instantCutoffTime: asNullableString(merged.instantCutoffTime),
      todayInstantCap: asInteger(merged.todayInstantCap, 999999),
      todayInstantSold: asInteger(merged.todayInstantSold, 0),
      maxScheduleQtyPerDay: asInteger(merged.maxScheduleQtyPerDay, 999999),
      minScheduleNoticeHours: asInteger(merged.minScheduleNoticeHours, 0),
      schedulePriceType:
        asTrimmedString(merged.schedulePriceType).length > 0
          ? asTrimmedString(merged.schedulePriceType)
          : asTrimmedString(rootData.schedulePriceType).length > 0
            ? asTrimmedString(rootData.schedulePriceType)
            : "fixed",
      estimatedSchedulePrice: asNullableNumber(merged.estimatedSchedulePrice),
      purchaseOptions: normalizePurchaseOptions(merged.purchaseOptions),

      deliveryShift:
        asTrimmedString(merged.deliveryShift).length > 0
          ? asTrimmedString(merged.deliveryShift)
          : asTrimmedString(rootData.deliveryShift).length > 0
            ? asTrimmedString(rootData.deliveryShift)
            : "any",

      publishAt: nullableRawTimestamp(merged.publishAt),
      unpublishAt: nullableRawTimestamp(merged.unpublishAt),

      isEnabled,
      status: normalizeStatus(merged.status, isEnabled),
      isFeatured: asBool(merged.isFeatured, false),
      isFlashSale: asBool(merged.isFlashSale, false),
      isNewArrival: asBool(merged.isNewArrival, false),
      isBestSeller: asBool(merged.isBestSeller, false),

      isDeleted: wantsDeleted,
      deletedAt,
      deletedBy,
      deleteReason,

      createdBy: asNullableString(existing.createdBy) ??
        asNullableString(merged.createdBy) ??
        actorUid,
      updatedBy: actorUid,
      createdAt: existing.createdAt ?? merged.createdAt ?? now,
      updatedAt: now,

      totalSold: asInteger(existing.totalSold, 0),
      addToCartCount: asInteger(existing.addToCartCount, 0),
      views: asInteger(existing.views, 0),

      cardLayoutType: normalizedCardConfig?.variantId ?? null,
      cardConfig: normalizedCardConfig,
      cardDesignJson: asNullableString(merged.cardDesignJson),

      taxClassId: asNullableString(merged.taxClassId),
      vatRate: asNullableNumber(merged.vatRate),
      isTaxIncluded: asBool(merged.isTaxIncluded, false),

      weightValue: asNullableNumber(merged.weightValue),
      weightUnit: asNullableString(merged.weightUnit),
      length: asNullableNumber(merged.length),
      width: asNullableNumber(merged.width),
      height: asNullableNumber(merged.height),
      dimensionUnit: asNullableString(merged.dimensionUnit),
      shippingClassId: asNullableString(merged.shippingClassId),

      mediaItems: normalizeObjectList(merged.mediaItems),
      imageUrls: asStringArray(merged.imageUrls),
      thumbnailUrl: asNullableString(merged.thumbnailUrl),

      adminNote: asNullableString(merged.adminNote),
      metadata: sanitizeJsonMap(merged.metadata),

      sortOrder: asInteger(merged.sortOrder, index),
    };
  });
}

function normalizeProductPayload(
  input: JsonMap,
  actorUid: string,
  productId: string,
  reason?: string | null,
): JsonMap {
  const titleEn = asTrimmedString(input.titleEn);
  const slug = asTrimmedString(input.slug).toLowerCase();

  const normalizedCardConfig = normalizeCardConfig(
    input.cardConfig,
    input.cardLayoutType,
  );

  const normalized: JsonMap = {
    ...input,
    id: productId,
    titleEn,
    slug,

    titleBn: asTrimmedString(input.titleBn),
    shortDescriptionEn: asTrimmedString(input.shortDescriptionEn),
    shortDescriptionBn: asTrimmedString(input.shortDescriptionBn),
    descriptionEn: asTrimmedString(input.descriptionEn),
    descriptionBn: asTrimmedString(input.descriptionBn),

    productCode:
      asTrimmedString(input.productCode).length > 0
        ? asTrimmedString(input.productCode)
        : null,
    sku:
      asTrimmedString(input.sku).length > 0 ? asTrimmedString(input.sku) : null,
    barcode: asNullableString(input.barcode),

    productType:
      asTrimmedString(input.productType).length > 0
        ? asTrimmedString(input.productType)
        : "simple",

    inventoryMode:
      asTrimmedString(input.inventoryMode).length > 0
        ? asTrimmedString(input.inventoryMode)
        : "stocked",

    schedulePriceType:
      asTrimmedString(input.schedulePriceType).length > 0
        ? asTrimmedString(input.schedulePriceType)
        : "fixed",

    quantityType:
      asTrimmedString(input.quantityType).length > 0
        ? asTrimmedString(input.quantityType)
        : "pcs",

    toleranceType:
      asTrimmedString(input.toleranceType).length > 0
        ? asTrimmedString(input.toleranceType)
        : "g",

    deliveryShift:
      asTrimmedString(input.deliveryShift).length > 0
        ? asTrimmedString(input.deliveryShift)
        : "any",

    cardLayoutType: normalizedCardConfig.variantId,
    cardConfig: normalizedCardConfig,

    tags: asStringArray(input.tags),
    keywords: asStringArray(input.keywords),

    price: asNumber(input.price, 0),
    stockQty: Math.trunc(asNumber(input.stockQty, 0)),
    regularStockQty: Math.trunc(asNumber(input.regularStockQty, 0)),
    reservedQty: Math.trunc(asNumber(input.reservedQty, 0)),
    reservedInstantQty: Math.trunc(asNumber(input.reservedInstantQty, 0)),
    todayInstantCap: Math.trunc(asNumber(input.todayInstantCap, 999999)),
    todayInstantSold: Math.trunc(asNumber(input.todayInstantSold, 0)),
    maxScheduleQtyPerDay: Math.trunc(
      asNumber(input.maxScheduleQtyPerDay, 999999),
    ),
    minScheduleNoticeHours: Math.trunc(
      asNumber(input.minScheduleNoticeHours, 0),
    ),
    reorderLevel: Math.trunc(asNumber(input.reorderLevel, 0)),
    sortOrder: Math.trunc(asNumber(input.sortOrder, 0)),

    // Server-managed counters.
    views: 0,
    totalSold: 0,
    addToCartCount: 0,

    quantityValue: asNumber(input.quantityValue, 0),
    tolerance: asNumber(input.tolerance, 0),

    trackInventory: asBool(input.trackInventory, true),
    supportsInstantOrder: asBool(input.supportsInstantOrder, true),
    supportsScheduledOrder: asBool(input.supportsScheduledOrder, false),
    allowBackorder: asBool(input.allowBackorder, false),
    isFeatured: asBool(input.isFeatured, false),
    isFlashSale: asBool(input.isFlashSale, false),
    isEnabled: asBool(input.isEnabled, true),
    isNewArrival: asBool(input.isNewArrival, false),
    isBestSeller: asBool(input.isBestSeller, false),
    isToleranceActive: asBool(input.isToleranceActive, false),

    status: normalizeStatus(input.status, asBool(input.isEnabled, true)),

    taxClassId: asNullableString(input.taxClassId),
    vatRate: asNullableNumber(input.vatRate),
    isTaxIncluded: asBool(input.isTaxIncluded, false),

    weightValue: asNullableNumber(input.weightValue),
    weightUnit: asNullableString(input.weightUnit),
    length: asNullableNumber(input.length),
    width: asNullableNumber(input.width),
    height: asNullableNumber(input.height),
    dimensionUnit: asNullableString(input.dimensionUnit),
    shippingClassId: asNullableString(input.shippingClassId),

    adminNote: asNullableString(input.adminNote),
    metadata: sanitizeJsonMap(input.metadata),
    purchaseOptions: normalizePurchaseOptions(input.purchaseOptions),

    isDeleted: false,
    deletedAt: null,
    deletedBy: null,
    deleteReason: null,

    createdBy:
      asTrimmedString(input.createdBy).length > 0
        ? asTrimmedString(input.createdBy)
        : actorUid,
    updatedBy: actorUid,
  };

  const nullableIdKeys = [
    "categoryId",
    "brandId",
    "categoryNameEn",
    "categoryNameBn",
    "categorySlug",
    "brandNameEn",
    "brandNameBn",
    "brandSlug",
    "instantCutoffTime",
    "unitLabelEn",
    "unitLabelBn",
  ] as const;

  for (const key of nullableIdKeys) {
    const value = asTrimmedString(input[key]);
    normalized[key] = value.length > 0 ? value : null;
  }

  const nullableNumberKeys = [
    "salePrice",
    "costPrice",
    "estimatedSchedulePrice",
    "minOrderQty",
    "maxOrderQty",
    "stepQty",
    "vatRate",
    "weightValue",
    "length",
    "width",
    "height",
  ] as const;

  for (const key of nullableNumberKeys) {
    const raw = input[key];
    normalized[key] =
      typeof raw === "number" && Number.isFinite(raw) ? raw : null;
  }

  normalized.mediaItems = normalizeRootMediaItems(
    input.mediaItems,
    normalized.productType,
  );
  normalized.imageUrls = asStringArray(input.imageUrls);
  normalized.thumbnailUrl = asNullableString(input.thumbnailUrl);

  normalized.variations = normalizeVariations(
    input.variations,
    [],
    actorUid,
    admin.firestore.Timestamp.now(),
    normalized,
    reason,
  );

  return normalized;
}

export const adminCreateProduct = onCall<
  CreateProductRequest,
  Promise<CreateProductResponse>
>(async (request) => {
  try {
    logger.info("adminCreateProduct invoked", {
      uid: request.auth?.uid ?? null,
      hasData: !!request.data,
      hasProduct: !!request.data?.product,
      productId:
        request.data?.product &&
        typeof request.data.product === "object" &&
        !Array.isArray(request.data.product)
          ? (request.data.product as JsonMap).id ?? null
          : null,
      titleEn:
        request.data?.product &&
        typeof request.data.product === "object" &&
        !Array.isArray(request.data.product)
          ? (request.data.product as JsonMap).titleEn ?? null
          : null,
    });

    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canManageProducts",
    );

    const productInput = requireObjectRecord(request.data?.product, "product");
    const reason = normalizeNullableId(request.data?.reason);

    const sanitizedInput = sanitizeProductInput(productInput);
    const requestedId = asTrimmedString(sanitizedInput.id);

    const titleEn = asTrimmedString(sanitizedInput.titleEn);
    const slug = asTrimmedString(sanitizedInput.slug).toLowerCase();

    requireNonEmpty(titleEn, "product.titleEn");
    requireNonEmpty(slug, "product.slug");

    const productRef =
      requestedId.length > 0
        ? db.collection("products").doc(requestedId)
        : db.collection("products").doc();

    const productId = productRef.id;
    let auditLogId = "";

    await db.runTransaction(async (tx) => {
      const existingSnap = await tx.get(productRef);
      if (existingSnap.exists) {
        throw new HttpsError(
          "already-exists",
          "A product with this id already exists.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      const normalizedData = normalizeProductPayload(
        sanitizedInput,
        actor.uid,
        productId,
        reason,
      );

      const docData: JsonMap = {
        ...normalizedData,
        createdAt: sanitizedInput.createdAt ?? now,
        updatedAt: now,
      };

      tx.set(productRef, docData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "create_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: titleEn,
          status: "success",
          reason,
          beforeData: null,
          afterData: {
            id: productId,
            titleEn,
            slug,
            isEnabled: docData.isEnabled ?? true,
            categoryId: docData.categoryId ?? null,
            brandId: docData.brandId ?? null,
            cardLayoutType: docData.cardLayoutType ?? "compact01",
            cardConfig: docData.cardConfig ?? null,
          },
          metadata: {
            sku: docData.sku ?? null,
            productCode: docData.productCode ?? null,
            productType: docData.productType ?? null,
            barcode: docData.barcode ?? null,
            status: docData.status ?? null,
            reservedQty: docData.reservedQty ?? 0,
            variationsCount: Array.isArray(docData.variations)
              ? docData.variations.length
              : 0,
          },
          eventSource: "server_action",
        }),
      );
    });

    return {
      success: true,
      productId,
      auditLogId,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    logger.error("adminCreateProduct failed", {
      error,
      data: request.data ?? null,
      uid: request.auth?.uid ?? null,
    });

    throw new HttpsError("internal", "Failed to create product.");
  }
});

