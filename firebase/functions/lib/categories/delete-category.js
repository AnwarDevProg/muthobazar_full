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
const db = admin.firestore();
const bucket = admin.storage().bucket();
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asNullableTrimmedString(value) {
    const normalized = asTrimmedString(value);
    return normalized.length === 0 ? null : normalized;
}
function asInt(value, defaultValue = 0) {
    if (typeof value === "number" && Number.isFinite(value)) {
        return Math.trunc(value);
    }
    const parsed = Number.parseInt(String(value ?? "").trim(), 10);
    return Number.isNaN(parsed) ? defaultValue : parsed;
}
function requireNonEmpty(value, fieldName) {
    if (value.length === 0) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} is required.`);
    }
}
function normalizeParentId(value) {
    const normalized = asTrimmedString(value);
    return normalized.length === 0 ? null : normalized;
}
function groupIdFromParentId(parentId) {
    return parentId == null || parentId.length === 0 ? "root" : parentId;
}
function parseCategoryState(doc) {
    const data = doc.data() ?? {};
    const parentId = normalizeParentId(data.parentId);
    const explicitGroupId = asTrimmedString(data.groupId);
    return {
        id: doc.id,
        nameEn: asTrimmedString(data.nameEn),
        nameBn: asTrimmedString(data.nameBn),
        descriptionEn: asTrimmedString(data.descriptionEn),
        descriptionBn: asTrimmedString(data.descriptionBn),
        imageUrl: asTrimmedString(data.imageUrl),
        iconUrl: asTrimmedString(data.iconUrl),
        imagePath: asTrimmedString(data.imagePath),
        thumbPath: asTrimmedString(data.thumbPath),
        slug: asTrimmedString(data.slug).toLowerCase(),
        parentId,
        groupId: explicitGroupId.length > 0 ? explicitGroupId : groupIdFromParentId(parentId),
        isFeatured: data.isFeatured === true,
        showOnHome: data.showOnHome === true,
        isActive: data.isActive !== false,
        sortOrder: asInt(data.sortOrder, 0),
        productsCount: asInt(data.productsCount, 0),
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
exports.deleteCategory = (0, https_1.onCall)(async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageCategories");
        const categoryId = asTrimmedString(request.data?.categoryId);
        const reason = asNullableTrimmedString(request.data?.reason);
        requireNonEmpty(categoryId, "categoryId");
        let auditLogId = "";
        let imagePathToDelete = "";
        let thumbPathToDelete = "";
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
                },
                eventSource: "server_action",
            }));
            tx.delete(categoryRef);
            imagePathToDelete = existing.imagePath;
            if (existing.thumbPath.length > 0 &&
                existing.thumbPath !== existing.imagePath) {
                thumbPathToDelete = existing.thumbPath;
            }
        });
        await deleteStoragePath(imagePathToDelete);
        await deleteStoragePath(thumbPathToDelete);
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
