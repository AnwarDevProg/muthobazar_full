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
exports.setCategoryActiveState = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const db = admin.firestore();
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asNullableTrimmedString(value) {
    const normalized = asTrimmedString(value);
    return normalized.length === 0 ? null : normalized;
}
function asBoolOrThrow(value, fieldName) {
    if (typeof value === "boolean") {
        return value;
    }
    throw new https_1.HttpsError("invalid-argument", `${fieldName} must be a boolean.`);
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
function buildAuditState(category) {
    return {
        id: category.id,
        nameEn: category.nameEn,
        nameBn: category.nameBn,
        descriptionEn: category.descriptionEn,
        descriptionBn: category.descriptionBn,
        imageUrl: category.imageUrl,
        iconUrl: category.iconUrl,
        imagePath: category.imagePath,
        thumbPath: category.thumbPath,
        slug: category.slug,
        parentId: category.parentId ?? "",
        groupId: category.groupId,
        isFeatured: category.isFeatured,
        showOnHome: category.showOnHome,
        isActive: category.isActive,
        sortOrder: category.sortOrder,
        productsCount: category.productsCount,
    };
}
exports.setCategoryActiveState = (0, https_1.onCall)(async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageCategories");
        const categoryId = asTrimmedString(request.data?.categoryId);
        const nextIsActive = asBoolOrThrow(request.data?.isActive, "isActive");
        const reason = asNullableTrimmedString(request.data?.reason);
        requireNonEmpty(categoryId, "categoryId");
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const categoryRef = db.collection("categories").doc(categoryId);
            const existingSnap = await tx.get(categoryRef);
            if (!existingSnap.exists) {
                throw new https_1.HttpsError("not-found", "Category not found.");
            }
            const existing = parseCategoryState(existingSnap);
            if (existing.isActive === nextIsActive) {
                throw new https_1.HttpsError("failed-precondition", `Category is already ${nextIsActive ? "active" : "inactive"}.`);
            }
            const afterState = {
                ...existing,
                isActive: nextIsActive,
            };
            tx.set(categoryRef, {
                isActive: nextIsActive,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: nextIsActive
                    ? "activate_category"
                    : "deactivate_category",
                module: "categories",
                targetType: "category",
                targetId: categoryId,
                targetTitle: existing.nameEn,
                status: "success",
                reason,
                beforeData: buildAuditState(existing),
                afterData: buildAuditState(afterState),
                metadata: {
                    changedFields: ["isActive"],
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            categoryId,
            isActive: nextIsActive,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("setCategoryActiveState failed", error);
        throw new https_1.HttpsError("internal", "Failed to change category active state.");
    }
});
