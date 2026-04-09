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
  requireNonNegativeInt,
  requireObjectRecord,
  slugify,
} from "../utils/callable-parsers";

const db = admin.firestore();

type UpdateCategoryRequest = {
  categoryId?: string;
  category?: Record<string, unknown>;
};

type UpdateCategoryResponse = {
  success: true;
  categoryId: string;
  auditLogId: string;
};

type CategoryPayload = {
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
  isFeatured: boolean;
  showOnHome: boolean;
  isActive: boolean;
  sortOrder: number;
};

type ExistingCategorySnapshot = {
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
  parentId: string;
  groupId: string;
  isFeatured: boolean;
  showOnHome: boolean;
  isActive: boolean;
  sortOrder: number;
  productsCount: number;
  createdAt: unknown;
  updatedAt: unknown;
};

function normalizeCategoryPayload(input: unknown): CategoryPayload {
  const raw = requireObjectRecord(input, "category");

  const nameEn = asTrimmedString(raw.nameEn);
  const nameBn = asTrimmedString(raw.nameBn);
  const descriptionEn = asTrimmedString(raw.descriptionEn);
  const descriptionBn = asTrimmedString(raw.descriptionBn);
  const imageUrl = asTrimmedString(raw.imageUrl);
  const iconUrl = asTrimmedString(raw.iconUrl);
  const imagePath = asTrimmedString(raw.imagePath);
  const thumbPath = asTrimmedString(raw.thumbPath);
  const parentId = normalizeNullableId(raw.parentId);

  requireNonEmpty(nameEn, "category.nameEn");

  const normalizedSlug = slugify(
    asTrimmedString(raw.slug).length > 0 ? asTrimmedString(raw.slug) : nameEn,
  );
  requireNonEmpty(normalizedSlug, "category.slug");

  const sortOrder = asInt(raw.sortOrder, 0);
  requireNonNegativeInt(sortOrder, "category.sortOrder");

  return {
    nameEn,
    nameBn,
    descriptionEn,
    descriptionBn,
    imageUrl,
    iconUrl,
    imagePath,
    thumbPath,
    slug: normalizedSlug,
    parentId,
    isFeatured: asBool(raw.isFeatured, false),
    showOnHome: asBool(raw.showOnHome, false),
    isActive: asBool(raw.isActive, true),
    sortOrder,
  };
}

function parseExistingCategory(
  doc: admin.firestore.DocumentSnapshot,
): ExistingCategorySnapshot {
  const data = doc.data() ?? {};
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
    parentId: asTrimmedString(data.parentId),
    groupId: asTrimmedString(data.groupId),
    isFeatured: asBool(data.isFeatured, false),
    showOnHome: asBool(data.showOnHome, false),
    isActive: asBool(data.isActive, true),
    sortOrder: asInt(data.sortOrder, 0),
    productsCount: asInt(data.productsCount, 0),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
  };
}

