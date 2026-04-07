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

type UpdateCategoryRequest = {
  categoryId?: string;
  category?: Record<string, unknown>;
};

type UpdateCategoryResponse = {
  success: true;
  categoryId: string;
  auditLogId: string;
  changedFields: string[];
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

function asBool(value: unknown, defaultValue = false): boolean {
  if (typeof value === "boolean") return value;
  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    if (normalized === "true") return true;
    if (normalized === "false") return false;
  }
  return defaultValue;
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

function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");
}

function normalizeCategoryPayload(input: unknown): CategoryPayload {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new HttpsError(
      "invalid-argument",
      "category payload is required.",
    );
  }

  const raw = input as Record<string, unknown>;

  const nameEn = asTrimmedString(raw.nameEn);
  const nameBn = asTrimmedString(raw.nameBn);
  const descriptionEn = asTrimmedString(raw.descriptionEn);
  const descriptionBn = asTrimmedString(raw.descriptionBn);
  const imageUrl = asTrimmedString(raw.imageUrl);
  const iconUrl = asTrimmedString(raw.iconUrl);
  const imagePath = asTrimmedString(raw.imagePath);
  const thumbPath = asTrimmedString(raw.thumbPath);
  const parentId = normalizeParentId(raw.parentId);

  requireNonEmpty(nameEn, "category.nameEn");

  const normalizedSlug = slugify(
    asTrimmedString(raw.slug).length > 0 ? asTrimmedString(raw.slug) : nameEn,
  );

  requireNonEmpty(normalizedSlug, "category.slug");

  const sortOrder = asInt(raw.sortOrder, 0);

  if (sortOrder < 0) {
    throw new HttpsError(
      "invalid-argument",
      "category.sortOrder must be 0 or greater.",
    );
  }

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
    isFeatured: asBool(data.isFeatured, false),
    showOnHome: asBool(data.showOnHome, false),
    isActive: asBool(data.isActive, true),
    sortOrder: asInt(data.sortOrder, 0),
    productsCount: asInt(data.productsCount, 0),
  };
}

function buildUpdatedCategoryMap(
  categoryId: string,
  payload: CategoryPayload,
  existing: CategoryState,
): admin.firestore.DocumentData {
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
    productsCount: existing.productsCount,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditCategoryState(
  categoryId: string,
  payload: CategoryPayload,
  existingProductsCount: number,
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
    productsCount: existingProductsCount,
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

function listChangedFields(
  existing: CategoryState,
  payload: CategoryPayload,
): string[] {
  const changed: string[] = [];
  const nextGroupId = groupIdFromParentId(payload.parentId);

  if (existing.nameEn !== payload.nameEn) changed.push("nameEn");
  if (existing.nameBn !== payload.nameBn) changed.push("nameBn");
  if (existing.descriptionEn !== payload.descriptionEn) changed.push("descriptionEn");
  if (existing.descriptionBn !== payload.descriptionBn) changed.push("descriptionBn");
  if (existing.imageUrl !== payload.imageUrl) changed.push("imageUrl");
  if (existing.iconUrl !== payload.iconUrl) changed.push("iconUrl");
  if (existing.imagePath !== payload.imagePath) changed.push("imagePath");
  if (existing.thumbPath !== payload.thumbPath) changed.push("thumbPath");
  if (existing.slug !== payload.slug) changed.push("slug");
  if ((existing.parentId ?? "") !== (payload.parentId ?? "")) changed.push("parentId");
  if (existing.groupId !== nextGroupId) changed.push("groupId");
  if (existing.isFeatured !== payload.isFeatured) changed.push("isFeatured");
  if (existing.showOnHome !== payload.showOnHome) changed.push("showOnHome");
  if (existing.isActive !== payload.isActive) changed.push("isActive");
  if (existing.sortOrder !== payload.sortOrder) changed.push("sortOrder");

  return changed;
}

async function ensureParentIsValid(
  tx: admin.firestore.Transaction,
  categoryId: string,
  parentId: string | null,
): Promise<void> {
  if (!parentId) return;

  if (parentId === categoryId) {
    throw new HttpsError(
      "failed-precondition",
      "A category cannot be its own parent.",
    );
  }

  let cursor: string | null = parentId;
  const visited = new Set<string>();

  while (cursor) {
    if (visited.has(cursor)) {
      throw new HttpsError(
        "failed-precondition",
        "Detected a circular category parent chain.",
      );
    }

    visited.add(cursor);

    if (cursor === categoryId) {
      throw new HttpsError(
        "failed-precondition",
        "This parent selection would create a circular hierarchy.",
      );
    }

    const parentRef = db.collection("categories").doc(cursor);
    const parentSnap = await tx.get(parentRef);

    if (!parentSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "Selected parent category was not found.",
      );
    }

    const parentData = parentSnap.data() ?? {};
    cursor = normalizeParentId(parentData.parentId);
  }
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

export const updateCategory = onCall<UpdateCategoryRequest>(
  async (request): Promise<UpdateCategoryResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const categoryId = asTrimmedString(request.data?.categoryId);
      requireNonEmpty(categoryId, "categoryId");

      const payload = normalizeCategoryPayload(request.data?.category);

      let auditLogId = "";
      let changedFields: string[] = [];
      let oldImagePathToDelete = "";
      let oldThumbPathToDelete = "";

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

        await ensureParentIsValid(tx, categoryId, payload.parentId);

        const slugQuery = db
          .collection("categories")
          .where("slug", "==", payload.slug)
          .limit(10);

        const slugSnap = await tx.get(slugQuery);
        const duplicateSlug = slugSnap.docs.find((doc) => doc.id !== categoryId);

        if (duplicateSlug) {
          throw new HttpsError(
            "already-exists",
            "A category with the same slug already exists.",
          );
        }

        const targetGroupId = groupIdFromParentId(payload.parentId);
        const groupQuery = db
          .collection("categories")
          .where("groupId", "==", targetGroupId);

        const groupSnap = await tx.get(groupQuery);
        const conflictingSort = groupSnap.docs.find((doc) => {
          if (doc.id === categoryId) return false;
          const data = doc.data() ?? {};
          return asInt(data.sortOrder, 0) === payload.sortOrder;
        });

        if (conflictingSort) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists in this group. Please use another.",
          );
        }

        changedFields = listChangedFields(existing, payload);

        if (changedFields.length === 0) {
          throw new HttpsError(
            "failed-precondition",
            "No category changes were detected.",
          );
        }

        tx.set(
          categoryRef,
          buildUpdatedCategoryMap(categoryId, payload, existing),
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
            beforeData: buildAuditBeforeState(existing),
            afterData: buildAuditCategoryState(
              categoryId,
              payload,
              existing.productsCount,
            ),
            metadata: {
              changedFields,
              previousGroupId: existing.groupId,
              nextGroupId: targetGroupId,
            },
            eventSource: "server_action",
          }),
        );

        if (
          existing.imagePath.length > 0 &&
          existing.imagePath !== payload.imagePath
        ) {
          oldImagePathToDelete = existing.imagePath;
        }

        if (
          existing.thumbPath.length > 0 &&
          existing.thumbPath !== payload.thumbPath &&
          existing.thumbPath !== oldImagePathToDelete
        ) {
          oldThumbPathToDelete = existing.thumbPath;
        }
      });

      await deleteStoragePath(oldImagePathToDelete);
      await deleteStoragePath(oldThumbPathToDelete);

      return {
        success: true,
        categoryId,
        auditLogId,
        changedFields,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("updateCategory failed", error);

      throw new HttpsError(
        "internal",
        "Failed to update category.",
      );
    }
  },
);