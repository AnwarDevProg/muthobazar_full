import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";

import {
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();
const storage = admin.storage();

type HardDeleteProductRequest = {
  productId?: string;
  reason?: string | null;
};

type HardDeleteProductResponse = {
  success: true;
  productId: string;
  auditLogId: string;
  deletedStorageCount: number;
};

type JsonMap = Record<string, unknown>;

type ExistingProductSnapshot = {
  id: string;
  titleEn: string;
  titleBn: string;
  slug: string;
  sku: string;
  productCode: string;
  categoryId: string;
  categoryNameEn: string;
  categoryNameBn: string;
  brandId: string;
  brandNameEn: string;
  brandNameBn: string;
  productType: string;
  inventoryMode: string;
  schedulePriceType: string;
  quantityType: string;
  toleranceType: string;
  deliveryShift: string;
  cardLayoutType: string;
  isEnabled: boolean;
  isDeleted: boolean;
  mediaItems: Array<Record<string, unknown>>;
  thumbnailUrl: string;
  imageUrls: string[];
  createdAt: unknown;
  updatedAt: unknown;
  deletedAt: unknown;
  deletedBy: unknown;
  deleteReason: unknown;
};

function asBool(value: unknown, fallback = false): boolean {
  return typeof value === "boolean" ? value : fallback;
}

function asStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => asTrimmedString(item))
    .filter((item) => item.length > 0);
}

function asObjectList(value: unknown): Array<Record<string, unknown>> {
  if (!Array.isArray(value)) return [];
  return value.filter(
    (item): item is Record<string, unknown> =>
      typeof item === "object" && item !== null && !Array.isArray(item),
  );
}

