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
exports.onProductDeletedUpdateCategoryCount = exports.onProductUpdatedUpdateCategoryCount = exports.onProductCreatedUpdateCategoryCount = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const firestore_2 = require("firebase-admin/firestore");
const db = (0, firestore_2.getFirestore)();
function normalizeCategoryId(value) {
    return (value ?? "").toString().trim();
}
async function recomputeCategoryProductsCount(categoryId) {
    const normalizedCategoryId = normalizeCategoryId(categoryId);
    if (!normalizedCategoryId)
        return;
    try {
        const productsSnap = await db
            .collection("products")
            .where("categoryId", "==", normalizedCategoryId)
            .get();
        let count = 0;
        for (const doc of productsSnap.docs) {
            const data = doc.data() ?? {};
            if (data.isDeleted === true) {
                continue;
            }
            count += 1;
        }
        await db.collection("categories").doc(normalizedCategoryId).set({
            productsCount: count,
            updatedAt: new Date().toISOString(),
        }, { merge: true });
        logger.info(`Category ${normalizedCategoryId} productsCount updated to ${count}`);
    }
    catch (error) {
        logger.error(`Failed to recompute productsCount for category ${normalizedCategoryId}`, error);
        throw error;
    }
}
exports.onProductCreatedUpdateCategoryCount = (0, firestore_1.onDocumentCreated)({
    document: "products/{productId}",
}, async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);
    if (!categoryId) {
        logger.info("Product created without categoryId. No category count update needed.");
        return;
    }
    await recomputeCategoryProductsCount(categoryId);
});
exports.onProductUpdatedUpdateCategoryCount = (0, firestore_1.onDocumentUpdated)({
    document: "products/{productId}",
}, async (event) => {
    const beforeData = event.data?.before.data() ?? {};
    const afterData = event.data?.after.data() ?? {};
    const beforeCategoryId = normalizeCategoryId(beforeData.categoryId);
    const afterCategoryId = normalizeCategoryId(afterData.categoryId);
    if (!beforeCategoryId && !afterCategoryId) {
        logger.info("Product updated without categoryId before/after. No category count update needed.");
        return;
    }
    if (beforeCategoryId && beforeCategoryId === afterCategoryId) {
        await recomputeCategoryProductsCount(beforeCategoryId);
        return;
    }
    if (beforeCategoryId) {
        await recomputeCategoryProductsCount(beforeCategoryId);
    }
    if (afterCategoryId) {
        await recomputeCategoryProductsCount(afterCategoryId);
    }
});
exports.onProductDeletedUpdateCategoryCount = (0, firestore_1.onDocumentDeleted)({
    document: "products/{productId}",
}, async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);
    if (!categoryId) {
        logger.info("Deleted product had no categoryId. No category count update needed.");
        return;
    }
    await recomputeCategoryProductsCount(categoryId);
});
