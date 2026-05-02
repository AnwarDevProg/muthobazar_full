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
exports.deleteCategory = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
const bucket = admin.storage().bucket();
function parseCategoryState(doc) {
    const data = doc.data() ?? {};
    const parentId = (0, callable_parsers_1.normalizeNullableId)(data.parentId);
    const explicitGroupId = (0, callable_parsers_1.asTrimmedString)(data.groupId);
    return {
        id: doc.id,
        nameEn: (0, callable_parsers_1.asTrimmedString)(data.nameEn),
        nameBn: (0, callable_parsers_1.asTrimmedString)(data.nameBn),
        descriptionEn: (0, callable_parsers_1.asTrimmedString)(data.descriptionEn),
        descriptionBn: (0, callable_parsers_1.asTrimmedString)(data.descriptionBn),
        imageUrl: (0, callable_parsers_1.asTrimmedString)(data.imageUrl),
        iconUrl: (0, callable_parsers_1.asTrimmedString)(data.iconUrl),
        imagePath: (0, callable_parsers_1.asTrimmedString)(data.imagePath),
        thumbPath: (0, callable_parsers_1.asTrimmedString)(data.thumbPath),
        slug: (0, callable_parsers_1.asTrimmedString)(data.slug).toLowerCase(),
        parentId,
        groupId: explicitGroupId.length > 0 ? explicitGroupId : (0, callable_parsers_1.groupIdFromParentId)(parentId),
        isFeatured: (0, callable_parsers_1.asBool)(data.isFeatured, false),
        showOnHome: (0, callable_parsers_1.asBool)(data.showOnHome, false),
        isActive: (0, callable_parsers_1.asBool)(data.isActive, true),
        sortOrder: (0, callable_parsers_1.asInt)(data.sortOrder, 0),
        productsCount: (0, callable_parsers_1.asInt)(data.productsCount, 0),
    };
}
function buildAuditBeforeState(existing) {
    return {
        id: existing.id,
        nameEn: existing.nameEn,
        nameBn: existing.nameBn,
        descriptionEn: existing.descriptionEn,
        descriptionBn: existing.descriptionBn,
        imageUrl: existing.imageUrl,
        iconUrl: existing.iconUrl,
        imagePath: existing.imagePath,
        thumbPath: existing.thumbPath,
        slug: existing.slug,
        parentId: existing.parentId ?? "",
        groupId: existing.groupId,
        isFeatured: existing.isFeatured,
        showOnHome: existing.showOnHome,
        isActive: existing.isActive,
        sortOrder: existing.sortOrder,
        productsCount: existing.productsCount,
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
function collectCategoryStoragePaths(raw, existing) {
    const paths = new Set();
    addStoragePath(paths, existing.imagePath);
    addStoragePath(paths, existing.thumbPath);
    addStoragePath(paths, raw.iconPath);
    addStoragePath(paths, raw.imageStoragePath);
    addStoragePath(paths, raw.thumbStoragePath);
    addStoragePath(paths, raw.iconStoragePath);
    addStoragePath(paths, raw.storagePath);
    addStoragePath(paths, raw.fullPath);
    addStoragePath(paths, raw.cardPath);
    addStoragePath(paths, raw.tinyPath);
    addStoragePath(paths, raw.fullStoragePath);
    addStoragePath(paths, raw.cardStoragePath);
    addStoragePath(paths, raw.tinyStoragePath);
    addStoragePathFromUrl(paths, existing.imageUrl);
    addStoragePathFromUrl(paths, existing.iconUrl);
    addStoragePathFromUrl(paths, raw.thumbUrl);
    addStoragePathFromUrl(paths, raw.fullUrl);
    addStoragePathFromUrl(paths, raw.cardUrl);
    addStoragePathFromUrl(paths, raw.tinyUrl);
    return Array.from(paths);
}
async function deleteStoragePath(path) {
    const normalized = path.trim();
    if (normalized.length === 0)
        return;
    try {
        await bucket.file(normalized).delete({ ignoreNotFound: true });
    }
    catch (error) {
        logger.warn(`Failed to delete storage object: ${normalized}`, error);
    }
}
exports.deleteCategory = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageCategories");
        const categoryId = (0, callable_parsers_1.asTrimmedString)(request.data?.categoryId);
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(categoryId, "categoryId");
        let auditLogId = "";
        let storagePathsToDelete = [];
        await db.runTransaction(async (tx) => {
            const categoryRef = db.collection("categories").doc(categoryId);
            const existingSnap = await tx.get(categoryRef);
            if (!existingSnap.exists) {
                throw new https_1.HttpsError("not-found", "Category not found.");
            }
            const existing = parseCategoryState(existingSnap);
            if (existing.productsCount > 0) {
                throw new https_1.HttpsError("failed-precondition", `This category cannot be deleted because it contains ${existing.productsCount} product(s).`);
            }
            const childQuery = db
                .collection("categories")
                .where("parentId", "==", categoryId)
                .limit(1);
            const childSnap = await tx.get(childQuery);
            if (!childSnap.empty) {
                throw new https_1.HttpsError("failed-precondition", "This category cannot be deleted because it has child categories.");
            }
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "delete_category",
                module: "categories",
                targetType: "category",
                targetId: categoryId,
                targetTitle: existing.nameEn,
                status: "success",
                reason,
                beforeData: buildAuditBeforeState(existing),
                afterData: null,
                metadata: {
                    groupId: existing.groupId,
                    parentId: existing.parentId ?? "",
                    productsCount: existing.productsCount,
                    imagePath: existing.imagePath,
                    thumbPath: existing.thumbPath,
                    storageCleanup: "image_icon_paths",
                },
                eventSource: "server_action",
            }));
            tx.delete(categoryRef);
            storagePathsToDelete = collectCategoryStoragePaths(existingSnap.data() ?? {}, existing);
        });
        for (const path of storagePathsToDelete) {
            await deleteStoragePath(path);
        }
        return {
            success: true,
            categoryId,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("deleteCategory failed", error);
        throw new https_1.HttpsError("internal", "Failed to delete category.");
    }
});
