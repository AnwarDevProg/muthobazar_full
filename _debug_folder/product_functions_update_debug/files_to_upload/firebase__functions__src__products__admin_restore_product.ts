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

type JsonMap = Record<string, unknown>;

function normalizeCardLayoutType(value: unknown): string {
  const normalized = asTrimmedString(value).toLowerCase();

  switch (normalized) {
    case "compact":
    case "deal":
    case "featured":
    case "standard":
      return normalized;
    default:
      return "standard";
  }
}

function normalizeExistingProductData(input: JsonMap): JsonMap {
  const output: JsonMap = { ...input };

  output.cardLayoutType = normalizeCardLayoutType(input.cardLayoutType);

  if (asTrimmedString(output.productType).length === 0) {
    output.productType = "simple";
  }

  if (asTrimmedString(output.inventoryMode).length === 0) {
    output.inventoryMode = "stocked";
  }

  if (asTrimmedString(output.schedulePriceType).length === 0) {
    output.schedulePriceType = "fixed";
  }

  if (asTrimmedString(output.quantityType).length === 0) {
    output.quantityType = "pcs";
  }

  if (asTrimmedString(output.toleranceType).length === 0) {
    output.toleranceType = "g";
  }

  if (asTrimmedString(output.deliveryShift).length === 0) {
    output.deliveryShift = "any";
  }

  return output;
}

export const adminRestoreProduct = onCall<
  RestoreProductRequest,
  Promise<RestoreProductResponse>
>(async (request) => {
  try {
    logger.info("adminRestoreProduct invoked", {
      uid: request.auth?.uid ?? null,
      productId: request.data?.productId ?? null,
    });

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

      const currentData = normalizeExistingProductData(
        (currentSnap.data() ?? {}) as JsonMap,
      );

      if (currentData.isDeleted !== true) {
        throw new HttpsError(
          "failed-precondition",
          "Product is not in quarantine.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      const nextData: JsonMap = {
        ...currentData,
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
        deleteReason: null,
        updatedAt: now,
        updatedBy: actor.uid,
      };

      tx.set(productRef, nextData, { merge: false });

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
          beforeData: {
            isDeleted: currentData.isDeleted ?? null,
            isEnabled: currentData.isEnabled ?? null,
            deletedBy: currentData.deletedBy ?? null,
            deleteReason: currentData.deleteReason ?? null,
            cardLayoutType: currentData.cardLayoutType ?? "standard",
          },
          afterData: {
            isDeleted: false,
            isEnabled: nextData.isEnabled ?? null,
            deletedBy: null,
            deleteReason: null,
            cardLayoutType: nextData.cardLayoutType ?? "standard",
          },
          metadata: {
            restoredFromQuarantine: true,
            productType: currentData.productType ?? null,
            categoryId: currentData.categoryId ?? null,
            brandId: currentData.brandId ?? null,
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
    if (error instanceof HttpsError) {
      throw error;
    }

    logger.error("adminRestoreProduct failed", {
      error,
      uid: request.auth?.uid ?? null,
      data: request.data ?? null,
    });

    throw new HttpsError("internal", "Failed to restore product.");
  }
});