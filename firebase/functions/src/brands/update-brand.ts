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
  asInt,
  asTrimmedString,
  requireNonEmpty,
  requireNonNegativeInt,
  requireObjectRecord,
  slugify,
} from "../utils/callable-parsers";

const db = admin.firestore();

type UpdateBrandRequest = {
  brandId?: string;
  brand?: Record<string, unknown>;
};

type UpdateBrandResponse = {
  success: true;
  brandId: string;
  auditLogId: string;
};

type BrandPayload = {
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
};

type ExistingBrandSnapshot = {
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

function normalizeBrandPayload(input: unknown): BrandPayload {
  const raw = requireObjectRecord(input, "brand");

  const nameEn = asTrimmedString(raw.nameEn);
  const nameBn = asTrimmedString(raw.nameBn);
  const descriptionEn = asTrimmedString(raw.descriptionEn);
  const descriptionBn = asTrimmedString(raw.descriptionBn);
  const imageUrl = asTrimmedString(raw.imageUrl);
  const logoUrl = asTrimmedString(raw.logoUrl);
  const imagePath = asTrimmedString(raw.imagePath);
  const thumbPath = asTrimmedString(raw.thumbPath);

  requireNonEmpty(nameEn, "brand.nameEn");

  const normalizedSlug = slugify(
    asTrimmedString(raw.slug).length > 0 ? asTrimmedString(raw.slug) : nameEn,
  );
  requireNonEmpty(normalizedSlug, "brand.slug");

  const sortOrder = asInt(raw.sortOrder, 0);
  requireNonNegativeInt(sortOrder, "brand.sortOrder");

  if (imageUrl.length === 0 && logoUrl.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "brand.imageUrl or brand.logoUrl is required.",
    );
  }

  return {
    nameEn,
    nameBn,
    descriptionEn,
    descriptionBn,
    imageUrl,
    logoUrl,
    imagePath,
    thumbPath,
    slug: normalizedSlug,
    isFeatured: asBool(raw.isFeatured, false),
    showOnHome: asBool(raw.showOnHome, false),
    isActive: asBool(raw.isActive, true),
    sortOrder,
  };
}

function parseExistingBrand(
  doc: admin.firestore.DocumentSnapshot,
): ExistingBrandSnapshot {
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

function buildUpdatedBrandDoc(
  payload: BrandPayload,
  productsCount: number,
): admin.firestore.DocumentData {
  return {
    nameEn: payload.nameEn,
    nameBn: payload.nameBn,
    descriptionEn: payload.descriptionEn,
    descriptionBn: payload.descriptionBn,
    imageUrl: payload.imageUrl,
    logoUrl: payload.logoUrl,
    imagePath: payload.imagePath,
    thumbPath: payload.thumbPath,
    slug: payload.slug,
    isFeatured: payload.isFeatured,
    showOnHome: payload.showOnHome,
    isActive: payload.isActive,
    sortOrder: payload.sortOrder,
    productsCount,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditBeforeData(
  current: ExistingBrandSnapshot,
): Record<string, unknown> {
  return {
    id: current.id,
    nameEn: current.nameEn,
    nameBn: current.nameBn,
    descriptionEn: current.descriptionEn,
    descriptionBn: current.descriptionBn,
    imageUrl: current.imageUrl,
    logoUrl: current.logoUrl,
    imagePath: current.imagePath,
    thumbPath: current.thumbPath,
    slug: current.slug,
    isFeatured: current.isFeatured,
    showOnHome: current.showOnHome,
    isActive: current.isActive,
    sortOrder: current.sortOrder,
    productsCount: current.productsCount,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
  };
}

function buildAuditAfterData(
  brandId: string,
  payload: BrandPayload,
  productsCount: number,
  createdAt: unknown,
): Record<string, unknown> {
  return {
    id: brandId,
    nameEn: payload.nameEn,
    nameBn: payload.nameBn,
    descriptionEn: payload.descriptionEn,
    descriptionBn: payload.descriptionBn,
    imageUrl: payload.imageUrl,
    logoUrl: payload.logoUrl,
    imagePath: payload.imagePath,
    thumbPath: payload.thumbPath,
    slug: payload.slug,
    isFeatured: payload.isFeatured,
    showOnHome: payload.showOnHome,
    isActive: payload.isActive,
    sortOrder: payload.sortOrder,
    productsCount,
    createdAt: createdAt ?? null,
  };
}

export const updateBrand = onCall<UpdateBrandRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<UpdateBrandResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const brandId = asTrimmedString(request.data?.brandId);
      requireNonEmpty(brandId, "brandId");

      const payload = normalizeBrandPayload(request.data?.brand);
      const brandRef = db.collection("brands").doc(brandId);
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const currentSnap = await tx.get(brandRef);
        if (!currentSnap.exists) {
          throw new HttpsError("not-found", "Brand not found.");
        }

        const current = parseExistingBrand(currentSnap);
        const beforeData = buildAuditBeforeData(current);
        const productsCount = current.productsCount;

        const slugQuery = db
          .collection("brands")
          .where("slug", "==", payload.slug)
          .limit(10);
        const slugSnap = await tx.get(slugQuery);
        const slugConflict = slugSnap.docs.find((doc) => doc.id !== brandId);
        if (slugConflict) {
          throw new HttpsError(
            "already-exists",
            "A brand with the same slug already exists.",
          );
        }

        const sortQuery = db
          .collection("brands")
          .where("sortOrder", "==", payload.sortOrder)
          .limit(10);
        const sortSnap = await tx.get(sortQuery);
        const sortConflict = sortSnap.docs.find((doc) => doc.id !== brandId);
        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another brand. Please use another.",
          );
        }

        tx.set(
          brandRef,
          buildUpdatedBrandDoc(payload, productsCount),
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "update_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData,
            afterData: buildAuditAfterData(
              brandId,
              payload,
              productsCount,
              current.createdAt,
            ),
            metadata: {
              sortOrder: payload.sortOrder,
              isFeatured: payload.isFeatured,
              showOnHome: payload.showOnHome,
              isActive: payload.isActive,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        brandId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("updateBrand failed", error);
      throw new HttpsError("internal", "Failed to update brand.");
    }
  },
);
