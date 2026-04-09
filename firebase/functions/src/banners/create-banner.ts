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
} from "../utils/callable-parsers";

const db = admin.firestore();

const ALLOWED_TARGET_TYPES = new Set<string>([
  "none",
  "product",
  "category",
  "brand",
  "route",
  "external",
]);

const ALLOWED_POSITIONS = new Set<string>([
  "home_hero",
  "home_secondary",
  "home_strip",
  "category_top",
  "brand_top",
  "generic",
]);

type CreateBannerRequest = {
  banner?: Record<string, unknown>;
};

type CreateBannerResponse = {
  success: true;
  bannerId: string;
  auditLogId: string;
};

type BannerPayload = {
  titleEn: string;
  titleBn: string;
  subtitleEn: string;
  subtitleBn: string;
  buttonTextEn: string;
  buttonTextBn: string;
  imageUrl: string;
  mobileImageUrl: string;
  targetType: string;
  targetId: string | null;
  targetRoute: string | null;
  externalUrl: string | null;
  isActive: boolean;
  showOnHome: boolean;
  position: string;
  sortOrder: number;
  startAt: string | null;
  endAt: string | null;
};

function normalizeNullableString(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length === 0 ? null : normalized;
}

function normalizeIsoDate(value: unknown, fieldName: string): string | null {
  const raw = asTrimmedString(value);
  if (raw.length === 0) {
    return null;
  }

  const parsed = new Date(raw);
  if (Number.isNaN(parsed.getTime())) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} must be a valid ISO datetime string.`,
    );
  }

  return parsed.toISOString();
}

function normalizeTargetType(value: unknown): string {
  const targetType = asTrimmedString(value).toLowerCase();
  return targetType.length === 0 ? "none" : targetType;
}

function normalizePosition(value: unknown): string {
  const position = asTrimmedString(value);
  return position.length === 0 ? "home_hero" : position;
}

function validateTargetRequirements(
  targetType: string,
  targetId: string | null,
  targetRoute: string | null,
  externalUrl: string | null,
): void {
  if (!ALLOWED_TARGET_TYPES.has(targetType)) {
    throw new HttpsError(
      "invalid-argument",
      "banner.targetType is not supported.",
    );
  }

  if (
    (targetType === "product" ||
      targetType === "category" ||
      targetType === "brand") &&
    !targetId
  ) {
    throw new HttpsError(
      "invalid-argument",
      "banner.targetId is required for product/category/brand target type.",
    );
  }

  if (targetType === "route" && !targetRoute) {
    throw new HttpsError(
      "invalid-argument",
      "banner.targetRoute is required for route target type.",
    );
  }

  if (targetType === "external" && !externalUrl) {
    throw new HttpsError(
      "invalid-argument",
      "banner.externalUrl is required for external target type.",
    );
  }
}

function normalizeBannerPayload(input: unknown): BannerPayload {
  const raw = requireObjectRecord(input, "banner");

  const titleEn = asTrimmedString(raw.titleEn);
  requireNonEmpty(titleEn, "banner.titleEn");

  const imageUrl = asTrimmedString(raw.imageUrl);
  const mobileImageUrl = asTrimmedString(raw.mobileImageUrl);
  requireNonEmpty(imageUrl, "banner.imageUrl");
  requireNonEmpty(mobileImageUrl, "banner.mobileImageUrl");

  const targetType = normalizeTargetType(raw.targetType);
  const targetId = normalizeNullableString(raw.targetId);
  const targetRoute = normalizeNullableString(raw.targetRoute);
  const externalUrl = normalizeNullableString(raw.externalUrl);
  validateTargetRequirements(targetType, targetId, targetRoute, externalUrl);

  const position = normalizePosition(raw.position);
  if (!ALLOWED_POSITIONS.has(position)) {
    throw new HttpsError(
      "invalid-argument",
      "banner.position is not supported.",
    );
  }

  const sortOrder = asInt(raw.sortOrder, 0);
  requireNonNegativeInt(sortOrder, "banner.sortOrder");

  const startAt = normalizeIsoDate(raw.startAt, "banner.startAt");
  const endAt = normalizeIsoDate(raw.endAt, "banner.endAt");
  if (startAt && endAt) {
    if (new Date(endAt).getTime() < new Date(startAt).getTime()) {
      throw new HttpsError(
        "invalid-argument",
        "banner.endAt must be after banner.startAt.",
      );
    }
  }

  return {
    titleEn,
    titleBn: asTrimmedString(raw.titleBn),
    subtitleEn: asTrimmedString(raw.subtitleEn),
    subtitleBn: asTrimmedString(raw.subtitleBn),
    buttonTextEn: asTrimmedString(raw.buttonTextEn),
    buttonTextBn: asTrimmedString(raw.buttonTextBn),
    imageUrl,
    mobileImageUrl,
    targetType,
    targetId,
    targetRoute,
    externalUrl,
    isActive: asBool(raw.isActive, true),
    showOnHome: asBool(raw.showOnHome, true),
    position,
    sortOrder,
    startAt,
    endAt,
  };
}

function buildBannerDoc(
  bannerId: string,
  payload: BannerPayload,
): Record<string, unknown> {
  const now = admin.firestore.FieldValue.serverTimestamp();

  return {
    id: bannerId,
    titleEn: payload.titleEn,
    titleBn: payload.titleBn,
    subtitleEn: payload.subtitleEn,
    subtitleBn: payload.subtitleBn,
    buttonTextEn: payload.buttonTextEn,
    buttonTextBn: payload.buttonTextBn,
    imageUrl: payload.imageUrl,
    mobileImageUrl: payload.mobileImageUrl,
    targetType: payload.targetType,
    targetId: payload.targetId,
    targetRoute: payload.targetRoute,
    externalUrl: payload.externalUrl,
    isActive: payload.isActive,
    showOnHome: payload.showOnHome,
    position: payload.position,
    sortOrder: payload.sortOrder,
    startAt: payload.startAt,
    endAt: payload.endAt,
    createdAt: now,
    updatedAt: now,
  };
}

function buildAuditAfterData(
  bannerId: string,
  payload: BannerPayload,
): Record<string, unknown> {
  return {
    id: bannerId,
    titleEn: payload.titleEn,
    titleBn: payload.titleBn,
    subtitleEn: payload.subtitleEn,
    subtitleBn: payload.subtitleBn,
    buttonTextEn: payload.buttonTextEn,
    buttonTextBn: payload.buttonTextBn,
    imageUrl: payload.imageUrl,
    mobileImageUrl: payload.mobileImageUrl,
    targetType: payload.targetType,
    targetId: payload.targetId,
    targetRoute: payload.targetRoute,
    externalUrl: payload.externalUrl,
    isActive: payload.isActive,
    showOnHome: payload.showOnHome,
    position: payload.position,
    sortOrder: payload.sortOrder,
    startAt: payload.startAt,
    endAt: payload.endAt,
  };
}

export const createBanner = onCall<CreateBannerRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<CreateBannerResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBanners",
      );

      const payload = normalizeBannerPayload(request.data?.banner);
      const bannerRef = db.collection("banners").doc();
      const bannerId = bannerRef.id;
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const sortQuery = db
          .collection("banners")
          .where("sortOrder", "==", payload.sortOrder)
          .limit(1);
        const sortSnap = await tx.get(sortQuery);
        if (!sortSnap.empty) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another banner. Please use another.",
          );
        }

        tx.set(bannerRef, buildBannerDoc(bannerId, payload));

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;
        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "create_banner",
            module: "banners",
            targetType: "banner",
            targetId: bannerId,
            targetTitle: payload.titleEn,
            status: "success",
            beforeData: null,
            afterData: buildAuditAfterData(bannerId, payload),
            metadata: {
              bannerTargetType: payload.targetType,
              position: payload.position,
              sortOrder: payload.sortOrder,
              isActive: payload.isActive,
              showOnHome: payload.showOnHome,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        bannerId,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("createBanner failed", error);
      throw new HttpsError("internal", "Failed to create banner.");
    }
  },
);
