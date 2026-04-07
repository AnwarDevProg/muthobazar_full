import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";

const db = admin.firestore();

type CreateCategoryRequest = {
  category?: Record<string, unknown>;
};

type CreateCategoryResponse = {
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
  slug: string;
  sortOrder: number;
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

function buildCategoryDoc(
  categoryId: string,
  payload: CategoryPayload,
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
    productsCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditAfterData(
  categoryId: string,
  payload: CategoryPayload,
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
    productsCount: 0,
  };
}

function parseExistingCategory(doc: admin.firestore.QueryDocumentSnapshot): ExistingCategorySnapshot {
  const data = doc.data() ?? {};

  return {
    id: doc.id,
    nameEn: String(data.nameEn ?? "").trim(),
    slug: String(data.slug ?? "").trim().toLowerCase(),
    sortOrder: asInt(data.sortOrder, 0),
  };
}

export const createCategory = onCall<CreateCategoryRequest>(
  async (request): Promise<CreateCategoryResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const payload = normalizeCategoryPayload(request.data?.category);
      const categoryRef = db.collection("categories").doc();
      const categoryId = categoryRef.id;
      const groupId = groupIdFromParentId(payload.parentId);

      let auditLogId = "";

      await db.runTransaction(async (tx) => {
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
          .limit(1);

        const slugSnap = await tx.get(slugQuery);
        if (!slugSnap.empty) {
          throw new HttpsError(
            "already-exists",
            "A category with the same slug already exists.",
          );
        }

        const groupQuery = db
          .collection("categories")
          .where("groupId", "==", groupId);

        const groupSnap = await tx.get(groupQuery);
        const siblings = groupSnap.docs.map(parseExistingCategory);

        const sortConflict = siblings.find(
          (item) => item.sortOrder === payload.sortOrder,
        );

        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists in this group. Please use another.",
          );
        }

        tx.set(
          categoryRef,
          buildCategoryDoc(categoryId, payload),
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "create_category",
            module: "categories",
            targetType: "category",
            targetId: categoryId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData: null,
            afterData: buildAuditAfterData(categoryId, payload),
            metadata: {
              parentId: payload.parentId ?? "",
              groupId,
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

      logger.error("createCategory failed", error);

      throw new HttpsError(
        "internal",
        "Failed to create category.",
      );
    }
  },
);