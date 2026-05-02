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
exports.deleteBrand = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
const storage = admin.storage();
function parseExistingBrand(doc) {
    const data = doc.data() ?? {};
    return {
        id: doc.id,
        nameEn: (0, callable_parsers_1.asTrimmedString)(data.nameEn),
        nameBn: (0, callable_parsers_1.asTrimmedString)(data.nameBn),
        descriptionEn: (0, callable_parsers_1.asTrimmedString)(data.descriptionEn),
        descriptionBn: (0, callable_parsers_1.asTrimmedString)(data.descriptionBn),
        imageUrl: (0, callable_parsers_1.asTrimmedString)(data.imageUrl),
        logoUrl: (0, callable_parsers_1.asTrimmedString)(data.logoUrl),
        imagePath: (0, callable_parsers_1.asTrimmedString)(data.imagePath),
        thumbPath: (0, callable_parsers_1.asTrimmedString)(data.thumbPath),
        slug: (0, callable_parsers_1.asTrimmedString)(data.slug).toLowerCase(),
        isFeatured: (0, callable_parsers_1.asBool)(data.isFeatured, false),
        showOnHome: (0, callable_parsers_1.asBool)(data.showOnHome, false),
        isActive: (0, callable_parsers_1.asBool)(data.isActive, true),
        sortOrder: (0, callable_parsers_1.asInt)(data.sortOrder, 0),
        productsCount: (0, callable_parsers_1.asInt)(data.productsCount, 0),
        createdAt: data.createdAt ?? null,
        updatedAt: data.updatedAt ?? null,
    };
}
function buildAuditBeforeData(current) {
    return {
        id: current.id,
        nameEn: current.nameEn,
        nameBn: current.nameBn,
        descriptionEn: current.descriptionEn,
        descriptionBn: current.descriptionBn,
        imageUrl: current.imageUrl,
        logoUrl: current.logoUrl,
        imagePath: current.imagePath,
        thumbPath: current.thumbPath,
        slug: current.slug,
        isFeatured: current.isFeatured,
        showOnHome: current.showOnHome,
        isActive: current.isActive,
        sortOrder: current.sortOrder,
        productsCount: current.productsCount,
        createdAt: current.createdAt ?? null,
        updatedAt: current.updatedAt ?? null,
    };
}
function storagePathFromDownloadUrl(url) {
    const safeUrl = url.trim();
    if (safeUrl.length === 0)
        return "";
    try {
        const parsed = new URL(safeUrl);
        const marker = "/o/";
        const markerIndex = parsed.pathname.indexOf(marker);
        if (markerIndex < 0)
            return "";
        const encodedPath = parsed.pathname.substring(markerIndex + marker.length);
        return decodeURIComponent(encodedPath);
    }
    catch (_) {
        return "";
    }
}
function addStoragePath(paths, value) {
    const path = (0, callable_parsers_1.asTrimmedString)(value);
    if (path.length > 0)
        paths.add(path);
}
function addStoragePathFromUrl(paths, value) {
    const path = storagePathFromDownloadUrl((0, callable_parsers_1.asTrimmedString)(value));
    if (path.length > 0)
        paths.add(path);
}
function collectBrandStoragePaths(raw, current) {
    const paths = new Set();
    addStoragePath(paths, current.imagePath);
    addStoragePath(paths, current.thumbPath);
    addStoragePath(paths, raw.logoPath);
    addStoragePath(paths, raw.imageStoragePath);
    addStoragePath(paths, raw.thumbStoragePath);
    addStoragePath(paths, raw.logoStoragePath);
    addStoragePath(paths, raw.storagePath);
    addStoragePath(paths, raw.fullPath);
    addStoragePath(paths, raw.cardPath);
    addStoragePath(paths, raw.tinyPath);
    addStoragePath(paths, raw.fullStoragePath);
    addStoragePath(paths, raw.cardStoragePath);
    addStoragePath(paths, raw.tinyStoragePath);
    addStoragePathFromUrl(paths, current.imageUrl);
    addStoragePathFromUrl(paths, current.logoUrl);
    addStoragePathFromUrl(paths, raw.thumbUrl);
    addStoragePathFromUrl(paths, raw.fullUrl);
    addStoragePathFromUrl(paths, raw.cardUrl);
    addStoragePathFromUrl(paths, raw.tinyUrl);
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
        logger.warn("Failed to delete brand storage object", {
            path: safePath,
            error,
        });
    }
}
exports.deleteBrand = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageBrands");
        const brandId = (0, callable_parsers_1.asTrimmedString)(request.data?.brandId);
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(brandId, "brandId");
        const brandRef = db.collection("brands").doc(brandId);
        let auditLogId = "";
        let storagePathsToDelete = [];
        await db.runTransaction(async (tx) => {
            const currentSnap = await tx.get(brandRef);
            if (!currentSnap.exists) {
                throw new https_1.HttpsError("not-found", "Brand not found.");
            }
            const current = parseExistingBrand(currentSnap);
            if (current.productsCount > 0) {
                throw new https_1.HttpsError("failed-precondition", `This brand cannot be deleted because it contains ${current.productsCount} product(s).`);
            }
            const productsSnap = await tx.get(db.collection("products").where("brandId", "==", brandId).limit(1));
            if (!productsSnap.empty) {
                throw new https_1.HttpsError("failed-precondition", "This brand cannot be deleted because some products still reference it.");
            }
            tx.delete(brandRef);
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "delete_brand",
                module: "brands",
                targetType: "brand",
                targetId: brandId,
                targetTitle: current.nameEn,
                status: "success",
                reason,
                beforeData: buildAuditBeforeData(current),
                afterData: null,
                metadata: {
                    slug: current.slug,
                    imagePath: current.imagePath,
                    thumbPath: current.thumbPath,
                    storageCleanup: "logo_image_paths",
                },
                eventSource: "server_action",
            }));
            storagePathsToDelete = collectBrandStoragePaths(currentSnap.data() ?? {}, current);
        });
        for (const path of storagePathsToDelete) {
            await deleteStorageObjectIfExists(path);
        }
        return {
            success: true,
            brandId,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("deleteBrand failed", error);
        throw new https_1.HttpsError("internal", "Failed to delete brand.");
    }
});
