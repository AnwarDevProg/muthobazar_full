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
exports.adminCreateProduct = void 0;
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
function normalizeProductPayload(input, actorUid, productId) {
    const titleEn = (0, callable_parsers_1.asTrimmedString)(input.titleEn);
    const slug = (0, callable_parsers_1.asTrimmedString)(input.slug).toLowerCase();
    const normalized = {
        ...input,
        id: productId,
        titleEn,
        slug,
        titleBn: (0, callable_parsers_1.asTrimmedString)(input.titleBn),
        shortDescriptionEn: (0, callable_parsers_1.asTrimmedString)(input.shortDescriptionEn),
        shortDescriptionBn: (0, callable_parsers_1.asTrimmedString)(input.shortDescriptionBn),
        descriptionEn: (0, callable_parsers_1.asTrimmedString)(input.descriptionEn),
        descriptionBn: (0, callable_parsers_1.asTrimmedString)(input.descriptionBn),
        productCode: (0, callable_parsers_1.asTrimmedString)(input.productCode).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.productCode)
            : null,
        sku: (0, callable_parsers_1.asTrimmedString)(input.sku).length > 0 ? (0, callable_parsers_1.asTrimmedString)(input.sku) : null,
        productType: (0, callable_parsers_1.asTrimmedString)(input.productType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.productType)
            : "simple",
        inventoryMode: (0, callable_parsers_1.asTrimmedString)(input.inventoryMode).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.inventoryMode)
            : "stocked",
        schedulePriceType: (0, callable_parsers_1.asTrimmedString)(input.schedulePriceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.schedulePriceType)
            : "fixed",
        quantityType: (0, callable_parsers_1.asTrimmedString)(input.quantityType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.quantityType)
            : "pcs",
        toleranceType: (0, callable_parsers_1.asTrimmedString)(input.toleranceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.toleranceType)
            : "g",
        deliveryShift: (0, callable_parsers_1.asTrimmedString)(input.deliveryShift).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.deliveryShift)
            : "any",
        cardLayoutType: normalizeCardLayoutType(input.cardLayoutType),
        tags: asStringArray(input.tags),
        keywords: asStringArray(input.keywords),
        price: asNumber(input.price, 0),
        stockQty: Math.trunc(asNumber(input.stockQty, 0)),
        regularStockQty: Math.trunc(asNumber(input.regularStockQty, 0)),
        reservedInstantQty: Math.trunc(asNumber(input.reservedInstantQty, 0)),
        todayInstantCap: Math.trunc(asNumber(input.todayInstantCap, 999999)),
        todayInstantSold: Math.trunc(asNumber(input.todayInstantSold, 0)),
        maxScheduleQtyPerDay: Math.trunc(asNumber(input.maxScheduleQtyPerDay, 999999)),
        minScheduleNoticeHours: Math.trunc(asNumber(input.minScheduleNoticeHours, 0)),
        reorderLevel: Math.trunc(asNumber(input.reorderLevel, 0)),
        sortOrder: Math.trunc(asNumber(input.sortOrder, 0)),
        views: Math.trunc(asNumber(input.views, 0)),
        totalSold: Math.trunc(asNumber(input.totalSold, 0)),
        addToCartCount: Math.trunc(asNumber(input.addToCartCount, 0)),
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
        createdBy: (0, callable_parsers_1.asTrimmedString)(input.createdBy).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(input.createdBy)
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
    ];
    for (const key of nullableIdKeys) {
        const value = (0, callable_parsers_1.asTrimmedString)(input[key]);
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
        const raw = input[key];
        normalized[key] =
            typeof raw === "number" && Number.isFinite(raw) ? raw : null;
    }
    return normalized;
}
exports.adminCreateProduct = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminCreateProduct invoked", {
            uid: request.auth?.uid ?? null,
            hasData: !!request.data,
            hasProduct: !!request.data?.product,
            productId: request.data?.product &&
                typeof request.data.product === "object" &&
                !Array.isArray(request.data.product)
                ? request.data.product.id ?? null
                : null,
            titleEn: request.data?.product &&
                typeof request.data.product === "object" &&
                !Array.isArray(request.data.product)
                ? request.data.product.titleEn ?? null
                : null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageProducts");
        const productInput = (0, callable_parsers_1.requireObjectRecord)(request.data?.product, "product");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        const sanitizedInput = sanitizeProductInput(productInput);
        const requestedId = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.id);
        const titleEn = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.titleEn);
        const slug = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.slug).toLowerCase();
        (0, callable_parsers_1.requireNonEmpty)(titleEn, "product.titleEn");
        (0, callable_parsers_1.requireNonEmpty)(slug, "product.slug");
        const productRef = requestedId.length > 0
            ? db.collection("products").doc(requestedId)
            : db.collection("products").doc();
        const productId = productRef.id;
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const existingSnap = await tx.get(productRef);
            if (existingSnap.exists) {
                throw new https_1.HttpsError("already-exists", "A product with this id already exists.");
            }
            const now = admin.firestore.FieldValue.serverTimestamp();
            const normalizedData = normalizeProductPayload(sanitizedInput, actor.uid, productId);
            const docData = {
                ...normalizedData,
                createdAt: sanitizedInput.createdAt ?? now,
                updatedAt: now,
            };
            tx.set(productRef, docData);
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
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
                    cardLayoutType: docData.cardLayoutType ?? "standard",
                },
                metadata: {
                    sku: docData.sku ?? null,
                    productCode: docData.productCode ?? null,
                    productType: docData.productType ?? null,
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
        logger.error("adminCreateProduct failed", {
            error,
            data: request.data ?? null,
            uid: request.auth?.uid ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to create product.");
    }
});
