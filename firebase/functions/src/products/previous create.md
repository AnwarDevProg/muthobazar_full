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

type CreateProductRequest = {
  product?: Record<string, unknown>;
  reason?: string | null;
};

type CreateProductResponse = {
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

function asBool(value: unknown, fallback = false): boolean {
  return typeof value === "boolean" ? value : fallback;
}

export const adminCreateProduct = onCall<
  CreateProductRequest,
  Promise<CreateProductResponse>
>(async (request) => {
  try {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canManageProducts",
    );

    const productInput = requireObjectRecord(request.data?.product, "product");
    const reason = normalizeNullableId(request.data?.reason);

    const sanitizedInput = sanitizeProductInput(productInput);

    const requestedId = asTrimmedString(sanitizedInput.id);
    const titleEn = asTrimmedString(sanitizedInput.titleEn);
    const slug = asTrimmedString(sanitizedInput.slug).toLowerCase();

    requireNonEmpty(titleEn, "product.titleEn");
    requireNonEmpty(slug, "product.slug");

    const productRef = requestedId.length > 0
      ? db.collection("products").doc(requestedId)
      : db.collection("products").doc();

    const productId = productRef.id;
    let auditLogId = "";

    await db.runTransaction(async (tx) => {
      const existingSnap = await tx.get(productRef);
      if (existingSnap.exists) {
        throw new HttpsError(
          "already-exists",
          "A product with this id already exists.",
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      const docData: Record<string, unknown> = {
        ...sanitizedInput,
        id: productId,
        titleEn,
        slug,
        isDeleted: false,
        deletedAt: null,
        deletedBy: null,
        deleteReason: null,
        createdAt: sanitizedInput.createdAt ?? now,
        updatedAt: now,
        createdBy: asTrimmedString(sanitizedInput.createdBy) || actor.uid,
        updatedBy: actor.uid,
        isEnabled: asBool(sanitizedInput.isEnabled, true),
      };

      tx.set(productRef, docData);

      const logRef = newAdminAuditLogRef();
      auditLogId = logRef.id;

      tx.set(
        logRef,
        buildAdminAuditLogDoc(logRef.id, actor, {
          action: "create_product",
          module: "products",
          targetType: "product",
          targetId: productId,
          targetTitle: titleEn,
          status: "success",
          reason,
          beforeData: null,
          afterData: {
            id: productId,
            titleEn,
            slug,
            isEnabled: docData.isEnabled,
            categoryId: docData.categoryId ?? null,
            brandId: docData.brandId ?? null,
          },
          metadata: {
            sku: docData.sku ?? null,
            productCode: docData.productCode ?? null,
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

    logger.error("adminCreateProduct failed", error);
    throw new HttpsError("internal", "Failed to create product.");
  }
});