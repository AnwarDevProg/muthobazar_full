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
exports.adminCreateProduct = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function sanitizeFirestoreValue(value) {
    if (value === undefined)
        return undefined;
    if (value === null ||
        typeof value === "string" ||
        typeof value === "number" ||
        typeof value === "boolean") {
        return value;
    }
    if (value instanceof Date ||
        value instanceof admin.firestore.Timestamp ||
        value instanceof admin.firestore.GeoPoint ||
        value instanceof admin.firestore.DocumentReference ||
        value instanceof admin.firestore.FieldValue) {
        return value;
    }
    if (Array.isArray(value)) {
        return value
            .map((item) => sanitizeFirestoreValue(item))
            .filter((item) => item !== undefined);
    }
    if (typeof value === "object") {
        const input = value;
        const output = {};
        for (const [key, rawValue] of Object.entries(input)) {
            if (key.startsWith("clear"))
                continue;
            const sanitized = sanitizeFirestoreValue(rawValue);
            if (sanitized !== undefined) {
                output[key] = sanitized;
            }
        }
        return output;
    }
    return undefined;
}
function sanitizeProductInput(input) {
    const sanitized = sanitizeFirestoreValue(input);
    if (!sanitized || typeof sanitized !== "object" || Array.isArray(sanitized)) {
        return {};
    }
    return sanitized;
}
function asBool(value, fallback = false) {
    return typeof value === "boolean" ? value : fallback;
}
exports.adminCreateProduct = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminCreateProduct invoked", {
            uid: request.auth?.uid ?? null,
            hasData: !!request.data,
            hasProduct: !!request.data?.product,
            productId: request.data?.product &&
                typeof request.data.product === "object" &&
                !Array.isArray(request.data.product)
                ? request.data.product.id ?? null
                : null,
            titleEn: request.data?.product &&
                typeof request.data.product === "object" &&
                !Array.isArray(request.data.product)
                ? request.data.product.titleEn ?? null
                : null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageProducts");
        const productInput = (0, callable_parsers_1.requireObjectRecord)(request.data?.product, "product");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        const sanitizedInput = sanitizeProductInput(productInput);
        const requestedId = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.id);
        const titleEn = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.titleEn);
        const slug = (0, callable_parsers_1.asTrimmedString)(sanitizedInput.slug).toLowerCase();
        (0, callable_parsers_1.requireNonEmpty)(titleEn, "product.titleEn");
        (0, callable_parsers_1.requireNonEmpty)(slug, "product.slug");
        const productRef = requestedId.length > 0
            ? db.collection("products").doc(requestedId)
            : db.collection("products").doc();
        const productId = productRef.id;
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const existingSnap = await tx.get(productRef);
            if (existingSnap.exists) {
                throw new https_1.HttpsError("already-exists", "A product with this id already exists.");
            }
            const now = admin.firestore.FieldValue.serverTimestamp();
            const docData = {
                ...sanitizedInput,
                id: productId,
                titleEn,
                slug,
                isDeleted: false,
                deletedAt: null,
                deletedBy: null,
                deleteReason: null,
                createdAt: sanitizedInput.createdAt ?? now,
                updatedAt: now,
                createdBy: (0, callable_parsers_1.asTrimmedString)(sanitizedInput.createdBy) || actor.uid,
                updatedBy: actor.uid,
                isEnabled: asBool(sanitizedInput.isEnabled, true),
            };
            tx.set(productRef, docData);
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "create_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: titleEn,
                status: "success",
                reason,
                beforeData: null,
                afterData: {
                    id: productId,
                    titleEn,
                    slug,
                    isEnabled: docData.isEnabled,
                    categoryId: docData.categoryId ?? null,
                    brandId: docData.brandId ?? null,
                },
                metadata: {
                    sku: docData.sku ?? null,
                    productCode: docData.productCode ?? null,
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            productId,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminCreateProduct failed", {
            error,
            data: request.data ?? null,
            uid: request.auth?.uid ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to create product.");
    }
});
