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

type UpdateBannerRequest = {
  bannerId?: string;
  banner?: Record<string, unknown>;
};

type UpdateBannerResponse = {
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

type ExistingBannerSnapshot = {
  id: string;
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
  createdAt: unknown;
  updatedAt: unknown;
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

function parseExistingBanner(
  doc: admin.firestore.DocumentSnapshot,
): ExistingBannerSnapshot {
  const data = doc.data() ?? {};

  return {
    id: doc.id,
    titleEn: asTrimmedString(data.titleEn),
    titleBn: asTrimmedString(data.titleBn),
    subtitleEn: asTrimmedString(data.subtitleEn),
    subtitleBn: asTrimmedString(data.subtitleBn),
    buttonTextEn: asTrimmedString(data.buttonTextEn),
    buttonTextBn: asTrimmedString(data.buttonTextBn),
    imageUrl: asTrimmedString(data.imageUrl),
    mobileImageUrl: asTrimmedString(data.mobileImageUrl),
    targetType: normalizeTargetType(data.targetType),
    targetId: normalizeNullableString(data.targetId),
    targetRoute: normalizeNullableString(data.targetRoute),
    externalUrl: normalizeNullableString(data.externalUrl),
    isActive: asBool(data.isActive, true),
    showOnHome: asBool(data.showOnHome, true),
    position: normalizePosition(data.position),
    sortOrder: asInt(data.sortOrder, 0),
    startAt: normalizeNullableString(data.startAt),
    endAt: normalizeNullableString(data.endAt),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
  };
}

function buildUpdatedBannerDoc(
  payload: BannerPayload,
): Record<string, unknown> {
  return {
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
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function buildAuditBeforeData(
  current: ExistingBannerSnapshot,
): Record<string, unknown> {
  return {
    id: current.id,
    titleEn: current.titleEn,
    titleBn: current.titleBn,
    subtitleEn: current.subtitleEn,
    subtitleBn: current.subtitleBn,
    buttonTextEn: current.buttonTextEn,
    buttonTextBn: current.buttonTextBn,
    imageUrl: current.imageUrl,
    mobileImageUrl: current.mobileImageUrl,
    targetType: current.targetType,
    targetId: current.targetId,
    targetRoute: current.targetRoute,
    externalUrl: current.externalUrl,
    isActive: current.isActive,
    showOnHome: current.showOnHome,
    position: current.position,
    sortOrder: current.sortOrder,
    startAt: current.startAt,
    endAt: current.endAt,
    createdAt: current.createdAt ?? null,
    updatedAt: current.updatedAt ?? null,
  };
}

function buildAuditAfterData(
  bannerId: string,
  payload: BannerPayload,
  createdAt: unknown,
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
    createdAt: createdAt ?? null,
  };
}

export const updateBanner = onCall<UpdateBannerRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<UpdateBannerResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBanners",
      );

      const bannerId = asTrimmedString(request.data?.bannerId);
      requireNonEmpty(bannerId, "bannerId");

      const payload = normalizeBannerPayload(request.data?.banner);
      const bannerRef = db.collection("banners").doc(bannerId);
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const currentSnap = await tx.get(bannerRef);
        if (!currentSnap.exists) {
          throw new HttpsError("not-found", "Banner not found.");
        }

        const current = parseExistingBanner(currentSnap);
        const beforeData = buildAuditBeforeData(current);

        const sortQuery = db
          .collection("banners")
          .where("sortOrder", "==", payload.sortOrder)
          .limit(10);
        const sortSnap = await tx.get(sortQuery);
        const sortConflict = sortSnap.docs.find((doc) => doc.id !== bannerId);
        if (sortConflict) {
          throw new HttpsError(
            "already-exists",
            "Sort number already exists for another banner. Please use another.",
          );
        }

        tx.set(
          bannerRef,
          buildUpdatedBannerDoc(payload),
          { merge: true },
        );

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;
        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "update_banner",
            module: "banners",
            targetType: "banner",
            targetId: bannerId,
            targetTitle: payload.titleEn,
            status: "success",
            beforeData,
            afterData: buildAuditAfterData(
              bannerId,
              payload,
              current.createdAt,
            ),
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

      logger.error("updateBanner failed", error);
      throw new HttpsError("internal", "Failed to update banner.");
    }
  },
);
