import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";
import {
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();

type DeleteProductRequest = {
  productId?: string;
  reason?: string | null;
};

type DeleteProductResponse = {
  success: true;
  productId: string;
  auditLogId: string;
};

export const adminDeleteProduct = onCall<
  DeleteProductRequest,
  Promise<DeleteProductResponse>
>(async (request) => {
  try {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canDeleteProducts",
    );

    const productId = asTrimmedString(request.data?.productId);
    const reason = normalizeNullableId(request.data?.reason);

    requireNonEmpty(productId, "productId");

    const productRef = db.collection("products").doc(productId);
    let auditLogId = "";

    await db.runTransaction(async (tx) => {
      const currentSnap = await tx.get(productRef);
      if (!currentSnap.exists) {
        throw new HttpsError("not-found", "Product not found.");
      }

      const currentData = (currentSnap.data() ?? {}) as Record<string, unknown>;

      if (currentData.isDeleted === true) {
        throw new HttpsError(
          "failed-precondition",
          "Product is already deleted.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();
      const nextData: Record<string, unknown> = {
        ...currentData,
        isDeleted: true,
        isEnabled: false,
        deletedAt: now,
        deletedBy: actor.uid,
        deleteReason: reason,
        updatedAt: now,
        updatedBy: actor.uid,
      };

      tx.set(productRef, nextData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "delete_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: asTrimmedString(currentData.titleEn) || productId,
          status: "success",
          reason,
          beforeData: currentData,
          afterData: nextData,
          metadata: {
            softDelete: true,
          },
          eventSource: "server_action",
        }),
      );
    });

    return {
      success: true,
      productId,
      auditLogId,
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;

    logger.error("adminDeleteProduct failed", error);
    throw new HttpsError("internal", "Failed to delete product.");
  }
});