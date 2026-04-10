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

type RestoreProductRequest = {
  productId?: string;
  reason?: string | null;
};

type RestoreProductResponse = {
  success: true;
  productId: string;
  auditLogId: string;
};

export const adminRestoreProduct = onCall<
  RestoreProductRequest,
  Promise<RestoreProductResponse>
>(async (request) => {
  try {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canRestoreProducts",
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

      if (currentData.isDeleted !== true) {
        throw new HttpsError(
          "failed-precondition",
          "Product is not in quarantine.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();
      const nextData: Record<string, unknown> = {
        ...currentData,
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
        deleteReason: null,
        updatedAt: now,
        updatedBy: actor.uid,
      };

      tx.set(productRef, nextData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "restore_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: asTrimmedString(currentData.titleEn) || productId,
          status: "success",
          reason,
          beforeData: currentData,
          afterData: nextData,
          metadata: {
            restoredFromQuarantine: true,
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

    logger.error("adminRestoreProduct failed", error);
    throw new HttpsError("internal", "Failed to restore product.");
  }
});