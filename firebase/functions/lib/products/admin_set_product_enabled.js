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
exports.adminSetProductEnabled = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function normalizeCardLayoutType(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    return normalized.length > 0 ? normalized : "compact01";
}
function normalizeExistingProductData(input) {
    const output = { ...input };
    output.cardLayoutType = normalizeCardLayoutType(input.cardLayoutType);
    if ((0, callable_parsers_1.asTrimmedString)(output.productType).length === 0) {
        output.productType = "simple";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.inventoryMode).length === 0) {
        output.inventoryMode = "stocked";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.schedulePriceType).length === 0) {
        output.schedulePriceType = "fixed";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.quantityType).length === 0) {
        output.quantityType = "pcs";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.toleranceType).length === 0) {
        output.toleranceType = "g";
    }
    if ((0, callable_parsers_1.asTrimmedString)(output.deliveryShift).length === 0) {
        output.deliveryShift = "any";
    }
    return output;
}
exports.adminSetProductEnabled = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminSetProductEnabled invoked", {
            uid: request.auth?.uid ?? null,
            productId: request.data?.productId ?? null,
            isEnabled: typeof request.data?.isEnabled === "boolean"
                ? request.data.isEnabled
                : null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageProducts");
        const productId = (0, callable_parsers_1.asTrimmedString)(request.data?.productId);
        const isEnabled = (0, callable_parsers_1.asBoolOrThrow)(request.data?.isEnabled, "isEnabled");
        const reason = (0, callable_parsers_1.normalizeNullableId)(request.data?.reason);
        (0, callable_parsers_1.requireNonEmpty)(productId, "productId");
        const productRef = db.collection("products").doc(productId);
        let auditLogId = "";
        await db.runTransaction(async (tx) => {
            const currentSnap = await tx.get(productRef);
            if (!currentSnap.exists) {
                throw new https_1.HttpsError("not-found", "Product not found.");
            }
            const currentData = normalizeExistingProductData((currentSnap.data() ?? {}));
            if (currentData.isDeleted === true) {
                throw new https_1.HttpsError("failed-precondition", "Deleted products cannot be enabled or disabled.");
            }
            const now = admin.firestore.FieldValue.serverTimestamp();
            const nextData = {
                ...currentData,
                isEnabled,
                status: isEnabled ? "active" : "inactive",
                updatedAt: now,
                updatedBy: actor.uid,
            };
            tx.set(productRef, nextData, { merge: false });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: isEnabled ? "enable_product" : "disable_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: (0, callable_parsers_1.asTrimmedString)(currentData.titleEn) || productId,
                status: "success",
                reason,
                beforeData: {
                    isEnabled: currentData.isEnabled ?? null,
                    isDeleted: currentData.isDeleted ?? null,
                    cardLayoutType: currentData.cardLayoutType ?? "standard",
                },
                afterData: {
                    isEnabled,
                    isDeleted: currentData.isDeleted ?? null,
                    cardLayoutType: nextData.cardLayoutType ?? "standard",
                },
                metadata: {
                    productType: currentData.productType ?? null,
                    categoryId: currentData.categoryId ?? null,
                    brandId: currentData.brandId ?? null,
                },
                eventSource: "server_action",
            }));
        });
        return {
            success: true,
            productId,
            isEnabled,
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminSetProductEnabled failed", {
            error,
            uid: request.auth?.uid ?? null,
            data: request.data ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to update product status.");
    }
});
