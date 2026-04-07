import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";

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

function getGroupTitle(groupId: string): string {
  return groupId === "root" ? "Root Category Group" : `Category Group ${groupId}`;
}

export const fixCategoryGroupSort = onCall(async (request) => {
  const actor = await getAuthorizedAdminActor(
    request.auth?.uid,
    "canManageCategories",
  );

  const data = request.data ?? {};
  const groupId = normalizeGroupId(data.groupId);

  let auditLogId = "";

  await db.runTransaction(async (tx) => {
    const query = db.collection("categories").where("groupId", "==", groupId);
    const snapshot = await tx.get(query);

    const beforeOrder = snapshot.docs
      .map((doc) => ({
        id: doc.id,
        sortOrder: Number(doc.data().sortOrder ?? 0),
        nameEn: String(doc.data().nameEn ?? "").toLowerCase(),
      }))
      .sort((a, b) => {
        const bySort = a.sortOrder - b.sortOrder;
        if (bySort !== 0) return bySort;
        return a.nameEn.localeCompare(b.nameEn);
      });

    const afterOrder = beforeOrder.map((item, index) => ({
      id: item.id,
      sortOrder: index,
    }));

    for (let index = 0; index < beforeOrder.length; index++) {
      tx.update(db.collection("categories").doc(beforeOrder[index].id), {
        sortOrder: index,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const logRef = newAdminAuditLogRef();
    auditLogId = logRef.id;

    tx.set(
      logRef,
      buildAdminAuditLogDoc(logRef.id, actor, {
        action: "fix_category_group_sort",
        module: "categories",
        targetType: "category_group",
        targetId: groupId,
        targetTitle: getGroupTitle(groupId),
        status: "success",
        beforeData: {
          items: beforeOrder,
        },
        afterData: {
          items: afterOrder,
        },
        metadata: {
          count: beforeOrder.length,
        },
        eventSource: "server_action",
      }),
    );
  });

  return {
    success: true,
    groupId,
    auditLogId,
  };
});