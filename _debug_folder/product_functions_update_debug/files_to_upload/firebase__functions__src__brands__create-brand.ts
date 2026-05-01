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

type CreateBrandRequest = {
  brand?: Record<string, unknown>;
};

type CreateBrandResponse = {
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
  slug: string;
  sortOrder: number;
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

function buildBrandDoc(
  brandId: string,
  payload: BrandPayload,
): admin.firestore.DocumentData {
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
    productsCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditAfterData(
  brandId: string,
  payload: BrandPayload,
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
    productsCount: 0,
  };
}

function parseExistingBrand(
  doc: admin.firestore.QueryDocumentSnapshot,
): ExistingBrandSnapshot {
  const data = doc.data() ?? {};
  return {
    id: doc.id,
    nameEn: asTrimmedString(data.nameEn),
    slug: asTrimmedString(data.slug).toLowerCase(),
    sortOrder: asInt(data.sortOrder, 0),
  };
}

export const createBrand = onCall<CreateBrandRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<CreateBrandResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBrands",
      );

      const payload = normalizeBrandPayload(request.data?.brand);
      const brandRef = db.collection("brands").doc();
      const brandId = brandRef.id;
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const slugQuery = db
          .collection("brands")
          .where("slug", "==", payload.slug)
          .limit(1);
        const slugSnap = await tx.get(slugQuery);
        if (!slugSnap.empty) {
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
        const sortConflict = sortSnap.docs
          .map(parseExistingBrand)
          .find((item) => item.sortOrder === payload.sortOrder);

        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another brand. Please use another.",
          );
        }

        tx.set(brandRef, buildBrandDoc(brandId, payload));

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "create_brand",
            module: "brands",
            targetType: "brand",
            targetId: brandId,
            targetTitle: payload.nameEn,
            status: "success",
            beforeData: null,
            afterData: buildAuditAfterData(brandId, payload),
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

      logger.error("createBrand failed", error);
      throw new HttpsError("internal", "Failed to create brand.");
    }
  },
);
