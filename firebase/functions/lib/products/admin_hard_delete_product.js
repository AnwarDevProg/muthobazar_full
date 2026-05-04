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
exports.adminHardDeleteProduct = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
const storage = admin.storage();
function asBool(value, fallback = false) {
    return typeof value === "boolean" ? value : fallback;
}
function asStringList(value) {
    if (!Array.isArray(value))
        return [];
    return value
        .map((item) => (0, callable_parsers_1.asTrimmedString)(item))
        .filter((item) => item.length > 0);
}
function asObjectList(value) {
    if (!Array.isArray(value))
        return [];
    return value.filter((item) => typeof item === "object" && item !== null && !Array.isArray(item));
}
function normalizeCardLayoutType(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    return normalized.length > 0 ? normalized : "standard";
}
function parseExistingProduct(doc) {
    const data = (doc.data() ?? {});
    return {
        id: doc.id,
        titleEn: (0, callable_parsers_1.asTrimmedString)(data.titleEn),
        titleBn: (0, callable_parsers_1.asTrimmedString)(data.titleBn),
        slug: (0, callable_parsers_1.asTrimmedString)(data.slug).toLowerCase(),
        sku: (0, callable_parsers_1.asTrimmedString)(data.sku),
        productCode: (0, callable_parsers_1.asTrimmedString)(data.productCode),
        categoryId: (0, callable_parsers_1.asTrimmedString)(data.categoryId),
        categoryNameEn: (0, callable_parsers_1.asTrimmedString)(data.categoryNameEn),
        categoryNameBn: (0, callable_parsers_1.asTrimmedString)(data.categoryNameBn),
        brandId: (0, callable_parsers_1.asTrimmedString)(data.brandId),
        brandNameEn: (0, callable_parsers_1.asTrimmedString)(data.brandNameEn),
        brandNameBn: (0, callable_parsers_1.asTrimmedString)(data.brandNameBn),
        productType: (0, callable_parsers_1.asTrimmedString)(data.productType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.productType)
            : "simple",
        inventoryMode: (0, callable_parsers_1.asTrimmedString)(data.inventoryMode).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.inventoryMode)
            : "stocked",
        schedulePriceType: (0, callable_parsers_1.asTrimmedString)(data.schedulePriceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.schedulePriceType)
            : "fixed",
        quantityType: (0, callable_parsers_1.asTrimmedString)(data.quantityType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.quantityType)
            : "pcs",
        toleranceType: (0, callable_parsers_1.asTrimmedString)(data.toleranceType).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.toleranceType)
            : "g",
        deliveryShift: (0, callable_parsers_1.asTrimmedString)(data.deliveryShift).length > 0
            ? (0, callable_parsers_1.asTrimmedString)(data.deliveryShift)
            : "any",
        cardLayoutType: normalizeCardLayoutType(data.cardLayoutType),
        isEnabled: asBool(data.isEnabled, true),
        isDeleted: asBool(data.isDeleted, false),
        mediaItems: asObjectList(data.mediaItems),
        variations: asObjectList(data.variations),
        thumbnailUrl: (0, callable_parsers_1.asTrimmedString)(data.thumbnailUrl),
        imageUrls: asStringList(data.imageUrls),
        rawData: data,
        createdAt: data.createdAt ?? null,
        updatedAt: data.updatedAt ?? null,
        deletedAt: data.deletedAt ?? null,
        deletedBy: data.deletedBy ?? null,
        deleteReason: data.deleteReason ?? null,
    };
}
function buildAuditBeforeData(current) {
    return {
        id: current.id,
        titleEn: current.titleEn,
        titleBn: current.titleBn,
        slug: current.slug,
        sku: current.sku,
        productCode: current.productCode,
        categoryId: current.categoryId,
        categoryNameEn: current.categoryNameEn,
        categoryNameBn: current.categoryNameBn,
        brandId: current.brandId,
        brandNameEn: current.brandNameEn,
        brandNameBn: current.brandNameBn,
        productType: current.productType,
        inventoryMode: current.inventoryMode,
        schedulePriceType: current.schedulePriceType,
        quantityType: current.quantityType,
        toleranceType: current.toleranceType,
        deliveryShift: current.deliveryShift,
        cardLayoutType: current.cardLayoutType,
        isEnabled: current.isEnabled,
        isDeleted: current.isDeleted,
        mediaItems: current.mediaItems,
        variations: current.variations,
        thumbnailUrl: current.thumbnailUrl,
        imageUrls: current.imageUrls,
        createdAt: current.createdAt ?? null,
        updatedAt: current.updatedAt ?? null,
        deletedAt: current.deletedAt ?? null,
        deletedBy: current.deletedBy ?? null,
        deleteReason: current.deleteReason ?? null,
    };
}
function addStoragePath(paths, value) {
    const path = (0, callable_parsers_1.asTrimmedString)(value);
    if (!path)
        return;
    if (path.startsWith("http://") || path.startsWith("https://"))
        return;
    if (path.startsWith("gs://")) {
        const parsed = parseStoragePathFromUrl(path);
        if (parsed)
            paths.add(parsed);
        return;
    }
    paths.add(path);
}
function addStoragePathFromUrl(paths, value) {
    const parsed = parseStoragePathFromUrl((0, callable_parsers_1.asTrimmedString)(value));
    if (parsed)
        paths.add(parsed);
}
function parseStoragePathFromUrl(value) {
    const url = value.trim();
    if (!url)
        return "";
    if (url.startsWith("gs://")) {
        const withoutScheme = url.replace(/^gs:\/\//, "");
        const firstSlash = withoutScheme.indexOf("/");
        if (firstSlash < 0)
            return "";
        return withoutScheme.substring(firstSlash + 1).trim();
    }
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
        return url;
    }
    try {
        const parsed = new URL(url);
        const objectMarker = "/o/";
        const markerIndex = parsed.pathname.indexOf(objectMarker);
        if (markerIndex < 0)
            return "";
        const encodedPath = parsed.pathname.substring(markerIndex + objectMarker.length);
        if (!encodedPath)
            return "";
        return decodeURIComponent(encodedPath).trim();
    }
    catch (error) {
        logger.warn("Failed to parse Firebase Storage URL", {
            url,
            error,
        });
        return "";
    }
}
function collectMediaStoragePaths(paths, item) {
    // Legacy/generic path fields.
    addStoragePath(paths, item.storagePath);
    addStoragePath(paths, item.imageStoragePath);
    addStoragePath(paths, item.imagePath);
    addStoragePath(paths, item.thumbnailStoragePath);
    addStoragePath(paths, item.thumbnailPath);
    addStoragePath(paths, item.thumbPath);
    // New generated image path fields.
    addStoragePath(paths, item.originalStoragePath);
    addStoragePath(paths, item.originalPath);
    addStoragePath(paths, item.fullStoragePath);
    addStoragePath(paths, item.fullPath);
    addStoragePath(paths, item.cardStoragePath);
    addStoragePath(paths, item.cardPath);
    addStoragePath(paths, item.thumbStoragePath);
    addStoragePath(paths, item.tinyStoragePath);
    addStoragePath(paths, item.tinyPath);
    // URL fallbacks for old records or partially migrated records.
    addStoragePathFromUrl(paths, item.url);
    addStoragePathFromUrl(paths, item.imageUrl);
    addStoragePathFromUrl(paths, item.thumbnailUrl);
    addStoragePathFromUrl(paths, item.originalUrl);
    addStoragePathFromUrl(paths, item.fullUrl);
    addStoragePathFromUrl(paths, item.cardUrl);
    addStoragePathFromUrl(paths, item.thumbUrl);
    addStoragePathFromUrl(paths, item.tinyUrl);
}
function collectRootStoragePaths(paths, data) {
    // Root legacy/generic paths.
    addStoragePath(paths, data.storagePath);
    addStoragePath(paths, data.imageStoragePath);
    addStoragePath(paths, data.imagePath);
    addStoragePath(paths, data.thumbnailStoragePath);
    addStoragePath(paths, data.thumbnailPath);
    addStoragePath(paths, data.thumbPath);
    // Root generated-image paths, if ever stored directly on product.
    addStoragePath(paths, data.originalStoragePath);
    addStoragePath(paths, data.originalPath);
    addStoragePath(paths, data.fullStoragePath);
    addStoragePath(paths, data.fullPath);
    addStoragePath(paths, data.cardStoragePath);
    addStoragePath(paths, data.cardPath);
    addStoragePath(paths, data.thumbStoragePath);
    addStoragePath(paths, data.tinyStoragePath);
    addStoragePath(paths, data.tinyPath);
    // Root URL fallbacks.
    addStoragePathFromUrl(paths, data.url);
    addStoragePathFromUrl(paths, data.imageUrl);
    addStoragePathFromUrl(paths, data.thumbnailUrl);
    addStoragePathFromUrl(paths, data.originalUrl);
    addStoragePathFromUrl(paths, data.fullUrl);
    addStoragePathFromUrl(paths, data.cardUrl);
    addStoragePathFromUrl(paths, data.thumbUrl);
    addStoragePathFromUrl(paths, data.tinyUrl);
    for (const imageUrl of asStringList(data.imageUrls)) {
        addStoragePathFromUrl(paths, imageUrl);
    }
}
function collectVariationStoragePaths(paths, variation) {
    // Variation legacy/generic fields.
    addStoragePath(paths, variation.imageStoragePath);
    addStoragePath(paths, variation.originalImageStoragePath);
    addStoragePath(paths, variation.thumbImageStoragePath);
    addStoragePath(paths, variation.fullImageStoragePath);
    addStoragePath(paths, variation.cardImageStoragePath);
    addStoragePath(paths, variation.tinyImageStoragePath);
    addStoragePath(paths, variation.storagePath);
    addStoragePath(paths, variation.imagePath);
    addStoragePath(paths, variation.originalImagePath);
    addStoragePath(paths, variation.thumbImagePath);
    addStoragePath(paths, variation.fullImagePath);
    addStoragePath(paths, variation.cardImagePath);
    addStoragePath(paths, variation.tinyImagePath);
    addStoragePath(paths, variation.thumbPath);
    // Variation generated-image fields.
    addStoragePath(paths, variation.originalStoragePath);
    addStoragePath(paths, variation.originalPath);
    addStoragePath(paths, variation.fullStoragePath);
    addStoragePath(paths, variation.fullPath);
    addStoragePath(paths, variation.cardStoragePath);
    addStoragePath(paths, variation.cardPath);
    addStoragePath(paths, variation.thumbStoragePath);
    addStoragePath(paths, variation.tinyStoragePath);
    addStoragePath(paths, variation.tinyPath);
    // Variation URL fallbacks.
    addStoragePathFromUrl(paths, variation.imageUrl);
    addStoragePathFromUrl(paths, variation.originalImageUrl);
    addStoragePathFromUrl(paths, variation.thumbImageUrl);
    addStoragePathFromUrl(paths, variation.fullImageUrl);
    addStoragePathFromUrl(paths, variation.cardImageUrl);
    addStoragePathFromUrl(paths, variation.tinyImageUrl);
    addStoragePathFromUrl(paths, variation.url);
    addStoragePathFromUrl(paths, variation.thumbnailUrl);
    addStoragePathFromUrl(paths, variation.originalUrl);
    addStoragePathFromUrl(paths, variation.fullUrl);
    addStoragePathFromUrl(paths, variation.cardUrl);
    addStoragePathFromUrl(paths, variation.thumbUrl);
    addStoragePathFromUrl(paths, variation.tinyUrl);
    for (const media of asObjectList(variation.mediaItems)) {
        collectMediaStoragePaths(paths, media);
    }
}
function collectStoragePaths(current) {
    const paths = new Set();
    collectRootStoragePaths(paths, current.rawData);
    for (const item of current.mediaItems) {
        collectMediaStoragePaths(paths, item);
    }
    for (const variation of current.variations) {
        collectVariationStoragePaths(paths, variation);
    }
    return Array.from(paths).sort();
}
async function deleteStorageObjectIfExists(path) {
    const safePath = path.trim();
    if (!safePath) {
        return {
            path: safePath,
            success: false,
            errorMessage: "Empty storage path.",
        };
    }
    try {
        await storage.bucket().file(safePath).delete({ ignoreNotFound: true });
        return {
            path: safePath,
            success: true,
        };
    }
    catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        logger.warn("Failed to delete product storage object", {
            path: safePath,
            error,
        });
        return {
            path: safePath,
            success: false,
            errorMessage,
        };
    }
}
exports.adminHardDeleteProduct = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminHardDeleteProduct invoked", {
            uid: request.auth?.uid ?? null,
            productId: request.data?.productId ?? null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canDeleteProducts");
        // Hard delete is only allowed from quarantine context.
        // Require restore permission too so direct callable access
        // cannot bypass the quarantine access policy.
        await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canRestoreProducts");
        const productId = (0, callable_parsers_1.asTrimmedString)(request.data?.productId);
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(productId, "productId");
        const productRef = db.collection("products").doc(productId);
        let auditLogId = "";
        let auditLogRefPath = "";
        let storagePathsToDelete = [];
        await db.runTransaction(async (tx) => {
            const currentSnap = await tx.get(productRef);
            if (!currentSnap.exists) {
                throw new https_1.HttpsError("not-found", "Product not found.");
            }
            const current = parseExistingProduct(currentSnap);
            if (!current.isDeleted) {
                throw new https_1.HttpsError("failed-precondition", "Only quarantine products can be permanently deleted.");
            }
            tx.delete(productRef);
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            auditLogRefPath = logRef.path;
            const storagePaths = collectStoragePaths(current);
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "hard_delete_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: current.titleEn || productId,
                status: "success",
                reason,
                beforeData: buildAuditBeforeData(current),
                afterData: null,
                metadata: {
                    slug: current.slug,
                    sku: current.sku,
                    productCode: current.productCode,
                    categoryId: current.categoryId,
                    brandId: current.brandId,
                    productType: current.productType,
                    cardLayoutType: current.cardLayoutType,
                    deletedAt: current.deletedAt ?? null,
                    wasQuarantined: current.isDeleted,
                    storageCleanup: "product_media_and_variation_media",
                    storageCleanupStatus: "pending",
                    storagePathsCount: storagePaths.length,
                    storageCleanupAttemptedCount: 0,
                    storageCleanupDeletedCount: 0,
                    storageCleanupFailedCount: 0,
                    failedStoragePaths: [],
                },
                eventSource: "server_action",
            }));
            storagePathsToDelete = storagePaths;
        });
        const storageDeleteResults = [];
        for (const path of storagePathsToDelete) {
            storageDeleteResults.push(await deleteStorageObjectIfExists(path));
        }
        const failedStorageResults = storageDeleteResults.filter((result) => !result.success);
        const failedStoragePaths = failedStorageResults.map((result) => result.path);
        const deletedStorageCount = storageDeleteResults.filter((result) => result.success).length;
        const failedStorageCount = failedStorageResults.length;
        const storageCleanupStatus = failedStorageCount > 0 ? "partial_failed" : "success";
        if (auditLogRefPath) {
            try {
                await db.doc(auditLogRefPath).update({
                    "metadata.storageCleanupStatus": storageCleanupStatus,
                    "metadata.storageCleanupAttemptedCount": storagePathsToDelete.length,
                    "metadata.storageCleanupDeletedCount": deletedStorageCount,
                    "metadata.storageCleanupFailedCount": failedStorageCount,
                    "metadata.failedStoragePaths": failedStoragePaths,
                });
            }
            catch (error) {
                logger.warn("Failed to update hard delete storage cleanup metadata", {
                    productId,
                    auditLogId,
                    error,
                });
            }
        }
        logger.info("adminHardDeleteProduct storage cleanup complete", {
            productId,
            attemptedStorageCount: storagePathsToDelete.length,
            deletedStorageCount,
            failedStorageCount,
            failedStoragePaths,
        });
        return {
            success: true,
            productId,
            auditLogId,
            attemptedStorageCount: storagePathsToDelete.length,
            deletedStorageCount,
            failedStorageCount,
            failedStoragePaths,
            storageCleanupStatus,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminHardDeleteProduct failed", {
            error,
            uid: request.auth?.uid ?? null,
            data: request.data ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to hard delete product.");
    }
});
