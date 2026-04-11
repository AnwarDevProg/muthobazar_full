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
exports.adminDeleteProduct = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const db = admin.firestore();
function normalizeCardLayoutType(value) {
    const normalized = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    switch (normalized) {
        case "compact":
        case "deal":
        case "featured":
        case "standard":
            return normalized;
        default:
            return "standard";
    }
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
exports.adminDeleteProduct = (0, https_1.onCall)(async (request) => {
    try {
        logger.info("adminDeleteProduct invoked", {
            uid: request.auth?.uid ?? null,
            productId: request.data?.productId ?? null,
        });
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canDeleteProducts");
        const productId = (0, callable_parsers_1.asTrimmedString)(request.data?.productId);
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
                throw new https_1.HttpsError("failed-precondition", "Product is already deleted.");
            }
            const now = admin.firestore.FieldValue.serverTimestamp();
            const nextData = {
                ...currentData,
                isDeleted: true,
                isEnabled: false,
                deletedAt: now,
                deletedBy: actor.uid,
                deleteReason: reason,
                updatedAt: now,
                updatedBy: actor.uid,
            };
            tx.set(productRef, nextData, { merge: false });
            const logRef = (0, audit_log_core_1.newAdminAuditLogRef)();
            auditLogId = logRef.id;
            tx.set(logRef, (0, audit_log_core_1.buildAdminAuditLogDoc)(logRef.id, actor, {
                action: "delete_product",
                module: "products",
                targetType: "product",
                targetId: productId,
                targetTitle: (0, callable_parsers_1.asTrimmedString)(currentData.titleEn) || productId,
                status: "success",
                reason,
                beforeData: {
                    isDeleted: currentData.isDeleted ?? null,
                    isEnabled: currentData.isEnabled ?? null,
                    deletedBy: currentData.deletedBy ?? null,
                    deleteReason: currentData.deleteReason ?? null,
                    cardLayoutType: currentData.cardLayoutType ?? "standard",
                },
                afterData: {
                    isDeleted: true,
                    isEnabled: false,
                    deletedBy: actor.uid,
                    deleteReason: reason,
                    cardLayoutType: nextData.cardLayoutType ?? "standard",
                },
                metadata: {
                    softDelete: true,
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
            auditLogId,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("adminDeleteProduct failed", {
            error,
            uid: request.auth?.uid ?? null,
            data: request.data ?? null,
        });
        throw new https_1.HttpsError("internal", "Failed to delete product.");
    }
});