function normalizeCardLayoutType(value: unknown): string {
  const normalized = asTrimmedString(value).toLowerCase();

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

function parseExistingProduct(
  doc: admin.firestore.DocumentSnapshot,
): ExistingProductSnapshot {
  const data = (doc.data() ?? {}) as JsonMap;

  return {
    id: doc.id,
    titleEn: asTrimmedString(data.titleEn),
    titleBn: asTrimmedString(data.titleBn),
    slug: asTrimmedString(data.slug).toLowerCase(),
    sku: asTrimmedString(data.sku),
    productCode: asTrimmedString(data.productCode),
    categoryId: asTrimmedString(data.categoryId),
    categoryNameEn: asTrimmedString(data.categoryNameEn),
    categoryNameBn: asTrimmedString(data.categoryNameBn),
    brandId: asTrimmedString(data.brandId),
    brandNameEn: asTrimmedString(data.brandNameEn),
    brandNameBn: asTrimmedString(data.brandNameBn),
    productType:
      asTrimmedString(data.productType).length > 0
        ? asTrimmedString(data.productType)
        : "simple",
    inventoryMode:
      asTrimmedString(data.inventoryMode).length > 0
        ? asTrimmedString(data.inventoryMode)
        : "stocked",
    schedulePriceType:
      asTrimmedString(data.schedulePriceType).length > 0
        ? asTrimmedString(data.schedulePriceType)
        : "fixed",
    quantityType:
      asTrimmedString(data.quantityType).length > 0
        ? asTrimmedString(data.quantityType)
        : "pcs",
    toleranceType:
      asTrimmedString(data.toleranceType).length > 0
        ? asTrimmedString(data.toleranceType)
        : "g",
    deliveryShift:
      asTrimmedString(data.deliveryShift).length > 0
        ? asTrimmedString(data.deliveryShift)
        : "any",
    cardLayoutType: normalizeCardLayoutType(data.cardLayoutType),
    isEnabled: asBool(data.isEnabled, true),
    isDeleted: asBool(data.isDeleted, false),
    mediaItems: asObjectList(data.mediaItems),
    thumbnailUrl: asTrimmedString(data.thumbnailUrl),
    imageUrls: asStringList(data.imageUrls),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
    deletedAt: data.deletedAt ?? null,
    deletedBy: data.deletedBy ?? null,
    deleteReason: data.deleteReason ?? null,
  };
}

function buildAuditBeforeData(
  current: ExistingProductSnapshot,
): Record<string, unknown> {
  return {
    id: current.id,
    titleEn: current.titleEn,
    titleBn: current.titleBn,
    slug: current.slug,
    sku: current.sku,
    productCode: current.productCode,
    categoryId: current.categoryId,
    categoryNameEn: current.categoryNameEn,
    categoryNameBn: current.categoryNameBn,
    brandId: current.brandId,
    brandNameEn: current.brandNameEn,
    brandNameBn: current.brandNameBn,
    productType: current.productType,
    inventoryMode: current.inventoryMode,
    schedulePriceType: current.schedulePriceType,
    quantityType: current.quantityType,
    toleranceType: current.toleranceType,
    deliveryShift: current.deliveryShift,
    cardLayoutType: current.cardLayoutType,
    isEnabled: current.isEnabled,
    isDeleted: current.isDeleted,
    mediaItems: current.mediaItems,
    thumbnailUrl: current.thumbnailUrl,
    imageUrls: current.imageUrls,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
    deletedAt: current.deletedAt ?? null,
    deletedBy: current.deletedBy ?? null,
    deleteReason: current.deleteReason ?? null,
  };
}

function collectStoragePaths(current: ExistingProductSnapshot): string[] {
  const paths = new Set<string>();

  for (const item of current.mediaItems) {
    const storagePath = asTrimmedString(item.storagePath);
    if (storagePath.length > 0) {
      paths.add(storagePath);
    }
  }

  return Array.from(paths);
}

async function deleteStorageObjectIfExists(path: string): Promise<void> {
  const safePath = path.trim();
  if (!safePath) return;

  try {
    await storage.bucket().file(safePath).delete({ ignoreNotFound: true });
  } catch (error) {
    logger.warn("Failed to delete product storage object", {
      path: safePath,
      error,
    });
  }
}

export const adminHardDeleteProduct = onCall<
  HardDeleteProductRequest,
  Promise<HardDeleteProductResponse>
>(async (request) => {
  try {
    logger.info("adminHardDeleteProduct invoked", {
      uid: request.auth?.uid ?? null,
      productId: request.data?.productId ?? null,
    });

    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canRestoreProducts",
    );

    const productId = asTrimmedString(request.data?.productId);
    const reason = normalizeNullableId(request.data?.reason);

    requireNonEmpty(productId, "productId");

    const productRef = db.collection("products").doc(productId);
    let auditLogId = "";
    let storagePathsToDelete: string[] = [];

    await db.runTransaction(async (tx) => {
      const currentSnap = await tx.get(productRef);

      if (!currentSnap.exists) {
        throw new HttpsError("not-found", "Product not found.");
      }

      const current = parseExistingProduct(currentSnap);

      if (!current.isDeleted) {
        throw new HttpsError(
          "failed-precondition",
          "Only quarantine products can be permanently deleted.",
        );
      }

      tx.delete(productRef);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      const storagePaths = collectStoragePaths(current);

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "hard_delete_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: current.titleEn || productId,
          status: "success",
          reason,
          beforeData: buildAuditBeforeData(current),
          afterData: null,
          metadata: {
            slug: current.slug,
            sku: current.sku,
            productCode: current.productCode,
            categoryId: current.categoryId,
            brandId: current.brandId,
            productType: current.productType,
            cardLayoutType: current.cardLayoutType,
            deletedAt: current.deletedAt ?? null,
            wasQuarantined: current.isDeleted,
            storagePathsCount: storagePaths.length,
          },
          eventSource: "server_action",
        }),
      );

      storagePathsToDelete = storagePaths;
    });

    for (const path of storagePathsToDelete) {
      await deleteStorageObjectIfExists(path);
    }

    return {
      success: true,
      productId,
      auditLogId,
      deletedStorageCount: storagePathsToDelete.length,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    logger.error("adminHardDeleteProduct failed", {
      error,
      uid: request.auth?.uid ?? null,
      data: request.data ?? null,
    });

    throw new HttpsError("internal", "Failed to hard delete product.");
  }
});