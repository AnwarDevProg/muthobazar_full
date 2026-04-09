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
exports.createBrand = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function normalizeBrandPayload(input) {
    const raw = (0, callable_parsers_1.requireObjectRecord)(input, "brand");
    const nameEn = (0, callable_parsers_1.asTrimmedString)(raw.nameEn);
    const nameBn = (0, callable_parsers_1.asTrimmedString)(raw.nameBn);
    const descriptionEn = (0, callable_parsers_1.asTrimmedString)(raw.descriptionEn);
    const descriptionBn = (0, callable_parsers_1.asTrimmedString)(raw.descriptionBn);
    const imageUrl = (0, callable_parsers_1.asTrimmedString)(raw.imageUrl);
    const logoUrl = (0, callable_parsers_1.asTrimmedString)(raw.logoUrl);
    const imagePath = (0, callable_parsers_1.asTrimmedString)(raw.imagePath);
    const thumbPath = (0, callable_parsers_1.asTrimmedString)(raw.thumbPath);
    (0, callable_parsers_1.requireNonEmpty)(nameEn, "brand.nameEn");
    const normalizedSlug = (0, callable_parsers_1.slugify)((0, callable_parsers_1.asTrimmedString)(raw.slug).length > 0 ? (0, callable_parsers_1.asTrimmedString)(raw.slug) : nameEn);
    (0, callable_parsers_1.requireNonEmpty)(normalizedSlug, "brand.slug");
    const sortOrder = (0, callable_parsers_1.asInt)(raw.sortOrder, 0);
    (0, callable_parsers_1.requireNonNegativeInt)(sortOrder, "brand.sortOrder");
    if (imageUrl.length === 0 && logoUrl.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "brand.imageUrl or brand.logoUrl is required.");
    }
    return {
        nameEn,
        nameBn,
        descriptionEn,
        descriptionBn,
        imageUrl,
        logoUrl,
        imagePath,
        thumbPath,
        slug: normalizedSlug,
        isFeatured: (0, callable_parsers_1.asBool)(raw.isFeatured, false),
        showOnHome: (0, callable_parsers_1.asBool)(raw.showOnHome, false),
        isActive: (0, callable_parsers_1.asBool)(raw.isActive, true),
        sortOrder,
    };
}
function buildBrandDoc(brandId, payload) {
    return {
        id: brandId,
        nameEn: payload.nameEn,
        nameBn: payload.nameBn,
        descriptionEn: payload.descriptionEn,
        descriptionBn: payload.descriptionBn,
        imageUrl: payload.imageUrl,
        logoUrl: payload.logoUrl,
        imagePath: payload.imagePath,
        thumbPath: payload.thumbPath,
        slug: payload.slug,
        isFeatured: payload.isFeatured,
        showOnHome: payload.showOnHome,
        isActive: payload.isActive,
        sortOrder: payload.sortOrder,
        productsCount: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
}
function buildAuditAfterData(brandId, payload) {
    return {
        id: brandId,
        nameEn: payload.nameEn,
        nameBn: payload.nameBn,
        descriptionEn: payload.descriptionEn,
        descriptionBn: payload.descriptionBn,
        imageUrl: payload.imageUrl,
        logoUrl: payload.logoUrl,
        imagePath: payload.imagePath,
        thumbPath: payload.thumbPath,
        slug: payload.slug,
        isFeatured: payload.isFeatured,
        showOnHome: payload.showOnHome,
        isActive: payload.isActive,
        sortOrder: payload.sortOrder,
        productsCount: 0,
    };
}
function parseExistingBrand(doc) {
    const data = doc.data() ?? {};
    return {
        id: doc.id,
        nameEn: (0, callable_parsers_1.asTrimmedString)(data.nameEn),
        slug: (0, callable_parsers_1.asTrimmedString)(data.slug).toLowerCase(),
        sortOrder: (0, callable_parsers_1.asInt)(data.sortOrder, 0),
    };
}
exports.createBrand = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageBrands");
        const payload = normalizeBrandPayload(request.data?.brand);
        const brandRef = db.collection("brands").doc();
        const brandId = brandRef.id;
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const slugQuery = db
                .collection("brands")
                .where("slug", "==", payload.slug)
                .limit(1);
            const slugSnap = await tx.get(slugQuery);
            if (!slugSnap.empty) {
                throw new https_1.HttpsError("already-exists", "A brand with the same slug already exists.");
            }
            const sortQuery = db
                .collection("brands")
                .where("sortOrder", "==", payload.sortOrder)
                .limit(10);
            const sortSnap = await tx.get(sortQuery);
            const sortConflict = sortSnap.docs
                .map(parseExistingBrand)
                .find((item) => item.sortOrder === payload.sortOrder);
            if (sortConflict) {
                throw new https_1.HttpsError("already-exists", "Sort number already exists for another brand. Please use another.");
            }
            tx.set(brandRef, buildBrandDoc(brandId, payload));
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "create_brand",
                module: "brands",
                targetType: "brand",
                targetId: brandId,
                targetTitle: payload.nameEn,
                status: "success",
                beforeData: null,
                afterData: buildAuditAfterData(brandId, payload),
                metadata: {
                    sortOrder: payload.sortOrder,
                    isFeatured: payload.isFeatured,
                    showOnHome: payload.showOnHome,
                    isActive: payload.isActive,
                },
                eventSource: "server_action",
            }));
        });
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
        logger.error("createBrand failed", error);
        throw new https_1.HttpsError("internal", "Failed to create brand.");
    }
});
