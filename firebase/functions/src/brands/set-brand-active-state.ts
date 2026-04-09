import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  buildAdminAuditLogDoc,
  getAuthorizedAdminActor,
  newAdminAuditLogRef,
} from "../admin/audit-log-core";
import {
  asBool,
  asBoolOrThrow,
  asInt,
  asTrimmedString,
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();

type SetBrandActiveStateRequest = {
  brandId?: string;
  isActive?: boolean;
  reason?: string | null;
};

type SetBrandActiveStateResponse = {
  success: true;
  brandId: string;
  isActive: boolean;
  auditLogId: string;
};

type BrandState = {
  id: string;
  nameEn: string;
  nameBn: string;
  descriptionEn: string;
  descriptionBn: string;
  imageUrl: string;
  logoUrl: string;
  imagePath: string;
  thumbPath: string;
  slug: string;
  isFeatured: boolean;
  showOnHome: boolean;
  isActive: boolean;
  sortOrder: number;
  productsCount: number;
  createdAt: unknown;
  updatedAt: unknown;
};

function parseBrandState(
  doc: admin.firestore.DocumentSnapshot | admin.firestore.QueryDocumentSnapshot,
): BrandState {
  const data = doc.data() ?? {};

  return {
    id: doc.id,
    nameEn: asTrimmedString(data.nameEn),
    nameBn: asTrimmedString(data.nameBn),
    descriptionEn: asTrimmedString(data.descriptionEn),
    descriptionBn: asTrimmedString(data.descriptionBn),
    imageUrl: asTrimmedString(data.imageUrl),
    logoUrl: asTrimmedString(data.logoUrl),
    imagePath: asTrimmedString(data.imagePath),
    thumbPath: asTrimmedString(data.thumbPath),
    slug: asTrimmedString(data.slug).toLowerCase(),
    isFeatured: asBool(data.isFeatured, false),
    showOnHome: asBool(data.showOnHome, false),
    isActive: asBool(data.isActive, true),
    sortOrder: asInt(data.sortOrder, 0),
    productsCount: asInt(data.productsCount, 0),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
  };
}

function buildAuditState(brand: BrandState): Record<string, unknown> {
  return {
    id: brand.id,
    nameEn: brand.nameEn,
    nameBn: brand.nameBn,
    descriptionEn: brand.descriptionEn,
    descriptionBn: brand.descriptionBn,
    imageUrl: brand.imageUrl,
    logoUrl: brand.logoUrl,
    imagePath: brand.imagePath,
    thumbPath: brand.thumbPath,
    slug: brand.slug,
    isFeatured: brand.isFeatured,
    showOnHome: brand.showOnHome,
    isActive: brand.isActive,
    sortOrder: brand.sortOrder,
    productsCount: brand.productsCount,
    createdAt: brand.createdAt ?? null,
    updatedAt: brand.updatedAt ?? null,
  };
}

export const setBrandActiveState = onCall<SetBrandActiveStateRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<SetBrandActiveStateResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const brandId = asTrimmedString(request.data?.brandId);
      const nextIsActive = asBoolOrThrow(request.data?.isActive, "isActive");
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(brandId, "brandId");

      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const brandRef = db.collection("brands").doc(brandId);
        const existingSnap = await tx.get(brandRef);
        if (!existingSnap.exists) {
          throw new HttpsError("not-found", "Brand not found.");
        }

        const existing = parseBrandState(existingSnap);
        if (existing.isActive === nextIsActive) {
          throw new HttpsError(
            "failed-precondition",
            `Brand is already ${nextIsActive ? "active" : "inactive"}.`,
          );
        }

        const afterState: BrandState = {
          ...existing,
          isActive: nextIsActive,
        };

        tx.set(
          brandRef,
          {
            isActive: nextIsActive,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: nextIsActive ? "activate_brand" : "deactivate_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: existing.nameEn,
            status: "success",
            reason,
            beforeData: buildAuditState(existing),
            afterData: buildAuditState(afterState),
            metadata: {
              changedFields: ["isActive"],
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        brandId,
        isActive: nextIsActive,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("setBrandActiveState failed", error);
      throw new HttpsError(
        "internal",
        "Failed to update brand status.",
      );
    }
  },
);
