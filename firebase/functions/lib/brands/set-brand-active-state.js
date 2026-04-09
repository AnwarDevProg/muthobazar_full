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
exports.setBrandActiveState = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function parseBrandState(doc) {
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
function buildAuditState(brand) {
    return {
        id: brand.id,
        nameEn: brand.nameEn,
        nameBn: brand.nameBn,
        descriptionEn: brand.descriptionEn,
        descriptionBn: brand.descriptionBn,
        imageUrl: brand.imageUrl,
        logoUrl: brand.logoUrl,
        imagePath: brand.imagePath,
        thumbPath: brand.thumbPath,
        slug: brand.slug,
        isFeatured: brand.isFeatured,
        showOnHome: brand.showOnHome,
        isActive: brand.isActive,
        sortOrder: brand.sortOrder,
        productsCount: brand.productsCount,
        createdAt: brand.createdAt ?? null,
        updatedAt: brand.updatedAt ?? null,
    };
}
exports.setBrandActiveState = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageBrands");
        const brandId = (0, callable_parsers_1.asTrimmedString)(request.data?.brandId);
        const nextIsActive = (0, callable_parsers_1.asBoolOrThrow)(request.data?.isActive, "isActive");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(brandId, "brandId");
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const brandRef = db.collection("brands").doc(brandId);
            const existingSnap = await tx.get(brandRef);
            if (!existingSnap.exists) {
                throw new https_1.HttpsError("not-found", "Brand not found.");
            }
            const existing = parseBrandState(existingSnap);
            if (existing.isActive === nextIsActive) {
                throw new https_1.HttpsError("failed-precondition", `Brand is already ${nextIsActive ? "active" : "inactive"}.`);
            }
            const afterState = {
                ...existing,
                isActive: nextIsActive,
            };
            tx.set(brandRef, {
                isActive: nextIsActive,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: nextIsActive ? "activate_brand" : "deactivate_brand",
                module: "brands",
                targetType: "brand",
                targetId: brandId,
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
            brandId,
            isActive: nextIsActive,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("setBrandActiveState failed", error);
        throw new https_1.HttpsError("internal", "Failed to update brand status.");
    }
});
