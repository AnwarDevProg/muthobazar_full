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
function isJsonMap(value) {
    return (!!value &&
        typeof value === "object" &&
        !Array.isArray(value));
}
function isValidNewCardVariantId(value) {
    return /^(compact|price|horizontal|premium|wide|featured|promo|flash)0[1-5]$/.test(value);
}
function familyIdFromVariantId(variantId) {
    if (variantId.startsWith("compact"))
        return "compact";
    if (variantId.startsWith("price"))
        return "price";
    if (variantId.startsWith("horizontal"))
        return "horizontal";
    if (variantId.startsWith("premium"))
        return "premium";
    if (variantId.startsWith("wide"))
        return "wide";
    if (variantId.startsWith("featured"))
        return "featured";
    if (variantId.startsWith("promo"))
        return "promo";
    if (variantId.startsWith("flash"))
        return "flash_sale";
    if (isValidAdvancedCardLayoutId(variantId))
        return "advanced_v3";
    throw new https_1.HttpsError("invalid-argument", `Invalid card variant id: ${variantId}`);
}
function isValidAdvancedCardLayoutId(value) {
    const advancedLayoutIds = new Set([
        "advanced_v3",
        "hero_poster_circle",
        "hero_poster_circle_diagonal_v1",
        "orange_gradient_poster_v1",
        "advanced_orange_phone_card_v1",
    ]);
    return advancedLayoutIds.has(value);
}
function normalizeCardVariantId(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    if (normalized.length === 0) {
        return "compact01";
    }
    if (!isValidNewCardVariantId(normalized) && !isValidAdvancedCardLayoutId(normalized)) {
        throw new https_1.HttpsError("invalid-argument", `Invalid card variant id: ${normalized}. Use legacy ids like compact01, horizontal03, wide02, promo05, or V3 ids like hero_poster_circle_diagonal_v1 when cardDesignJson is provided.`);
    }
    return normalized;
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
        familyId: familyIdFromVariantId(variantId),
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
function asNullableString(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value);
    return normalized.length > 0 ? normalized : null;
}
function asNullableNumber(value) {
    return typeof value === "number" && Number.isFinite(value) ? value : null;
}
function asInteger(value, fallback = 0) {
    return Math.trunc(asNumber(value, fallback));
}
function sanitizeJsonMap(value) {
    const sanitized = sanitizeFirestoreValue(value);
    if (!isJsonMap(sanitized))
        return {};
    return sanitized;
}
function normalizeObjectList(value) {
    if (!Array.isArray(value))
        return [];
    return value
        .map((item) => sanitizeFirestoreValue(item))
        .filter((item) => isJsonMap(item));
}
function normalizeRootMediaItems(value, productType) {
    const productTypeText = (0, callable_parsers_1.asTrimmedString)(productType).toLowerCase();
    const isVariableProduct = productTypeText === "variable";
    return normalizeObjectList(value).map((item, index) => {
        const normalized = {
            ...item,
            sortOrder: asInteger(item.sortOrder, index),
        };
        if (isVariableProduct) {
            normalized.role = "gallery";
            normalized.isPrimary = false;
            return normalized;
        }
        const role = (0, callable_parsers_1.asTrimmedString)(item.role);
        normalized.role = role.length > 0 ? role : index === 0 ? "thumbnail" : "gallery";
        normalized.isPrimary = asBool(item.isPrimary, index === 0);
        return normalized;
    });
}
function normalizePurchaseOptions(value) {
    return normalizeObjectList(value);
}
function normalizeOptionalCardConfig(value, fallbackLayoutType) {
    const rawLayoutType = (0, callable_parsers_1.asTrimmedString)(fallbackLayoutType).toLowerCase();
    const hasConfig = isJsonMap(value);
    const hasLayout = rawLayoutType.length > 0;
    if (!hasConfig && !hasLayout) {
        return null;
    }
    return normalizeCardConfig(value, hasLayout ? rawLayoutType : "compact01");
}
function normalizeStatus(value, isEnabled) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    if (normalized.length > 0) {
        return normalized;
    }
    return isEnabled ? "active" : "inactive";
}
function nullableRawTimestamp(value) {
    return value === undefined ? null : value;
}
function normalizeVariations(value, existingValue, actorUid, now, rootData, reason) {
    const inputVariations = normalizeObjectList(value);
    const existingVariations = normalizeObjectList(existingValue);
    const existingById = new Map();
    for (const item of existingVariations) {
        const id = (0, callable_parsers_1.asTrimmedString)(item.id);
        if (id.length > 0) {
            existingById.set(id, item);
        }
    }
    return inputVariations.map((input, index) => {
        const requestedId = (0, callable_parsers_1.asTrimmedString)(input.id);
        const existing = requestedId.length > 0 ? existingById.get(requestedId) ?? {} : {};
        const merged = {
            ...existing,
            ...input,
        };
        const id = requestedId.length > 0
            ? requestedId
            : (0, callable_parsers_1.asTrimmedString)(existing.id).length > 0
                ? (0, callable_parsers_1.asTrimmedString)(existing.id)
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
        const normalizedCardConfig = normalizeOptionalCardConfig(merged.cardConfig, merged.cardLayoutType);
        return {
            ...merged,
            id,
            titleEn: (0, callable_parsers_1.asTrimmedString)(merged.titleEn),
            titleBn: (0, callable_parsers_1.asTrimmedString)(merged.titleBn),
            shortDescriptionEn: (0, callable_parsers_1.asTrimmedString)(merged.shortDescriptionEn),
            shortDescriptionBn: (0, callable_parsers_1.asTrimmedString)(merged.shortDescriptionBn),
            descriptionEn: (0, callable_parsers_1.asTrimmedString)(merged.descriptionEn),
            descriptionBn: (0, callable_parsers_1.asTrimmedString)(merged.descriptionBn),
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
            quantityType: (0, callable_parsers_1.asTrimmedString)(merged.quantityType).length > 0
                ? (0, callable_parsers_1.asTrimmedString)(merged.quantityType)
                : (0, callable_parsers_1.asTrimmedString)(rootData.quantityType).length > 0
                    ? (0, callable_parsers_1.asTrimmedString)(rootData.quantityType)
                    : "pcs",
            quantityValue: asNumber(merged.quantityValue, 0),
            unitLabelEn: asNullableString(merged.unitLabelEn),
            unitLabelBn: asNullableString(merged.unitLabelBn),
            toleranceType: (0, callable_parsers_1.asTrimmedString)(merged.toleranceType).length > 0
                ? (0, callable_parsers_1.asTrimmedString)(merged.toleranceType)
                : (0, callable_parsers_1.asTrimmedString)(rootData.toleranceType).length > 0
                    ? (0, callable_parsers_1.asTrimmedString)(rootData.toleranceType)
                    : "g",
            tolerance: asNumber(merged.tolerance, 0),
            isToleranceActive: asBool(merged.isToleranceActive, false),
            trackInventory: asBool(merged.trackInventory, asBool(rootData.trackInventory, true)),
            supportsInstantOrder: asBool(merged.supportsInstantOrder, asBool(rootData.supportsInstantOrder, true)),
            supportsScheduledOrder: asBool(merged.supportsScheduledOrder, asBool(rootData.supportsScheduledOrder, false)),
            allowBackorder: asBool(merged.allowBackorder, asBool(rootData.allowBackorder, false)),
            instantCutoffTime: asNullableString(merged.instantCutoffTime),
            todayInstantCap: asInteger(merged.todayInstantCap, 999999),
            todayInstantSold: asInteger(merged.todayInstantSold, 0),
            maxScheduleQtyPerDay: asInteger(merged.maxScheduleQtyPerDay, 999999),
            minScheduleNoticeHours: asInteger(merged.minScheduleNoticeHours, 0),
            schedulePriceType: (0, callable_parsers_1.asTrimmedString)(merged.schedulePriceType).length > 0
                ? (0, callable_parsers_1.asTrimmedString)(merged.schedulePriceType)
                : (0, callable_parsers_1.asTrimmedString)(rootData.schedulePriceType).length > 0
                    ? (0, callable_parsers_1.asTrimmedString)(rootData.schedulePriceType)
                    : "fixed",
            estimatedSchedulePrice: asNullableNumber(merged.estimatedSchedulePrice),
            purchaseOptions: normalizePurchaseOptions(merged.purchaseOptions),
            deliveryShift: (0, callable_parsers_1.asTrimmedString)(merged.deliveryShift).length > 0
                ? (0, callable_parsers_1.asTrimmedString)(merged.deliveryShift)
                : (0, callable_parsers_1.asTrimmedString)(rootData.deliveryShift).length > 0
                    ? (0, callable_parsers_1.asTrimmedString)(rootData.deliveryShift)
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
function normalizeMergedProductPayload(currentData, patchInput, actorUid, productId, reason) {
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
        barcode: asNullableString(mergedBase.barcode),
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
        reservedQty: Math.trunc(asNumber(mergedBase.reservedQty, 0)),
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
        status: normalizeStatus(mergedBase.status, asBool(mergedBase.isEnabled, true)),
        taxClassId: asNullableString(mergedBase.taxClassId),
        vatRate: asNullableNumber(mergedBase.vatRate),
        isTaxIncluded: asBool(mergedBase.isTaxIncluded, false),
        weightValue: asNullableNumber(mergedBase.weightValue),
        weightUnit: asNullableString(mergedBase.weightUnit),
        length: asNullableNumber(mergedBase.length),
        width: asNullableNumber(mergedBase.width),
        height: asNullableNumber(mergedBase.height),
        dimensionUnit: asNullableString(mergedBase.dimensionUnit),
        shippingClassId: asNullableString(mergedBase.shippingClassId),
        adminNote: asNullableString(mergedBase.adminNote),
        metadata: sanitizeJsonMap(mergedBase.metadata),
        purchaseOptions: normalizePurchaseOptions(mergedBase.purchaseOptions),
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
        "vatRate",
        "weightValue",
        "length",
        "width",
        "height",
    ];
    for (const key of nullableNumberKeys) {
        const raw = mergedBase[key];
        normalized[key] =
            typeof raw === "number" && Number.isFinite(raw) ? raw : null;
    }
    normalized.mediaItems = normalizeRootMediaItems(mergedBase.mediaItems, normalized.productType);
    normalized.imageUrls = asStringArray(mergedBase.imageUrls);
    normalized.thumbnailUrl = asNullableString(mergedBase.thumbnailUrl);
    normalized.variations = normalizeVariations(mergedBase.variations, currentData.variations, actorUid, admin.firestore.Timestamp.now(), normalized, reason);
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
            const nextData = normalizeMergedProductPayload(currentData, sanitizedInput, actor.uid, productId, reason);
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
                    barcode: nextData.barcode ?? null,
                    status: nextData.status ?? null,
                    reservedQty: nextData.reservedQty ?? 0,
                    variationsCount: Array.isArray(nextData.variations)
                        ? nextData.variations.length
                        : 0,
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
