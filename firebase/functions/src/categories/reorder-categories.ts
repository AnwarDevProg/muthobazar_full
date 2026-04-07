import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";

const db = admin.firestore();

function normalizeGroupId(input: unknown): string {
  const value = String(input ?? "").trim();
  return value.length === 0 ? "root" : value;
}

function normalizeOrderedIds(input: unknown): string[] {
  if (!Array.isArray(input) || input.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "orderedCategoryIds must be a non-empty array.",
    );
  }

  const normalized = input
    .map((item) => String(item ?? "").trim())
    .filter((item) => item.length > 0);

  if (normalized.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "orderedCategoryIds must contain valid ids.",
    );
  }

  const seen = new Set<string>();
  for (const id of normalized) {
    if (seen.has(id)) {
      throw new HttpsError(
        "invalid-argument",
        "orderedCategoryIds contains duplicates.",
      );
    }
    seen.add(id);
  }

  return normalized;
}

function getGroupTitle(groupId: string): string {
  return groupId === "root" ? "Root Category Group" : `Category Group ${groupId}`;
}

export const reorderCategoryGroup = onCall(async (request) => {
  const actor = await getAuthorizedAdminActor(
    request.auth?.uid,
    "canManageCategories",
  );

  const data = request.data ?? {};
  const groupId = normalizeGroupId(data.groupId);
  const orderedCategoryIds = normalizeOrderedIds(data.orderedCategoryIds);

  let auditLogId = "";

  await db.runTransaction(async (tx) => {
    const query = db.collection("categories").where("groupId", "==", groupId);
    const snapshot = await tx.get(query);

    const existingDocs = snapshot.docs;
    const existingIds = new Set(existingDocs.map((doc) => doc.id));
    const providedIds = new Set(orderedCategoryIds);

    if (existingIds.size !== providedIds.size) {
      throw new HttpsError(
        "failed-precondition",
        "Category group changed. Please reload and try again.",
      );
    }

    for (const id of orderedCategoryIds) {
      if (!existingIds.has(id)) {
        throw new HttpsError(
          "failed-precondition",
          "Category group changed. Please reload and try again.",
        );
      }
    }

    const beforeOrderedCategoryIds = existingDocs
      .map((doc) => ({
        id: doc.id,
        sortOrder: Number(doc.data().sortOrder ?? 0),
        nameEn: String(doc.data().nameEn ?? "").toLowerCase(),
      }))
      .sort((a, b) => {
        const bySort = a.sortOrder - b.sortOrder;
        if (bySort !== 0) return bySort;
        return a.nameEn.localeCompare(b.nameEn);
      })
      .map((item) => item.id);

    for (let index = 0; index < orderedCategoryIds.length; index++) {
      const id = orderedCategoryIds[index];
      tx.update(db.collection("categories").doc(id), {
        sortOrder: index,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const logRef = newAdminAuditLogRef();
    auditLogId = logRef.id;

    tx.set(
      logRef,
      buildAdminAuditLogDoc(logRef.id, actor, {
        action: "reorder_category_group",
        module: "categories",
        targetType: "category_group",
        targetId: groupId,
        targetTitle: getGroupTitle(groupId),
        status: "success",
        beforeData: {
          orderedCategoryIds: beforeOrderedCategoryIds,
        },
        afterData: {
          orderedCategoryIds,
        },
        metadata: {
          count: orderedCategoryIds.length,
        },
        eventSource: "server_action",
      }),
    );
  });

  return {
    success: true,
    groupId,
    count: orderedCategoryIds.length,
    auditLogId,
  };
});