function buildUpdatedCategoryDoc(
  payload: CategoryPayload,
  productsCount: number,
): admin.firestore.DocumentData {
  return {
    nameEn: payload.nameEn,
    nameBn: payload.nameBn,
    descriptionEn: payload.descriptionEn,
    descriptionBn: payload.descriptionBn,
    imageUrl: payload.imageUrl,
    iconUrl: payload.iconUrl,
    imagePath: payload.imagePath,
    thumbPath: payload.thumbPath,
    slug: payload.slug,
    parentId: payload.parentId ?? "",
    groupId: groupIdFromParentId(payload.parentId),
    isFeatured: payload.isFeatured,
    showOnHome: payload.showOnHome,
    isActive: payload.isActive,
    sortOrder: payload.sortOrder,
    productsCount,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditBeforeData(
  current: ExistingCategorySnapshot,
): Record<string, unknown> {
  return {
    id: current.id,
    nameEn: current.nameEn,
    nameBn: current.nameBn,
    descriptionEn: current.descriptionEn,
    descriptionBn: current.descriptionBn,
    imageUrl: current.imageUrl,
    iconUrl: current.iconUrl,
    imagePath: current.imagePath,
    thumbPath: current.thumbPath,
    slug: current.slug,
    parentId: current.parentId,
    groupId: current.groupId,
    isFeatured: current.isFeatured,
    showOnHome: current.showOnHome,
    isActive: current.isActive,
    sortOrder: current.sortOrder,
    productsCount: current.productsCount,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
  };
}

function buildAuditAfterData(
  categoryId: string,
  payload: CategoryPayload,
  productsCount: number,
  createdAt: unknown,
): Record<string, unknown> {
  return {
    id: categoryId,
    nameEn: payload.nameEn,
    nameBn: payload.nameBn,
    descriptionEn: payload.descriptionEn,
    descriptionBn: payload.descriptionBn,
    imageUrl: payload.imageUrl,
    iconUrl: payload.iconUrl,
    imagePath: payload.imagePath,
    thumbPath: payload.thumbPath,
    slug: payload.slug,
    parentId: payload.parentId ?? "",
    groupId: groupIdFromParentId(payload.parentId),
    isFeatured: payload.isFeatured,
    showOnHome: payload.showOnHome,
    isActive: payload.isActive,
    sortOrder: payload.sortOrder,
    productsCount,
    createdAt: createdAt ?? null,
  };
}

export const updateCategory = onCall<UpdateCategoryRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<UpdateCategoryResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const categoryId = asTrimmedString(request.data?.categoryId);
      requireNonEmpty(categoryId, "categoryId");

      const payload = normalizeCategoryPayload(request.data?.category);
      const categoryRef = db.collection("categories").doc(categoryId);
      const nextGroupId = groupIdFromParentId(payload.parentId);
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const currentSnap = await tx.get(categoryRef);
        if (!currentSnap.exists) {
          throw new HttpsError("not-found", "Category not found.");
        }

        const current = parseExistingCategory(currentSnap);
        const beforeData = buildAuditBeforeData(current);
        const productsCount = current.productsCount;

        if (payload.parentId && payload.parentId === categoryId) {
          throw new HttpsError(
            "failed-precondition",
            "A category cannot be its own parent.",
          );
        }

        if (payload.parentId) {
          const parentRef = db.collection("categories").doc(payload.parentId);
          const parentSnap = await tx.get(parentRef);
          if (!parentSnap.exists) {
            throw new HttpsError(
              "failed-precondition",
              "Selected parent category was not found.",
            );
          }
        }

        const slugQuery = db
          .collection("categories")
          .where("slug", "==", payload.slug)
          .limit(10);
        const slugSnap = await tx.get(slugQuery);
        const slugConflict = slugSnap.docs.find((doc) => doc.id !== categoryId);
        if (slugConflict) {
          throw new HttpsError(
            "already-exists",
            "A category with the same slug already exists.",
          );
        }

        const groupQuery = db
          .collection("categories")
          .where("groupId", "==", nextGroupId);
        const groupSnap = await tx.get(groupQuery);
        const sortConflict = groupSnap.docs.find((doc) => {
          if (doc.id === categoryId) return false;
          return asInt(doc.data()?.sortOrder, 0) === payload.sortOrder;
        });

        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists in this group. Please use another.",
          );
        }

        tx.set(
          categoryRef,
          buildUpdatedCategoryDoc(payload, productsCount),
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "update_category",
            module: "categories",
            targetType: "category",
            targetId: categoryId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData,
            afterData: buildAuditAfterData(
              categoryId,
              payload,
              productsCount,
              current.createdAt,
            ),
            metadata: {
              previousParentId: current.parentId,
              nextParentId: payload.parentId ?? "",
              previousGroupId: current.groupId,
              nextGroupId,
              sortOrder: payload.sortOrder,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        categoryId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("updateCategory failed", error);
      throw new HttpsError("internal", "Failed to update category.");
    }
  },
);
