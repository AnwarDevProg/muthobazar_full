"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onProductDeletedUpdateCategoryCount = exports.onProductUpdatedUpdateCategoryCount = exports.onProductCreatedUpdateCategoryCount = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
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
            // Optional future protection for soft delete
            if (data.isDeleted === true) {
                continue;
            }
            count += 1;
        }
        await db.collection("categories").doc(normalizedCategoryId).set({
            productsCount: count,
            updatedAt: new Date().toISOString(),
        }, { merge: true });
        firebase_functions_1.logger.info(`Category ${normalizedCategoryId} productsCount updated to ${count}`);
    }
    catch (error) {
        firebase_functions_1.logger.error(`Failed to recompute productsCount for category ${normalizedCategoryId}`, error);
        throw error;
    }
}
exports.onProductCreatedUpdateCategoryCount = (0, firestore_1.onDocumentCreated)({
    document: "products/{productId}",
    region: "asia-south1",
}, async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);
    if (!categoryId) {
        firebase_functions_1.logger.info("Product created without categoryId. No category count update needed.");
        return;
    }
    await recomputeCategoryProductsCount(categoryId);
});
exports.onProductUpdatedUpdateCategoryCount = (0, firestore_1.onDocumentUpdated)({
    document: "products/{productId}",
    region: "asia-south1",
}, async (event) => {
    const beforeData = event.data?.before.data() ?? {};
    const afterData = event.data?.after.data() ?? {};
    const beforeCategoryId = normalizeCategoryId(beforeData.categoryId);
    const afterCategoryId = normalizeCategoryId(afterData.categoryId);
    if (!beforeCategoryId && !afterCategoryId) {
        firebase_functions_1.logger.info("Product updated without categoryId before/after. No category count update needed.");
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
    region: "asia-south1",
}, async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);
    if (!categoryId) {
        firebase_functions_1.logger.info("Deleted product had no categoryId. No category count update needed.");
        return;
    }
    await recomputeCategoryProductsCount(categoryId);
});
