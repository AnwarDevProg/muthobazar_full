"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminUpdateProduct = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function sanitizeFirestoreValue(value) {
    if (value === undefined)
        return undefined;
    if (value === null ||
        typeof value === "string" ||
        typeof value === "number" ||
        typeof value === "boolean") {
        return value;
    }
    if (value instanceof Date ||
        value instanceof admin.firestore.Timestamp ||
        value instanceof admin.firestore.GeoPoint ||
        value instanceof admin.firestore.DocumentReference ||
        value instanceof admin.firestore.FieldValue) {
        return value;
    }
    if (Array.isArray(value)) {
        return value
            .map((item) => sanitizeFirestoreValue(item))
            .filter((item) => item !== undefined);
    }
    if (typeof value === "object") {
        const input = value;
        const output = {};
        for (const [key, rawValue] of Object.entries(input)) {
            if (key.startsWith("clear"))
                continue;
            const sanitized = sanitizeFirestoreValue(rawValue);
            if (sanitized !== undefined) {
                output[key] = sanitized;
            }
        }
        return output;
    }
    return undefined;
}
function sanitizeProductInput(input) {
    const sanitized = sanitizeFirestoreValue(input);
    if (!sanitized || typeof sanitized !== "object" || Array.isArray(sanitized)) {
        return {};
    }
    return sanitized;
}
function asBool(value, fallback = false) {
    return typeof value === "boolean" ? value : fallback;
}
function asNumber(value, fallback = 0) {
    return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}
