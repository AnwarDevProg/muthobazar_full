import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";
import {
  asBool,
  asInt,
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();
const storage = admin.storage();

type DeleteBrandRequest = {
  brandId?: string;
  reason?: string | null;
};

type DeleteBrandResponse = {
  success: true;
  brandId: string;
  auditLogId: string;
};

type ExistingBrandSnapshot = {
  id: string;
  nameEn: string;
  nameBn: string;
  descriptionEn: string;
  descriptionBn: string;
  imageUrl: string;
  logoUrl: string;
  imagePath: string;
  thumbPath: string;
  slug: string;
  isFeatured: boolean;
  showOnHome: boolean;
  isActive: boolean;
  sortOrder: number;
  productsCount: number;
  createdAt: unknown;
  updatedAt: unknown;
};

function parseExistingBrand(
  doc: admin.firestore.DocumentSnapshot,
): ExistingBrandSnapshot {
  const data = doc.data() ?? {};

  return {
    id: doc.id,
    nameEn: asTrimmedString(data.nameEn),
    nameBn: asTrimmedString(data.nameBn),
    descriptionEn: asTrimmedString(data.descriptionEn),
    descriptionBn: asTrimmedString(data.descriptionBn),
    imageUrl: asTrimmedString(data.imageUrl),
    logoUrl: asTrimmedString(data.logoUrl),
    imagePath: asTrimmedString(data.imagePath),
    thumbPath: asTrimmedString(data.thumbPath),
    slug: asTrimmedString(data.slug).toLowerCase(),
    isFeatured: asBool(data.isFeatured, false),
    showOnHome: asBool(data.showOnHome, false),
    isActive: asBool(data.isActive, true),
    sortOrder: asInt(data.sortOrder, 0),
    productsCount: asInt(data.productsCount, 0),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
  };
}

function buildAuditBeforeData(
  current: ExistingBrandSnapshot,
): Record<string, unknown> {
  return {
    id: current.id,
    nameEn: current.nameEn,
    nameBn: current.nameBn,
    descriptionEn: current.descriptionEn,
    descriptionBn: current.descriptionBn,
    imageUrl: current.imageUrl,
    logoUrl: current.logoUrl,
    imagePath: current.imagePath,
    thumbPath: current.thumbPath,
    slug: current.slug,
    isFeatured: current.isFeatured,
    showOnHome: current.showOnHome,
    isActive: current.isActive,
    sortOrder: current.sortOrder,
    productsCount: current.productsCount,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
  };
}


function storagePathFromDownloadUrl(url: string): string {
  const safeUrl = url.trim();
  if (safeUrl.length === 0) return "";

  try {
    const parsed = new URL(safeUrl);
    const marker = "/o/";
    const markerIndex = parsed.pathname.indexOf(marker);
    if (markerIndex < 0) return "";

    const encodedPath = parsed.pathname.substring(markerIndex + marker.length);
    return decodeURIComponent(encodedPath);
  } catch (_) {
    return "";
  }
}

function addStoragePath(paths: Set<string>, value: unknown): void {
  const path = asTrimmedString(value);
  if (path.length > 0) paths.add(path);
}

function addStoragePathFromUrl(paths: Set<string>, value: unknown): void {
  const path = storagePathFromDownloadUrl(asTrimmedString(value));
  if (path.length > 0) paths.add(path);
}

function collectBrandStoragePaths(
  raw: admin.firestore.DocumentData,
  current: ExistingBrandSnapshot,
): string[] {
  const paths = new Set<string>();

  addStoragePath(paths, current.imagePath);
  addStoragePath(paths, current.thumbPath);
  addStoragePath(paths, raw.logoPath);
  addStoragePath(paths, raw.imageStoragePath);
  addStoragePath(paths, raw.thumbStoragePath);
  addStoragePath(paths, raw.logoStoragePath);
  addStoragePath(paths, raw.storagePath);

  addStoragePathFromUrl(paths, current.imageUrl);
  addStoragePathFromUrl(paths, current.logoUrl);
  addStoragePathFromUrl(paths, raw.thumbUrl);

  return Array.from(paths);
}

async function deleteStorageObjectIfExists(path: string): Promise<void> {
  const safePath = path.trim();
  if (!safePath) return;

  try {
    await storage.bucket().file(safePath).delete({ ignoreNotFound: true });
  } catch (error) {
    logger.warn("Failed to delete brand storage object", {
      path: safePath,
      error,
    });
  }
}

export const deleteBrand = onCall<DeleteBrandRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<DeleteBrandResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const brandId = asTrimmedString(request.data?.brandId);
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(brandId, "brandId");

      const brandRef = db.collection("brands").doc(brandId);
      let auditLogId = "";
      let storagePathsToDelete: string[] = [];

      await db.runTransaction(async (tx) => {
        const currentSnap = await tx.get(brandRef);
        if (!currentSnap.exists) {
          throw new HttpsError("not-found", "Brand not found.");
        }

        const current = parseExistingBrand(currentSnap);

        if (current.productsCount > 0) {
          throw new HttpsError(
            "failed-precondition",
            `This brand cannot be deleted because it contains ${current.productsCount} product(s).`,
          );
        }

        const productsSnap = await tx.get(
          db.collection("products").where("brandId", "==", brandId).limit(1),
        );
        if (!productsSnap.empty) {
          throw new HttpsError(
            "failed-precondition",
            "This brand cannot be deleted because some products still reference it.",
          );
        }

        tx.delete(brandRef);

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "delete_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: current.nameEn,
            status: "success",
            reason,
            beforeData: buildAuditBeforeData(current),
            afterData: null,
            metadata: {
              slug: current.slug,
              imagePath: current.imagePath,
              thumbPath: current.thumbPath,
            },
            eventSource: "server_action",
          }),
        );

        storagePathsToDelete = collectBrandStoragePaths(
          currentSnap.data() ?? {},
          current,
        );
      });

      for (const path of storagePathsToDelete) {
        await deleteStorageObjectIfExists(path);
      }

      return {
        success: true,
        brandId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("deleteBrand failed", error);
      throw new HttpsError("internal", "Failed to delete brand.");
    }
  },
);