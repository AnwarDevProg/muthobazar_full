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
exports.createBanner = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
const ALLOWED_TARGET_TYPES = new Set([
    "none",
    "product",
    "category",
    "brand",
    "route",
    "external",
]);
const ALLOWED_POSITIONS = new Set([
    "home_hero",
    "home_secondary",
    "home_strip",
    "category_top",
    "brand_top",
    "generic",
]);
function normalizeNullableString(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value);
    return normalized.length === 0 ? null : normalized;
}
function normalizeIsoDate(value, fieldName) {
    const raw = (0, callable_parsers_1.asTrimmedString)(value);
    if (raw.length === 0) {
        return null;
    }
    const parsed = new Date(raw);
    if (Number.isNaN(parsed.getTime())) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} must be a valid ISO datetime string.`);
    }
    return parsed.toISOString();
}
function normalizeTargetType(value) {
    const targetType = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    return targetType.length === 0 ? "none" : targetType;
}
function normalizePosition(value) {
    const position = (0, callable_parsers_1.asTrimmedString)(value);
    return position.length === 0 ? "home_hero" : position;
}
function validateTargetRequirements(targetType, targetId, targetRoute, externalUrl) {
    if (!ALLOWED_TARGET_TYPES.has(targetType)) {
        throw new https_1.HttpsError("invalid-argument", "banner.targetType is not supported.");
    }
    if ((targetType === "product" ||
        targetType === "category" ||
        targetType === "brand") &&
        !targetId) {
        throw new https_1.HttpsError("invalid-argument", "banner.targetId is required for product/category/brand target type.");
    }
    if (targetType === "route" && !targetRoute) {
        throw new https_1.HttpsError("invalid-argument", "banner.targetRoute is required for route target type.");
    }
    if (targetType === "external" && !externalUrl) {
        throw new https_1.HttpsError("invalid-argument", "banner.externalUrl is required for external target type.");
    }
}
function normalizeBannerPayload(input) {
    const raw = (0, callable_parsers_1.requireObjectRecord)(input, "banner");
    const titleEn = (0, callable_parsers_1.asTrimmedString)(raw.titleEn);
    (0, callable_parsers_1.requireNonEmpty)(titleEn, "banner.titleEn");
    const imageUrl = (0, callable_parsers_1.asTrimmedString)(raw.imageUrl);
    const mobileImageUrl = (0, callable_parsers_1.asTrimmedString)(raw.mobileImageUrl);
    (0, callable_parsers_1.requireNonEmpty)(imageUrl, "banner.imageUrl");
    (0, callable_parsers_1.requireNonEmpty)(mobileImageUrl, "banner.mobileImageUrl");
    const targetType = normalizeTargetType(raw.targetType);
    const targetId = normalizeNullableString(raw.targetId);
    const targetRoute = normalizeNullableString(raw.targetRoute);
    const externalUrl = normalizeNullableString(raw.externalUrl);
    validateTargetRequirements(targetType, targetId, targetRoute, externalUrl);
    const position = normalizePosition(raw.position);
    if (!ALLOWED_POSITIONS.has(position)) {
        throw new https_1.HttpsError("invalid-argument", "banner.position is not supported.");
    }
    const sortOrder = (0, callable_parsers_1.asInt)(raw.sortOrder, 0);
    (0, callable_parsers_1.requireNonNegativeInt)(sortOrder, "banner.sortOrder");
    const startAt = normalizeIsoDate(raw.startAt, "banner.startAt");
    const endAt = normalizeIsoDate(raw.endAt, "banner.endAt");
    if (startAt && endAt) {
        if (new Date(endAt).getTime() < new Date(startAt).getTime()) {
            throw new https_1.HttpsError("invalid-argument", "banner.endAt must be after banner.startAt.");
        }
    }
    return {
        titleEn,
        titleBn: (0, callable_parsers_1.asTrimmedString)(raw.titleBn),
        subtitleEn: (0, callable_parsers_1.asTrimmedString)(raw.subtitleEn),
        subtitleBn: (0, callable_parsers_1.asTrimmedString)(raw.subtitleBn),
        buttonTextEn: (0, callable_parsers_1.asTrimmedString)(raw.buttonTextEn),
        buttonTextBn: (0, callable_parsers_1.asTrimmedString)(raw.buttonTextBn),
        imageUrl,
        mobileImageUrl,
        targetType,
        targetId,
        targetRoute,
        externalUrl,
        isActive: (0, callable_parsers_1.asBool)(raw.isActive, true),
        showOnHome: (0, callable_parsers_1.asBool)(raw.showOnHome, true),
        position,
        sortOrder,
        startAt,
        endAt,
    };
}
function buildBannerDoc(bannerId, payload) {
    const now = admin.firestore.FieldValue.serverTimestamp();
    return {
        id: bannerId,
        titleEn: payload.titleEn,
        titleBn: payload.titleBn,
        subtitleEn: payload.subtitleEn,
        subtitleBn: payload.subtitleBn,
        buttonTextEn: payload.buttonTextEn,
        buttonTextBn: payload.buttonTextBn,
        imageUrl: payload.imageUrl,
        mobileImageUrl: payload.mobileImageUrl,
        targetType: payload.targetType,
        targetId: payload.targetId,
        targetRoute: payload.targetRoute,
        externalUrl: payload.externalUrl,
        isActive: payload.isActive,
        showOnHome: payload.showOnHome,
        position: payload.position,
        sortOrder: payload.sortOrder,
        startAt: payload.startAt,
        endAt: payload.endAt,
        createdAt: now,
        updatedAt: now,
    };
}
function buildAuditAfterData(bannerId, payload) {
    return {
        id: bannerId,
        titleEn: payload.titleEn,
        titleBn: payload.titleBn,
        subtitleEn: payload.subtitleEn,
        subtitleBn: payload.subtitleBn,
        buttonTextEn: payload.buttonTextEn,
        buttonTextBn: payload.buttonTextBn,
        imageUrl: payload.imageUrl,
        mobileImageUrl: payload.mobileImageUrl,
        targetType: payload.targetType,
        targetId: payload.targetId,
        targetRoute: payload.targetRoute,
        externalUrl: payload.externalUrl,
        isActive: payload.isActive,
        showOnHome: payload.showOnHome,
        position: payload.position,
        sortOrder: payload.sortOrder,
        startAt: payload.startAt,
        endAt: payload.endAt,
    };
}
exports.createBanner = (0, https_1.onCall)({
    region: "asia-south1",
}, async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageBanners");
        const payload = normalizeBannerPayload(request.data?.banner);
        const bannerRef = db.collection("banners").doc();
        const bannerId = bannerRef.id;
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const sortQuery = db
                .collection("banners")
                .where("sortOrder", "==", payload.sortOrder)
                .limit(1);
            const sortSnap = await tx.get(sortQuery);
            if (!sortSnap.empty) {
                throw new https_1.HttpsError("already-exists", "Sort number already exists for another banner. Please use another.");
            }
            tx.set(bannerRef, buildBannerDoc(bannerId, payload));
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "create_banner",
                module: "banners",
                targetType: "banner",
                targetId: bannerId,
                targetTitle: payload.titleEn,
                status: "success",
                beforeData: null,
                afterData: buildAuditAfterData(bannerId, payload),
                metadata: {
                    bannerTargetType: payload.targetType,
                    position: payload.position,
                    sortOrder: payload.sortOrder,
                    isActive: payload.isActive,
                    showOnHome: payload.showOnHome,
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            bannerId,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("createBanner failed", error);
        throw new https_1.HttpsError("internal", "Failed to create banner.");
    }
});
