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
exports.setBannerActiveState = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function parseBannerState(doc) {
    const data = doc.data() ?? {};
    return {
        id: doc.id,
        titleEn: (0, callable_parsers_1.asTrimmedString)(data.titleEn),
        titleBn: (0, callable_parsers_1.asTrimmedString)(data.titleBn),
        subtitleEn: (0, callable_parsers_1.asTrimmedString)(data.subtitleEn),
        subtitleBn: (0, callable_parsers_1.asTrimmedString)(data.subtitleBn),
        buttonTextEn: (0, callable_parsers_1.asTrimmedString)(data.buttonTextEn),
        buttonTextBn: (0, callable_parsers_1.asTrimmedString)(data.buttonTextBn),
        imageUrl: (0, callable_parsers_1.asTrimmedString)(data.imageUrl),
        mobileImageUrl: (0, callable_parsers_1.asTrimmedString)(data.mobileImageUrl),
        targetType: (0, callable_parsers_1.asTrimmedString)(data.targetType).toLowerCase(),
        targetId: (0, callable_parsers_1.normalizeNullableId)(data.targetId),
        targetRoute: (0, callable_parsers_1.normalizeNullableId)(data.targetRoute),
        externalUrl: (0, callable_parsers_1.normalizeNullableId)(data.externalUrl),
        isActive: (0, callable_parsers_1.asBool)(data.isActive, true),
        showOnHome: (0, callable_parsers_1.asBool)(data.showOnHome, true),
        position: (0, callable_parsers_1.asTrimmedString)(data.position),
        sortOrder: (0, callable_parsers_1.asInt)(data.sortOrder, 0),
        startAt: (0, callable_parsers_1.normalizeNullableId)(data.startAt),
        endAt: (0, callable_parsers_1.normalizeNullableId)(data.endAt),
        createdAt: data.createdAt ?? null,
        updatedAt: data.updatedAt ?? null,
    };
}
function buildAuditState(banner) {
    return {
        id: banner.id,
        titleEn: banner.titleEn,
        titleBn: banner.titleBn,
        subtitleEn: banner.subtitleEn,
        subtitleBn: banner.subtitleBn,
        buttonTextEn: banner.buttonTextEn,
        buttonTextBn: banner.buttonTextBn,
        imageUrl: banner.imageUrl,
        mobileImageUrl: banner.mobileImageUrl,
        targetType: banner.targetType,
        targetId: banner.targetId,
        targetRoute: banner.targetRoute,
        externalUrl: banner.externalUrl,
        isActive: banner.isActive,
        showOnHome: banner.showOnHome,
        position: banner.position,
        sortOrder: banner.sortOrder,
        startAt: banner.startAt,
        endAt: banner.endAt,
        createdAt: banner.createdAt ?? null,
        updatedAt: banner.updatedAt ?? null,
    };
}
exports.setBannerActiveState = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageBanners");
        const bannerId = (0, callable_parsers_1.asTrimmedString)(request.data?.bannerId);
        const nextIsActive = (0, callable_parsers_1.asBoolOrThrow)(request.data?.isActive, "isActive");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(bannerId, "bannerId");
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const bannerRef = db.collection("banners").doc(bannerId);
            const existingSnap = await tx.get(bannerRef);
            if (!existingSnap.exists) {
                throw new https_1.HttpsError("not-found", "Banner not found.");
            }
            const existing = parseBannerState(existingSnap);
            if (existing.isActive === nextIsActive) {
                throw new https_1.HttpsError("failed-precondition", `Banner is already ${nextIsActive ? "active" : "inactive"}.`);
            }
            const afterState = {
                ...existing,
                isActive: nextIsActive,
            };
            tx.set(bannerRef, {
                isActive: nextIsActive,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: nextIsActive ? "activate_banner" : "deactivate_banner",
                module: "banners",
                targetType: "banner",
                targetId: bannerId,
                targetTitle: existing.titleEn,
                status: "success",
                reason,
                beforeData: buildAuditState(existing),
                afterData: buildAuditState(afterState),
                metadata: {
                    changedFields: ["isActive"],
                    position: existing.position,
                    sortOrder: existing.sortOrder,
                    showOnHome: existing.showOnHome,
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            bannerId,
            isActive: nextIsActive,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("setBannerActiveState failed", error);
        throw new https_1.HttpsError("internal", "Failed to change banner active state.");
    }
});
