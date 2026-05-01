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

type JsonMap = Record<string, unknown>;

function normalizeCardLayoutType(value: unknown): string {
  const normalized = asTrimmedString(value).toLowerCase();
  return normalized.length > 0 ? normalized : "compact01";
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

export const adminSetProductEnabled = onCall<
  SetProductEnabledRequest,
  Promise<SetProductEnabledResponse>
>(async (request) => {
  try {
    logger.info("adminSetProductEnabled invoked", {
      uid: request.auth?.uid ?? null,
      productId: request.data?.productId ?? null,
      isEnabled:
        typeof request.data?.isEnabled === "boolean"
          ? request.data.isEnabled
          : null,
    });

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

      const currentData = normalizeExistingProductData(
        (currentSnap.data() ?? {}) as JsonMap,
      );

      if (currentData.isDeleted === true) {
        throw new HttpsError(
          "failed-precondition",
          "Deleted products cannot be enabled or disabled.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      const nextData: JsonMap = {
        ...currentData,
        isEnabled,
        status: isEnabled ? "active" : "inactive",
        updatedAt: now,
        updatedBy: actor.uid,
      };

      tx.set(productRef, nextData, { merge: false });

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
          beforeData: {
            isEnabled: currentData.isEnabled ?? null,
            isDeleted: currentData.isDeleted ?? null,
            cardLayoutType: currentData.cardLayoutType ?? "standard",
          },
          afterData: {
            isEnabled,
            isDeleted: currentData.isDeleted ?? null,
            cardLayoutType: nextData.cardLayoutType ?? "standard",
          },
          metadata: {
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
      isEnabled,
      auditLogId,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    logger.error("adminSetProductEnabled failed", {
      error,
      uid: request.auth?.uid ?? null,
      data: request.data ?? null,
    });

    throw new HttpsError("internal", "Failed to update product status.");
  }
});