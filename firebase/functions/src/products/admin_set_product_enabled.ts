import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";
import {
  asBoolOrThrow,
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();

type SetProductEnabledRequest = {
  productId?: string;
  isEnabled?: boolean;
  reason?: string | null;
};

type SetProductEnabledResponse = {
  success: true;
  productId: string;
  isEnabled: boolean;
  auditLogId: string;
};

export const adminSetProductEnabled = onCall<
  SetProductEnabledRequest,
  Promise<SetProductEnabledResponse>
>(async (request) => {
  try {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canManageProducts",
    );

    const productId = asTrimmedString(request.data?.productId);
    const isEnabled = asBoolOrThrow(request.data?.isEnabled, "isEnabled");
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
          "Deleted products cannot be enabled or disabled.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();
      const nextData: Record<string, unknown> = {
        ...currentData,
        isEnabled,
        updatedAt: now,
        updatedBy: actor.uid,
      };

      tx.set(productRef, nextData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: isEnabled ? "enable_product" : "disable_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: asTrimmedString(currentData.titleEn) || productId,
          status: "success",
          reason,
          beforeData: currentData,
          afterData: nextData,
          metadata: {
            isEnabled,
          },
          eventSource: "server_action",
        }),
      );
    });

    return {
      success: true,
      productId,
      isEnabled,
      auditLogId,
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;

    logger.error("adminSetProductEnabled failed", error);
    throw new HttpsError("internal", "Failed to update product status.");
  }
});