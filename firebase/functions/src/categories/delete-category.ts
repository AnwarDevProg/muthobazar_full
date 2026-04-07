import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";

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

function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function asNullableTrimmedString(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length === 0 ? null : normalized;
}

function asInt(value: unknown, defaultValue = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }

  const parsed = Number.parseInt(String(value ?? "").trim(), 10);
  return Number.isNaN(parsed) ? defaultValue : parsed;
}

function requireNonEmpty(value: string, fieldName: string): void {
  if (value.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is required.`,
    );
  }
}

function normalizeParentId(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length === 0 ? null : normalized;
}

function groupIdFromParentId(parentId: string | null): string {
  return parentId == null || parentId.length === 0 ? "root" : parentId;
}

function parseCategoryState(
  doc: admin.firestore.DocumentSnapshot | admin.firestore.QueryDocumentSnapshot,
): CategoryState {
  const data = doc.data() ?? {};

  const parentId = normalizeParentId(data.parentId);
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
    groupId: explicitGroupId.length > 0 ? explicitGroupId : groupIdFromParentId(parentId),
    isFeatured: data.isFeatured === true,
    showOnHome: data.showOnHome === true,
    isActive: data.isActive !== false,
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
  async (request): Promise<DeleteCategoryResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const categoryId = asTrimmedString(request.data?.categoryId);
      const reason = asNullableTrimmedString(request.data?.reason);

      requireNonEmpty(categoryId, "categoryId");

      let auditLogId = "";
      let imagePathToDelete = "";
      let thumbPathToDelete = "";

      await db.runTransaction(async (tx) => {
        const categoryRef = db.collection("categories").doc(categoryId);
        const existingSnap = await tx.get(categoryRef);

        if (!existingSnap.exists) {
          throw new HttpsError(
            "not-found",
            "Category not found.",
          );
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

        imagePathToDelete = existing.imagePath;
        if (
          existing.thumbPath.length > 0 &&
          existing.thumbPath !== existing.imagePath
        ) {
          thumbPathToDelete = existing.thumbPath;
        }
      });

      await deleteStoragePath(imagePathToDelete);
      await deleteStoragePath(thumbPathToDelete);

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

      throw new HttpsError(
        "internal",
        "Failed to delete category.",
      );
    }
  },
);