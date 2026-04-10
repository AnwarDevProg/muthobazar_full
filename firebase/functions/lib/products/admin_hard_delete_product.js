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
function parseExistingProduct(doc) {
    const data = doc.data() ?? {};
    return {
        id: doc.id,
        titleEn: (0, callable_parsers_1.asTrimmedString)(data.titleEn),
        titleBn: (0, callable_parsers_1.asTrimmedString)(data.titleBn),
        slug: (0, callable_parsers_1.asTrimmedString)(data.slug).toLowerCase(),
        sku: (0, callable_parsers_1.asTrimmedString)(data.sku),
        productCode: (0, callable_parsers_1.asTrimmedString)(data.productCode),
        categoryId: (0, callable_parsers_1.asTrimmedString)(data.categoryId),
        categoryNameEn: (0, callable_parsers_1.asTrimmedString)(data.categoryNameEn),
        brandId: (0, callable_parsers_1.asTrimmedString)(data.brandId),
        brandNameEn: (0, callable_parsers_1.asTrimmedString)(data.brandNameEn),
        isEnabled: asBool(data.isEnabled, true),
        isDeleted: asBool(data.isDeleted, false),
        mediaItems: asObjectList(data.mediaItems),
        thumbnailUrl: (0, callable_parsers_1.asTrimmedString)(data.thumbnailUrl),
        imageUrls: asStringList(data.imageUrls),
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
        brandId: current.brandId,
        brandNameEn: current.brandNameEn,
        isEnabled: current.isEnabled,
        isDeleted: current.isDeleted,
        mediaItems: current.mediaItems,
        thumbnailUrl: current.thumbnailUrl,
        imageUrls: current.imageUrls,
        createdAt: current.createdAt ?? null,
        updatedAt: current.updatedAt ?? null,
        deletedAt: current.deletedAt ?? null,
        deletedBy: current.deletedBy ?? null,
        deleteReason: current.deleteReason ?? null,
    };
}
function collectStoragePaths(current) {
    const paths = new Set();
    for (const item of current.mediaItems) {
        const path = (0, callable_parsers_1.asTrimmedString)(item["storagePath"]);
        if (path.length > 0) {
            paths.add(path);
        }
    }
    return Array.from(paths);
}
async function deleteStorageObjectIfExists(path) {
    const safePath = path.trim();
    if (!safePath)
        return;
    try {
        await storage.bucket().file(safePath).delete({ ignoreNotFound: true });
    }
    catch (error) {
        logger.warn("Failed to delete product storage object", {
            path: safePath,
            error,
        });
    }
}
exports.adminHardDeleteProduct = (0, https_1.onCall)(async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canRestoreProducts");
        const productId = (0, callable_parsers_1.asTrimmedString)(request.data?.productId);
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(productId, "productId");
        const productRef = db.collection("products").doc(productId);
        let auditLogId = "";
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
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "hard_delete_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: current.titleEn,
                status: "success",
                reason,
                beforeData: buildAuditBeforeData(current),
                afterData: null,
                metadata: {
                    slug: current.slug,
                    sku: current.sku,
                    categoryId: current.categoryId,
                    brandId: current.brandId,
                    deletedAt: current.deletedAt,
                    wasQuarantined: current.isDeleted,
                    storagePathsCount: collectStoragePaths(current).length,
                },
                eventSource: "server_action",
            }));
            storagePathsToDelete = collectStoragePaths(current);
        });
        for (const path of storagePathsToDelete) {
            await deleteStorageObjectIfExists(path);
        }
        return {
            success: true,
            productId,
            auditLogId,
            deletedStorageCount: storagePathsToDelete.length,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminHardDeleteProduct failed", error);
        throw new https_1.HttpsError("internal", "Failed to hard delete product.");
    }
});
