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
  variations: Array<Record<string, unknown>>;
  thumbnailUrl: string;
  imageUrls: string[];
  rawData: Record<string, unknown>;
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
  return normalized.length > 0 ? normalized : "standard";
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
    variations: asObjectList(data.variations),
    thumbnailUrl: asTrimmedString(data.thumbnailUrl),
    imageUrls: asStringList(data.imageUrls),
    rawData: data,
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
    variations: current.variations,
    thumbnailUrl: current.thumbnailUrl,
    imageUrls: current.imageUrls,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
    deletedAt: current.deletedAt ?? null,
    deletedBy: current.deletedBy ?? null,
    deleteReason: current.deleteReason ?? null,
  };
}

function addStoragePath(paths: Set<string>, value: unknown): void {
  const path = asTrimmedString(value);

  if (!path) return;
  if (path.startsWith("http://") || path.startsWith("https://")) return;
  if (path.startsWith("gs://")) {
    const parsed = parseStoragePathFromUrl(path);
    if (parsed) paths.add(parsed);
    return;
  }

  paths.add(path);
}

function addStoragePathFromUrl(paths: Set<string>, value: unknown): void {
  const parsed = parseStoragePathFromUrl(asTrimmedString(value));
  if (parsed) paths.add(parsed);
}

function parseStoragePathFromUrl(value: string): string {
  const url = value.trim();
  if (!url) return "";

  if (url.startsWith("gs://")) {
    const withoutScheme = url.replace(/^gs:\/\//, "");
    const firstSlash = withoutScheme.indexOf("/");
    if (firstSlash < 0) return "";
    return withoutScheme.substring(firstSlash + 1).trim();
  }

  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    return url;
  }

  try {
    const parsed = new URL(url);
    const objectMarker = "/o/";
    const markerIndex = parsed.pathname.indexOf(objectMarker);

    if (markerIndex < 0) return "";

    const encodedPath = parsed.pathname.substring(markerIndex + objectMarker.length);
    if (!encodedPath) return "";

    return decodeURIComponent(encodedPath).trim();
  } catch (error) {
    logger.warn("Failed to parse Firebase Storage URL", {
      url,
      error,
    });
    return "";
  }
}

function collectMediaStoragePaths(
  paths: Set<string>,
  item: Record<string, unknown>,
): void {
  // Legacy/generic path fields.
  addStoragePath(paths, item.storagePath);
  addStoragePath(paths, item.imageStoragePath);
  addStoragePath(paths, item.imagePath);
  addStoragePath(paths, item.thumbnailStoragePath);
  addStoragePath(paths, item.thumbnailPath);
  addStoragePath(paths, item.thumbPath);

  // New generated image path fields.
  addStoragePath(paths, item.originalStoragePath);
  addStoragePath(paths, item.originalPath);
  addStoragePath(paths, item.fullStoragePath);
  addStoragePath(paths, item.fullPath);
  addStoragePath(paths, item.cardStoragePath);
  addStoragePath(paths, item.cardPath);
  addStoragePath(paths, item.thumbStoragePath);
  addStoragePath(paths, item.tinyStoragePath);
  addStoragePath(paths, item.tinyPath);

  // URL fallbacks for old records or partially migrated records.
  addStoragePathFromUrl(paths, item.url);
  addStoragePathFromUrl(paths, item.imageUrl);
  addStoragePathFromUrl(paths, item.thumbnailUrl);
  addStoragePathFromUrl(paths, item.originalUrl);
  addStoragePathFromUrl(paths, item.fullUrl);
  addStoragePathFromUrl(paths, item.cardUrl);
  addStoragePathFromUrl(paths, item.thumbUrl);
  addStoragePathFromUrl(paths, item.tinyUrl);
}

