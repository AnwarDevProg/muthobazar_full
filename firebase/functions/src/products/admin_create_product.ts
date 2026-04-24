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

const cardVariantFamilyById: Record<string, string> = {
  compact01: "compact",
  compact02: "compact",
  compact03: "compact",
  compact04: "compact",
  compact05: "compact",
  price01: "price",
  price02: "price",
  price03: "price",
  price04: "price",
  price05: "price",
  horizontal01: "horizontal",
  horizontal02: "horizontal",
  horizontal03: "horizontal",
  horizontal04: "horizontal",
  horizontal05: "horizontal",
  premium01: "premium",
  premium02: "premium",
  premium03: "premium",
  premium04: "premium",
  premium05: "premium",
  wide01: "wide",
  wide02: "wide",
  wide03: "wide",
  wide04: "wide",
  wide05: "wide",
  featured01: "featured",
  featured02: "featured",
  featured03: "featured",
  featured04: "featured",
  featured05: "featured",
  promo01: "promo",
  promo02: "promo",
  promo03: "promo",
  promo04: "promo",
  promo05: "promo",
  flash01: "flashSale",
  flash02: "flashSale",
  flash03: "flashSale",
  flash04: "flashSale",
  flash05: "flashSale",
};

function isJsonMap(value: unknown): value is JsonMap {
  return (
    !!value &&
    typeof value === "object" &&
    !Array.isArray(value)
  );
}

function normalizeCardVariantId(value: unknown): string {
  const normalized = asTrimmedString(value).toLowerCase();

  switch (normalized) {
    case "":
    case "standard":
    case "default":
    case "compact":
      return "compact01";

    case "deal":
    case "promo":
      return "promo01";

    case "featured":
      return "featured01";

    case "flash":
    case "flashsale":
    case "flash_sale":
    case "flash-sale":
      return "flash01";

    case "price":
    case "card01":
      return "price01";

    case "horizontal":
      return "horizontal01";

    case "premium":
    case "card02":
      return "premium01";

    case "wide":
      return "wide01";

    case "card03":
      return "featured01";

    case "compact01":
    case "compact02":
    case "compact03":
    case "compact04":
    case "compact05":
    case "price01":
    case "price02":
    case "price03":
    case "price04":
    case "price05":
    case "horizontal01":
    case "horizontal02":
    case "horizontal03":
    case "horizontal04":
    case "horizontal05":
    case "premium01":
    case "premium02":
    case "premium03":
    case "premium04":
    case "premium05":
    case "wide01":
    case "wide02":
    case "wide03":
    case "wide04":
    case "wide05":
    case "featured01":
    case "featured02":
    case "featured03":
    case "featured04":
    case "featured05":
    case "promo01":
    case "promo02":
    case "promo03":
    case "promo04":
    case "promo05":
    case "flash01":
    case "flash02":
    case "flash03":
    case "flash04":
    case "flash05":
      return normalized;

    default:
      return "compact01";
  }
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
    familyId: cardVariantFamilyById[variantId] ?? "compact",
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



function normalizeProductPayload(
  input: JsonMap,
  actorUid: string,
  productId: string,
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
  ] as const;

  for (const key of nullableNumberKeys) {
    const raw = input[key];
    normalized[key] =
      typeof raw === "number" && Number.isFinite(raw) ? raw : null;
  }

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