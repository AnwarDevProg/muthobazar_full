import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";

const db = admin.firestore();

function normalizeGroupId(input: unknown): string {
  const value = String(input ?? "").trim();
  return value.length === 0 ? "root" : value;
}

export const reorderCategoryGroup = onCall(async (request) => {
  const data = request.data ?? {};

  const groupIdRaw = data.groupId;
  const orderedCategoryIdsRaw = data.orderedCategoryIds;

  const groupId = normalizeGroupId(groupIdRaw);

  if (!Array.isArray(orderedCategoryIdsRaw) || orderedCategoryIdsRaw.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "orderedCategoryIds must be a non-empty array.",
    );
  }

  const orderedCategoryIds = orderedCategoryIdsRaw
    .map((item) => String(item ?? "").trim())
    .filter((item) => item.length > 0);

  if (orderedCategoryIds.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "orderedCategoryIds must contain valid ids.",
    );
  }

  const duplicateCheck = new Set<string>();
  for (const id of orderedCategoryIds) {
    if (duplicateCheck.has(id)) {
      throw new HttpsError(
        "invalid-argument",
        "orderedCategoryIds contains duplicates.",
      );
    }
    duplicateCheck.add(id);
  }

  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(
      db.collection("categories").where("groupId", "==", groupId),
    );

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

    for (let index = 0; index < orderedCategoryIds.length; index++) {
      const id = orderedCategoryIds[index];
      const ref = db.collection("categories").doc(id);

      tx.update(ref, {
        sortOrder: index,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

  return {
    success: true,
    groupId,
    count: orderedCategoryIds.length,
  };
});