function collectRootStoragePaths(
  paths: Set<string>,
  data: Record<string, unknown>,
): void {
  // Root legacy/generic paths.
  addStoragePath(paths, data.storagePath);
  addStoragePath(paths, data.imageStoragePath);
  addStoragePath(paths, data.imagePath);
  addStoragePath(paths, data.thumbnailStoragePath);
  addStoragePath(paths, data.thumbnailPath);
  addStoragePath(paths, data.thumbPath);

  // Root generated-image paths, if ever stored directly on product.
  addStoragePath(paths, data.originalStoragePath);
  addStoragePath(paths, data.originalPath);
  addStoragePath(paths, data.fullStoragePath);
  addStoragePath(paths, data.fullPath);
  addStoragePath(paths, data.cardStoragePath);
  addStoragePath(paths, data.cardPath);
  addStoragePath(paths, data.thumbStoragePath);
  addStoragePath(paths, data.tinyStoragePath);
  addStoragePath(paths, data.tinyPath);

  // Root URL fallbacks.
  addStoragePathFromUrl(paths, data.url);
  addStoragePathFromUrl(paths, data.imageUrl);
  addStoragePathFromUrl(paths, data.thumbnailUrl);
  addStoragePathFromUrl(paths, data.originalUrl);
  addStoragePathFromUrl(paths, data.fullUrl);
  addStoragePathFromUrl(paths, data.cardUrl);
  addStoragePathFromUrl(paths, data.thumbUrl);
  addStoragePathFromUrl(paths, data.tinyUrl);

  for (const imageUrl of asStringList(data.imageUrls)) {
    addStoragePathFromUrl(paths, imageUrl);
  }
}

function collectVariationStoragePaths(
  paths: Set<string>,
  variation: Record<string, unknown>,
): void {
  // Variation legacy/generic fields.
  addStoragePath(paths, variation.imageStoragePath);
  addStoragePath(paths, variation.thumbImageStoragePath);
  addStoragePath(paths, variation.fullImageStoragePath);
  addStoragePath(paths, variation.cardImageStoragePath);
  addStoragePath(paths, variation.tinyImageStoragePath);
  addStoragePath(paths, variation.storagePath);
  addStoragePath(paths, variation.imagePath);
  addStoragePath(paths, variation.thumbPath);

  // Variation generated-image fields.
  addStoragePath(paths, variation.originalStoragePath);
  addStoragePath(paths, variation.originalPath);
  addStoragePath(paths, variation.fullStoragePath);
  addStoragePath(paths, variation.fullPath);
  addStoragePath(paths, variation.cardStoragePath);
  addStoragePath(paths, variation.cardPath);
  addStoragePath(paths, variation.thumbStoragePath);
  addStoragePath(paths, variation.tinyStoragePath);
  addStoragePath(paths, variation.tinyPath);

  // Variation URL fallbacks.
  addStoragePathFromUrl(paths, variation.imageUrl);
  addStoragePathFromUrl(paths, variation.thumbImageUrl);
  addStoragePathFromUrl(paths, variation.fullImageUrl);
  addStoragePathFromUrl(paths, variation.cardImageUrl);
  addStoragePathFromUrl(paths, variation.tinyImageUrl);
  addStoragePathFromUrl(paths, variation.url);
  addStoragePathFromUrl(paths, variation.thumbnailUrl);
  addStoragePathFromUrl(paths, variation.originalUrl);
  addStoragePathFromUrl(paths, variation.fullUrl);
  addStoragePathFromUrl(paths, variation.cardUrl);
  addStoragePathFromUrl(paths, variation.thumbUrl);
  addStoragePathFromUrl(paths, variation.tinyUrl);

  for (const media of asObjectList(variation.mediaItems)) {
    collectMediaStoragePaths(paths, media);
  }
}

function collectStoragePaths(current: ExistingProductSnapshot): string[] {
  const paths = new Set<string>();

  collectRootStoragePaths(paths, current.rawData);

  for (const item of current.mediaItems) {
    collectMediaStoragePaths(paths, item);
  }

  for (const variation of current.variations) {
    collectVariationStoragePaths(paths, variation);
  }

  return Array.from(paths).sort();
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
      "canDeleteProducts",
    );

    // Hard delete is only allowed from quarantine context.
    // Require restore permission too so direct callable access
    // cannot bypass the quarantine access policy.
    await getAuthorizedAdminActor(
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
            storageCleanup: "product_media_and_variation_media",
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

    logger.info("adminHardDeleteProduct storage cleanup complete", {
      productId,
      storagePathsCount: storagePathsToDelete.length,
    });

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
