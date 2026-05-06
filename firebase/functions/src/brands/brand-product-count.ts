import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

function normalizeBrandId(value: unknown): string {
  return (value ?? "").toString().trim();
}

async function recomputeBrandProductsCount(
  brandId: string,
): Promise<void> {
  const normalizedBrandId = normalizeBrandId(brandId);

  if (!normalizedBrandId) return;

  try {
    const productsSnap = await db
      .collection("products")
      .where("brandId", "==", normalizedBrandId)
      .get();

    let count = 0;

    for (const doc of productsSnap.docs) {
      const data = doc.data() ?? {};

      if (data.isDeleted === true) {
        continue;
      }

      count += 1;
    }

    await db.collection("brands").doc(normalizedBrandId).set(
      {
        productsCount: count,
        updatedAt: new Date().toISOString(),
      },
      { merge: true },
    );

    logger.info(
      `Brand ${normalizedBrandId} productsCount updated to ${count}`,
    );
  } catch (error) {
    logger.error(
      `Failed to recompute productsCount for brand ${normalizedBrandId}`,
      error,
    );
    throw error;
  }
}

export const onProductCreatedUpdateBrandCount = onDocumentCreated(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const data = event.data?.data() ?? {};
    const brandId = normalizeBrandId(data.brandId);

    if (!brandId) {
      logger.info(
        "Product created without brandId. No brand count update needed.",
      );
      return;
    }

    await recomputeBrandProductsCount(brandId);
  },
);

export const onProductUpdatedUpdateBrandCount = onDocumentUpdated(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const beforeData = event.data?.before.data() ?? {};
    const afterData = event.data?.after.data() ?? {};

    const beforeBrandId = normalizeBrandId(beforeData.brandId);
    const afterBrandId = normalizeBrandId(afterData.brandId);

    if (!beforeBrandId && !afterBrandId) {
      logger.info(
        "Product updated without brandId before/after. No brand count update needed.",
      );
      return;
    }

    if (beforeBrandId && beforeBrandId === afterBrandId) {
      await recomputeBrandProductsCount(beforeBrandId);
      return;
    }

    if (beforeBrandId) {
      await recomputeBrandProductsCount(beforeBrandId);
    }

    if (afterBrandId) {
      await recomputeBrandProductsCount(afterBrandId);
    }
  },
);

export const onProductDeletedUpdateBrandCount = onDocumentDeleted(
  {
    document: "products/{productId}",
  },
  async (event) => {
    const data = event.data?.data() ?? {};
    const brandId = normalizeBrandId(data.brandId);

    if (!brandId) {
      logger.info(
        "Deleted product had no brandId. No brand count update needed.",
      );
      return;
    }

    await recomputeBrandProductsCount(brandId);
  },
);
