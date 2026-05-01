import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

function normalizeCategoryId(value: unknown): string {
  return (value ?? "").toString().trim();
}

async function recomputeCategoryProductsCount(
  categoryId: string,
): Promise<void> {
  const normalizedCategoryId = normalizeCategoryId(categoryId);

  if (!normalizedCategoryId) return;

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

    await db.collection("categories").doc(normalizedCategoryId).set(
      {
        productsCount: count,
        updatedAt: new Date().toISOString(),
      },
      { merge: true },
    );

    logger.info(
      `Category ${normalizedCategoryId} productsCount updated to ${count}`,
    );
  } catch (error) {
    logger.error(
      `Failed to recompute productsCount for category ${normalizedCategoryId}`,
      error,
    );
    throw error;
  }
}

export const onProductCreatedUpdateCategoryCount = onDocumentCreated(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);

    if (!categoryId) {
      logger.info(
        "Product created without categoryId. No category count update needed.",
      );
      return;
    }

    await recomputeCategoryProductsCount(categoryId);
  },
);

export const onProductUpdatedUpdateCategoryCount = onDocumentUpdated(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const beforeData = event.data?.before.data() ?? {};
    const afterData = event.data?.after.data() ?? {};

    const beforeCategoryId = normalizeCategoryId(beforeData.categoryId);
    const afterCategoryId = normalizeCategoryId(afterData.categoryId);

    if (!beforeCategoryId && !afterCategoryId) {
      logger.info(
        "Product updated without categoryId before/after. No category count update needed.",
      );
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
  },
);

export const onProductDeletedUpdateCategoryCount = onDocumentDeleted(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const data = event.data?.data() ?? {};
    const categoryId = normalizeCategoryId(data.categoryId);

    if (!categoryId) {
      logger.info(
        "Deleted product had no categoryId. No category count update needed.",
      );
      return;
    }

    await recomputeCategoryProductsCount(categoryId);
  },
);