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
  requireObjectRecord,
} from "../utils/callable-parsers";

const db = admin.firestore();

type UpdateProductRequest = {
  product?: Record<string, unknown>;
  reason?: string | null;
};

type UpdateProductResponse = {
  success: true;
  productId: string;
  auditLogId: string;
};

function sanitizeFirestoreValue(value: unknown): unknown {
  if (value === undefined) return undefined;
  if (
    value === null ||
    typeof value === "string" ||
    typeof value === "number" ||
    typeof value === "boolean"
  ) {
    return value;
  }

  if (
    value instanceof Date ||
    value instanceof admin.firestore.Timestamp ||
    value instanceof admin.firestore.GeoPoint ||
    value instanceof admin.firestore.DocumentReference ||
    value instanceof admin.firestore.FieldValue
  ) {
    return value;
  }

  if (Array.isArray(value)) {
    return value
      .map((item) => sanitizeFirestoreValue(item))
      .filter((item) => item !== undefined);
  }

  if (typeof value === "object") {
    const input = value as Record<string, unknown>;
    const output: Record<string, unknown> = {};

    for (const [key, rawValue] of Object.entries(input)) {
      if (key.startsWith("clear")) continue;
      const sanitized = sanitizeFirestoreValue(rawValue);
      if (sanitized !== undefined) {
        output[key] = sanitized;
      }
    }

    return output;
  }

  return undefined;
}

function sanitizeProductInput(
  input: Record<string, unknown>,
): Record<string, unknown> {
  const sanitized = sanitizeFirestoreValue(input);
  if (!sanitized || typeof sanitized !== "object" || Array.isArray(sanitized)) {
    return {};
  }
  return sanitized as Record<string, unknown>;
}

export const adminUpdateProduct = onCall<
  UpdateProductRequest,
  Promise<UpdateProductResponse>
>(async (request) => {
  try {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canManageProducts",
    );

    const productInput = requireObjectRecord(request.data?.product, "product");
    const reason = normalizeNullableId(request.data?.reason);

    const sanitizedInput = sanitizeProductInput(productInput);
    const productId = asTrimmedString(sanitizedInput.id);

    requireNonEmpty(productId, "product.id");

    const productRef = db.collection("products").doc(productId);
    let auditLogId = "";

    await db.runTransaction(async (tx) => {
      const currentSnap = await tx.get(productRef);
      if (!currentSnap.exists) {
        throw new HttpsError("not-found", "Product not found.");
      }

      const currentData = (currentSnap.data() ?? {}) as Record<string, unknown>;
      const now = admin.firestore.FieldValue.serverTimestamp();

      const nextData: Record<string, unknown> = {
        ...currentData,
        ...sanitizedInput,
        id: productId,
        updatedAt: now,
        updatedBy: actor.uid,
      };

      if (asTrimmedString(nextData.titleEn).length === 0) {
        throw new HttpsError("invalid-argument", "product.titleEn is required.");
      }

      if (asTrimmedString(nextData.slug).length === 0) {
        throw new HttpsError("invalid-argument", "product.slug is required.");
      }

      tx.set(productRef, nextData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "update_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: asTrimmedString(nextData.titleEn),
          status: "success",
          reason,
          beforeData: currentData,
          afterData: nextData,
          metadata: {
            sku: nextData.sku ?? null,
            productCode: nextData.productCode ?? null,
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

    logger.error("adminUpdateProduct failed", error);
    throw new HttpsError("internal", "Failed to update product.");
  }
});