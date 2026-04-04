import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";

const db = admin.firestore();

function normalizeGroupId(input: unknown): string {
  const value = String(input ?? "").trim();
  return value.length === 0 ? "root" : value;
}

export const fixCategoryGroupSort = onCall(async (request) => {
  const data = request.data ?? {};
  const groupId = normalizeGroupId(data.groupId);

  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(
      db.collection("categories").where("groupId", "==", groupId),
    );

    const ordered = snapshot.docs
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

    for (let i = 0; i < ordered.length; i++) {
      tx.update(db.collection("categories").doc(ordered[i].id), {
        sortOrder: i,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

  return {
    success: true,
    groupId,
  };
});