function asStringArray(value) {
    if (!Array.isArray(value))
        return [];
    return value
        .map((item) => (0, callable_parsers_1.asTrimmedString)(item))
        .filter((item) => item.length > 0);
}
const cardVariantFamilyById = {
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
function isJsonMap(value) {
    return (!!value &&
        typeof value === "object" &&
        !Array.isArray(value));
}
function normalizeCardVariantId(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
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
function sanitizeCardSettings(value) {
    if (!isJsonMap(value))
        return {};
    const sanitized = sanitizeFirestoreValue(value);
    if (!isJsonMap(sanitized))
        return {};
    return sanitized;
}
function normalizeCardConfig(value, fallbackLayoutType) {
    const input = isJsonMap(value) ? value : {};
    const variantId = normalizeCardVariantId(input.variantId ?? fallbackLayoutType);
    return {
        familyId: cardVariantFamilyById[variantId] ?? "compact",
        variantId,
        presetId: (0, callable_parsers_1.asTrimmedString)(input.presetId).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.presetId)
            : null,
        settings: sanitizeCardSettings(input.settings),
    };
}
function normalizeCardLayoutType(value) {
    return normalizeCardVariantId(value);
}
function normalizeExistingProductData(input) {
    const output = { ...input };
    const normalizedCardConfig = normalizeCardConfig(input.cardConfig, input.cardLayoutType);
    output.cardLayoutType = normalizedCardConfig.variantId;
    output.cardConfig = normalizedCardConfig;
    if ((0, callable_parsers_1.asTrimmedString)(output.productType).length === 0) {
        output.productType = "simple";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.inventoryMode).length === 0) {
        output.inventoryMode = "stocked";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.schedulePriceType).length === 0) {
        output.schedulePriceType = "fixed";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.quantityType).length === 0) {
        output.quantityType = "pcs";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.toleranceType).length === 0) {
        output.toleranceType = "g";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.deliveryShift).length === 0) {
        output.deliveryShift = "any";
    }
    return output;
}
function normalizeMergedProductPayload(currentData, patchInput, actorUid, productId) {
    const mergedBase = {
        ...normalizeExistingProductData(currentData),
        ...patchInput,
    };
    const titleEn = (0, callable_parsers_1.asTrimmedString)(mergedBase.titleEn);
    const slug = (0, callable_parsers_1.asTrimmedString)(mergedBase.slug).toLowerCase();
    const normalizedCardConfig = normalizeCardConfig(mergedBase.cardConfig, mergedBase.cardLayoutType);
    const normalized = {
        ...mergedBase,
        id: productId,
        titleEn,
        slug,
        titleBn: (0, callable_parsers_1.asTrimmedString)(mergedBase.titleBn),
        shortDescriptionEn: (0, callable_parsers_1.asTrimmedString)(mergedBase.shortDescriptionEn),
        shortDescriptionBn: (0, callable_parsers_1.asTrimmedString)(mergedBase.shortDescriptionBn),
        descriptionEn: (0, callable_parsers_1.asTrimmedString)(mergedBase.descriptionEn),
        descriptionBn: (0, callable_parsers_1.asTrimmedString)(mergedBase.descriptionBn),
        productCode: (0, callable_parsers_1.asTrimmedString)(mergedBase.productCode).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.productCode)
            : null,
        sku: (0, callable_parsers_1.asTrimmedString)(mergedBase.sku).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.sku)
            : null,
        productType: (0, callable_parsers_1.asTrimmedString)(mergedBase.productType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.productType)
            : "simple",
        inventoryMode: (0, callable_parsers_1.asTrimmedString)(mergedBase.inventoryMode).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.inventoryMode)
            : "stocked",
        schedulePriceType: (0, callable_parsers_1.asTrimmedString)(mergedBase.schedulePriceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.schedulePriceType)
            : "fixed",
        quantityType: (0, callable_parsers_1.asTrimmedString)(mergedBase.quantityType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.quantityType)
            : "pcs",
        toleranceType: (0, callable_parsers_1.asTrimmedString)(mergedBase.toleranceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.toleranceType)
            : "g",
        deliveryShift: (0, callable_parsers_1.asTrimmedString)(mergedBase.deliveryShift).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(mergedBase.deliveryShift)
            : "any",
        cardLayoutType: normalizedCardConfig.variantId,
        cardConfig: normalizedCardConfig,
        tags: asStringArray(mergedBase.tags),
        keywords: asStringArray(mergedBase.keywords),
        price: asNumber(mergedBase.price, 0),
        stockQty: Math.trunc(asNumber(mergedBase.stockQty, 0)),
        regularStockQty: Math.trunc(asNumber(mergedBase.regularStockQty, 0)),
        reservedInstantQty: Math.trunc(asNumber(mergedBase.reservedInstantQty, 0)),
        todayInstantCap: Math.trunc(asNumber(mergedBase.todayInstantCap, 999999)),
        todayInstantSold: Math.trunc(asNumber(mergedBase.todayInstantSold, 0)),
        maxScheduleQtyPerDay: Math.trunc(asNumber(mergedBase.maxScheduleQtyPerDay, 999999)),
        minScheduleNoticeHours: Math.trunc(asNumber(mergedBase.minScheduleNoticeHours, 0)),
        reorderLevel: Math.trunc(asNumber(mergedBase.reorderLevel, 0)),
        sortOrder: Math.trunc(asNumber(mergedBase.sortOrder, 0)),
        // Server-managed counters. Ignore any client patch values.
        views: Math.trunc(asNumber(currentData.views, 0)),
        totalSold: Math.trunc(asNumber(currentData.totalSold, 0)),
        addToCartCount: Math.trunc(asNumber(currentData.addToCartCount, 0)),
        quantityValue: asNumber(mergedBase.quantityValue, 0),
        tolerance: asNumber(mergedBase.tolerance, 0),
        trackInventory: asBool(mergedBase.trackInventory, true),
        supportsInstantOrder: asBool(mergedBase.supportsInstantOrder, true),
        supportsScheduledOrder: asBool(mergedBase.supportsScheduledOrder, false),
        allowBackorder: asBool(mergedBase.allowBackorder, false),
        isFeatured: asBool(mergedBase.isFeatured, false),
        isFlashSale: asBool(mergedBase.isFlashSale, false),
        isEnabled: asBool(mergedBase.isEnabled, true),
        isNewArrival: asBool(mergedBase.isNewArrival, false),
        isBestSeller: asBool(mergedBase.isBestSeller, false),
        isToleranceActive: asBool(mergedBase.isToleranceActive, false),
        updatedBy: actorUid,
    };
    const nullableStringKeys = [
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
    ];
    for (const key of nullableStringKeys) {
        const value = (0, callable_parsers_1.asTrimmedString)(mergedBase[key]);
        normalized[key] = value.length > 0 ? value : null;
    }
    const nullableNumberKeys = [
        "salePrice",
        "costPrice",
        "estimatedSchedulePrice",
        "minOrderQty",
        "maxOrderQty",
        "stepQty",
    ];
    for (const key of nullableNumberKeys) {
        const raw = mergedBase[key];
        normalized[key] =
            typeof raw === "number" && Number.isFinite(raw) ? raw : null;
    }
    return normalized;
}
exports.adminUpdateProduct = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminUpdateProduct invoked", {
            uid: request.auth?.uid ?? null,
            hasData: !!request.data,
            hasProduct: !!request.data?.product,
            productId: request.data?.product &&
                typeof request.data.product === "object" &&
                !Array.isArray(request.data.product)
                ? request.data.product.id ?? null
                : null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageProducts");
        const productInput = (0, callable_parsers_1.requireObjectRecord)(request.data?.product, "product");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        const sanitizedInput = sanitizeProductInput(productInput);
        const productId = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.id);
        (0, callable_parsers_1.requireNonEmpty)(productId, "product.id");
        const productRef = db.collection("products").doc(productId);
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const currentSnap = await tx.get(productRef);
            if (!currentSnap.exists) {
                throw new https_1.HttpsError("not-found", "Product not found.");
            }
            const currentData = (currentSnap.data() ?? {});
            const now = admin.firestore.FieldValue.serverTimestamp();
            const nextData = normalizeMergedProductPayload(currentData, sanitizedInput, actor.uid, productId);
            (0, callable_parsers_1.requireNonEmpty)((0, callable_parsers_1.asTrimmedString)(nextData.titleEn), "product.titleEn");
            (0, callable_parsers_1.requireNonEmpty)((0, callable_parsers_1.asTrimmedString)(nextData.slug), "product.slug");
            tx.set(productRef, {
                ...nextData,
                updatedAt: now,
            }, { merge: false });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "update_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: (0, callable_parsers_1.asTrimmedString)(nextData.titleEn),
                status: "success",
                reason,
                beforeData: currentData,
                afterData: {
                    id: productId,
                    titleEn: nextData.titleEn,
                    slug: nextData.slug,
                    isEnabled: nextData.isEnabled ?? true,
                    categoryId: nextData.categoryId ?? null,
                    brandId: nextData.brandId ?? null,
                    cardLayoutType: nextData.cardLayoutType ?? "compact01",
                    cardConfig: nextData.cardConfig ?? null,
                },
                metadata: {
                    sku: nextData.sku ?? null,
                    productCode: nextData.productCode ?? null,
                    productType: nextData.productType ?? null,
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            productId,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminUpdateProduct failed", {
            error,
            data: request.data ?? null,
            uid: request.auth?.uid ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to update product.");
    }
});
