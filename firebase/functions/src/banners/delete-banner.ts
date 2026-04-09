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
  normalizeNullableId,
  requireNonEmpty,
} from "../utils/callable-parsers";

const db = admin.firestore();

type DeleteBannerRequest = {
  bannerId?: string;
  reason?: string | null;
};

type DeleteBannerResponse = {
  success: true;
  bannerId: string;
  auditLogId: string;
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
    targetType: asTrimmedString(data.targetType).toLowerCase(),
    targetId: normalizeNullableId(data.targetId),
    targetRoute: normalizeNullableId(data.targetRoute),
    externalUrl: normalizeNullableId(data.externalUrl),
    isActive: asBool(data.isActive, true),
    showOnHome: asBool(data.showOnHome, true),
    position: asTrimmedString(data.position),
    sortOrder: asInt(data.sortOrder, 0),
    startAt: normalizeNullableId(data.startAt),
    endAt: normalizeNullableId(data.endAt),
    createdAt: data.createdAt ?? null,
    updatedAt: data.updatedAt ?? null,
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

export const deleteBanner = onCall<DeleteBannerRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<DeleteBannerResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBanners",
      );

      const bannerId = asTrimmedString(request.data?.bannerId);
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(bannerId, "bannerId");

      const bannerRef = db.collection("banners").doc(bannerId);
      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const currentSnap = await tx.get(bannerRef);
        if (!currentSnap.exists) {
          throw new HttpsError("not-found", "Banner not found.");
        }

        const current = parseExistingBanner(currentSnap);

        const logRef = newAdminAuditLogRef();
        auditLogId = logRef.id;

        tx.set(
          logRef,
          buildAdminAuditLogDoc(logRef.id, actor, {
            action: "delete_banner",
            module: "banners",
            targetType: "banner",
            targetId: bannerId,
            targetTitle: current.titleEn,
            status: "success",
            reason,
            beforeData: buildAuditBeforeData(current),
            afterData: null,
            metadata: {
              bannerTargetType: current.targetType,
              position: current.position,
              sortOrder: current.sortOrder,
              isActive: current.isActive,
              showOnHome: current.showOnHome,
            },
            eventSource: "server_action",
          }),
        );

        tx.delete(bannerRef);
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

      logger.error("deleteBanner failed", error);
      throw new HttpsError("internal", "Failed to delete banner.");
    }
  },
);
