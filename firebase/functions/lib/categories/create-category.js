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
exports.createCategory = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const db = admin.firestore();
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asBool(value, defaultValue = false) {
    if (typeof value === "boolean")
        return value;
    if (typeof value === "string") {
        const normalized = value.trim().toLowerCase();
        if (normalized === "true")
            return true;
        if (normalized === "false")
            return false;
    }
    return defaultValue;
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
function slugify(value) {
    return value
        .toLowerCase()
        .trim()
        .replace(/&/g, " and ")
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .replace(/-{2,}/g, "-");
}
function normalizeCategoryPayload(input) {
    if (!input || typeof input !== "object" || Array.isArray(input)) {
        throw new https_1.HttpsError("invalid-argument", "category payload is required.");
    }
    const raw = input;
    const nameEn = asTrimmedString(raw.nameEn);
    const nameBn = asTrimmedString(raw.nameBn);
    const descriptionEn = asTrimmedString(raw.descriptionEn);
    const descriptionBn = asTrimmedString(raw.descriptionBn);
    const imageUrl = asTrimmedString(raw.imageUrl);
    const iconUrl = asTrimmedString(raw.iconUrl);
    const imagePath = asTrimmedString(raw.imagePath);
    const thumbPath = asTrimmedString(raw.thumbPath);
    const parentId = normalizeParentId(raw.parentId);
    requireNonEmpty(nameEn, "category.nameEn");
    const normalizedSlug = slugify(asTrimmedString(raw.slug).length > 0 ? asTrimmedString(raw.slug) : nameEn);
    requireNonEmpty(normalizedSlug, "category.slug");
    const sortOrder = asInt(raw.sortOrder, 0);
    if (sortOrder < 0) {
        throw new https_1.HttpsError("invalid-argument", "category.sortOrder must be 0 or greater.");
    }
    return {
        nameEn,
        nameBn,
        descriptionEn,
        descriptionBn,
        imageUrl,
        iconUrl,
        imagePath,
        thumbPath,
        slug: normalizedSlug,
        parentId,
        isFeatured: asBool(raw.isFeatured, false),
        showOnHome: asBool(raw.showOnHome, false),
        isActive: asBool(raw.isActive, true),
        sortOrder,
    };
}
function buildCategoryDoc(categoryId, payload) {
    return {
        id: categoryId,
        nameEn: payload.nameEn,
        nameBn: payload.nameBn,
        descriptionEn: payload.descriptionEn,
        descriptionBn: payload.descriptionBn,
        imageUrl: payload.imageUrl,
        iconUrl: payload.iconUrl,
        imagePath: payload.imagePath,
        thumbPath: payload.thumbPath,
        slug: payload.slug,
        parentId: payload.parentId ?? "",
        groupId: groupIdFromParentId(payload.parentId),
        isFeatured: payload.isFeatured,
        showOnHome: payload.showOnHome,
        isActive: payload.isActive,
        sortOrder: payload.sortOrder,
        productsCount: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
}
function buildAuditAfterData(categoryId, payload) {
    return {
        id: categoryId,
        nameEn: payload.nameEn,
        nameBn: payload.nameBn,
        descriptionEn: payload.descriptionEn,
        descriptionBn: payload.descriptionBn,
        imageUrl: payload.imageUrl,
        iconUrl: payload.iconUrl,
        imagePath: payload.imagePath,
        thumbPath: payload.thumbPath,
        slug: payload.slug,
        parentId: payload.parentId ?? "",
        groupId: groupIdFromParentId(payload.parentId),
        isFeatured: payload.isFeatured,
        showOnHome: payload.showOnHome,
        isActive: payload.isActive,
        sortOrder: payload.sortOrder,
        productsCount: 0,
    };
}
function parseExistingCategory(doc) {
    const data = doc.data() ?? {};
    return {
        id: doc.id,
        nameEn: String(data.nameEn ?? "").trim(),
        slug: String(data.slug ?? "").trim().toLowerCase(),
        sortOrder: asInt(data.sortOrder, 0),
    };
}
exports.createCategory = (0, https_1.onCall)(async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageCategories");
        const payload = normalizeCategoryPayload(request.data?.category);
        const categoryRef = db.collection("categories").doc();
        const categoryId = categoryRef.id;
        const groupId = groupIdFromParentId(payload.parentId);
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            if (payload.parentId) {
                const parentRef = db.collection("categories").doc(payload.parentId);
                const parentSnap = await tx.get(parentRef);
                if (!parentSnap.exists) {
                    throw new https_1.HttpsError("failed-precondition", "Selected parent category was not found.");
                }
            }
            const slugQuery = db
                .collection("categories")
                .where("slug", "==", payload.slug)
                .limit(1);
            const slugSnap = await tx.get(slugQuery);
            if (!slugSnap.empty) {
                throw new https_1.HttpsError("already-exists", "A category with the same slug already exists.");
            }
            const groupQuery = db
                .collection("categories")
                .where("groupId", "==", groupId);
            const groupSnap = await tx.get(groupQuery);
            const siblings = groupSnap.docs.map(parseExistingCategory);
            const sortConflict = siblings.find((item) => item.sortOrder === payload.sortOrder);
            if (sortConflict) {
                throw new https_1.HttpsError("already-exists", "Sort number already exists in this group. Please use another.");
            }
            tx.set(categoryRef, buildCategoryDoc(categoryId, payload));
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "create_category",
                module: "categories",
                targetType: "category",
                targetId: categoryId,
                targetTitle: payload.nameEn,
                status: "success",
                beforeData: null,
                afterData: buildAuditAfterData(categoryId, payload),
                metadata: {
                    parentId: payload.parentId ?? "",
                    groupId,
                    sortOrder: payload.sortOrder,
                },
                eventSource: "server_action",
            }));
        });
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
        logger.error("createCategory failed", error);
        throw new https_1.HttpsError("internal", "Failed to create category.");
    }
});
