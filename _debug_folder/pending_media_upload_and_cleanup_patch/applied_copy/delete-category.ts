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
  groupIdFromParentId,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();
const bucket = admin.storage().bucket();

type DeleteCategoryRequest = {
  categoryId?: string;
  reason?: string | null;
};

type DeleteCategoryResponse = {
  success: true;
  categoryId: string;
  auditLogId: string;
};

type CategoryState = {
  id: string;
  nameEn: string;
  nameBn: string;
  descriptionEn: string;
  descriptionBn: string;
  imageUrl: string;
  iconUrl: string;
  imagePath: string;
  thumbPath: string;
  slug: string;
  parentId: string | null;
  groupId: string;
  isFeatured: boolean;
  showOnHome: boolean;
  isActive: boolean;
  sortOrder: number;
  productsCount: number;
};

function parseCategoryState(
  doc: admin.firestore.DocumentSnapshot | admin.firestore.QueryDocumentSnapshot,
): CategoryState {
  const data = doc.data() ?? {};
  const parentId = normalizeNullableId(data.parentId);
  const explicitGroupId = asTrimmedString(data.groupId);

  return {
    id: doc.id,
    nameEn: asTrimmedString(data.nameEn),
    nameBn: asTrimmedString(data.nameBn),
    descriptionEn: asTrimmedString(data.descriptionEn),
    descriptionBn: asTrimmedString(data.descriptionBn),
    imageUrl: asTrimmedString(data.imageUrl),
    iconUrl: asTrimmedString(data.iconUrl),
    imagePath: asTrimmedString(data.imagePath),
    thumbPath: asTrimmedString(data.thumbPath),
    slug: asTrimmedString(data.slug).toLowerCase(),
    parentId,
    groupId:
      explicitGroupId.length > 0 ? explicitGroupId : groupIdFromParentId(parentId),
    isFeatured: asBool(data.isFeatured, false),
    showOnHome: asBool(data.showOnHome, false),
    isActive: asBool(data.isActive, true),
    sortOrder: asInt(data.sortOrder, 0),
    productsCount: asInt(data.productsCount, 0),
  };
}

function buildAuditBeforeState(existing: CategoryState): Record<string, unknown> {
  return {
    id: existing.id,
    nameEn: existing.nameEn,
    nameBn: existing.nameBn,
    descriptionEn: existing.descriptionEn,
    descriptionBn: existing.descriptionBn,
    imageUrl: existing.imageUrl,
    iconUrl: existing.iconUrl,
    imagePath: existing.imagePath,
    thumbPath: existing.thumbPath,
    slug: existing.slug,
    parentId: existing.parentId ?? "",
    groupId: existing.groupId,
    isFeatured: existing.isFeatured,
    showOnHome: existing.showOnHome,
    isActive: existing.isActive,
    sortOrder: existing.sortOrder,
    productsCount: existing.productsCount,
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

function collectCategoryStoragePaths(
  raw: admin.firestore.DocumentData,
  existing: CategoryState,
): string[] {
  const paths = new Set<string>();

  addStoragePath(paths, existing.imagePath);
  addStoragePath(paths, existing.thumbPath);
  addStoragePath(paths, raw.iconPath);
  addStoragePath(paths, raw.imageStoragePath);
  addStoragePath(paths, raw.thumbStoragePath);
  addStoragePath(paths, raw.iconStoragePath);
  addStoragePath(paths, raw.storagePath);

  addStoragePathFromUrl(paths, existing.imageUrl);
  addStoragePathFromUrl(paths, existing.iconUrl);
  addStoragePathFromUrl(paths, raw.thumbUrl);

  return Array.from(paths);
}

async function deleteStoragePath(path: string): Promise<void> {
  const normalized = path.trim();
  if (normalized.length === 0) return;

  try {
    await bucket.file(normalized).delete({ ignoreNotFound: true });
  } catch (error) {
    logger.warn(`Failed to delete storage object: ${normalized}`, error);
  }
}

export const deleteCategory = onCall<DeleteCategoryRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<DeleteCategoryResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const categoryId = asTrimmedString(request.data?.categoryId);
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(categoryId, "categoryId");

      let auditLogId = "";
      let storagePathsToDelete: string[] = [];

      await db.runTransaction(async (tx) => {
        const categoryRef = db.collection("categories").doc(categoryId);
        const existingSnap = await tx.get(categoryRef);
        if (!existingSnap.exists) {
          throw new HttpsError("not-found", "Category not found.");
        }

        const existing = parseCategoryState(existingSnap);

        if (existing.productsCount > 0) {
          throw new HttpsError(
            "failed-precondition",
            `This category cannot be deleted because it contains ${existing.productsCount} product(s).`,
          );
        }

        const childQuery = db
          .collection("categories")
          .where("parentId", "==", categoryId)
          .limit(1);
        const childSnap = await tx.get(childQuery);
        if (!childSnap.empty) {
          throw new HttpsError(
            "failed-precondition",
            "This category cannot be deleted because it has child categories.",
          );
        }

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "delete_category",
            module: "categories",
            targetType: "category",
            targetId: categoryId,
            targetTitle: existing.nameEn,
            status: "success",
            reason,
            beforeData: buildAuditBeforeState(existing),
            afterData: null,
            metadata: {
              groupId: existing.groupId,
              parentId: existing.parentId ?? "",
              productsCount: existing.productsCount,
            },
            eventSource: "server_action",
          }),
        );

        tx.delete(categoryRef);
        storagePathsToDelete = collectCategoryStoragePaths(
          existingSnap.data() ?? {},
          existing,
        );
      });

      for (const path of storagePathsToDelete) {
        await deleteStoragePath(path);
      }

      return {
        success: true,
        categoryId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("deleteCategory failed", error);
      throw new HttpsError("internal", "Failed to delete category.");
    }
  },
);
