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
function normalizeCardLayoutType(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    switch (normalized) {
        case "compact":
        case "deal":
        case "featured":
        case "standard":
            return normalized;
        default:
            return "standard";
    }
}
function normalizeExistingProductData(input) {
    const output = { ...input };
    output.cardLayoutType = normalizeCardLayoutType(input.cardLayoutType);
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
        cardLayoutType: normalizeCardLayoutType(mergedBase.cardLayoutType),
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
                    cardLayoutType: nextData.cardLayoutType ?? "standard",
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
