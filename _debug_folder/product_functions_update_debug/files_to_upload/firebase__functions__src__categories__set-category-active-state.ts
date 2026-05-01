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
  asBoolOrThrow,
  asInt,
  asTrimmedString,
  groupIdFromParentId,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();

type SetCategoryActiveStateRequest = {
  categoryId?: string;
  isActive?: boolean;
  reason?: string | null;
};

type SetCategoryActiveStateResponse = {
  success: true;
  categoryId: string;
  isActive: boolean;
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

function buildAuditState(category: CategoryState): Record<string, unknown> {
  return {
    id: category.id,
    nameEn: category.nameEn,
    nameBn: category.nameBn,
    descriptionEn: category.descriptionEn,
    descriptionBn: category.descriptionBn,
    imageUrl: category.imageUrl,
    iconUrl: category.iconUrl,
    imagePath: category.imagePath,
    thumbPath: category.thumbPath,
    slug: category.slug,
    parentId: category.parentId ?? "",
    groupId: category.groupId,
    isFeatured: category.isFeatured,
    showOnHome: category.showOnHome,
    isActive: category.isActive,
    sortOrder: category.sortOrder,
    productsCount: category.productsCount,
  };
}

export const setCategoryActiveState = onCall<SetCategoryActiveStateRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<SetCategoryActiveStateResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageCategories",
      );

      const categoryId = asTrimmedString(request.data?.categoryId);
      const nextIsActive = asBoolOrThrow(request.data?.isActive, "isActive");
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(categoryId, "categoryId");

      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const categoryRef = db.collection("categories").doc(categoryId);
        const existingSnap = await tx.get(categoryRef);
        if (!existingSnap.exists) {
          throw new HttpsError("not-found", "Category not found.");
        }

        const existing = parseCategoryState(existingSnap);
        if (existing.isActive === nextIsActive) {
          throw new HttpsError(
            "failed-precondition",
            `Category is already ${nextIsActive ? "active" : "inactive"}.`,
          );
        }

        const afterState: CategoryState = {
          ...existing,
          isActive: nextIsActive,
        };

        tx.set(
          categoryRef,
          {
            isActive: nextIsActive,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: nextIsActive ? "activate_category" : "deactivate_category",
            module: "categories",
            targetType: "category",
            targetId: categoryId,
            targetTitle: existing.nameEn,
            status: "success",
            reason,
            beforeData: buildAuditState(existing),
            afterData: buildAuditState(afterState),
            metadata: {
              changedFields: ["isActive"],
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        categoryId,
        isActive: nextIsActive,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("setCategoryActiveState failed", error);
      throw new HttpsError(
        "internal",
        "Failed to change category active state.",
      );
    }
  },
);
