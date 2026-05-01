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

type SetBannerActiveStateRequest = {
  bannerId?: string;
  isActive?: boolean;
  reason?: string | null;
};

type SetBannerActiveStateResponse = {
  success: true;
  bannerId: string;
  isActive: boolean;
  auditLogId: string;
};

type BannerState = {
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

function parseBannerState(
  doc: admin.firestore.DocumentSnapshot | admin.firestore.QueryDocumentSnapshot,
): BannerState {
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

function buildAuditState(banner: BannerState): Record<string, unknown> {
  return {
    id: banner.id,
    titleEn: banner.titleEn,
    titleBn: banner.titleBn,
    subtitleEn: banner.subtitleEn,
    subtitleBn: banner.subtitleBn,
    buttonTextEn: banner.buttonTextEn,
    buttonTextBn: banner.buttonTextBn,
    imageUrl: banner.imageUrl,
    mobileImageUrl: banner.mobileImageUrl,
    targetType: banner.targetType,
    targetId: banner.targetId,
    targetRoute: banner.targetRoute,
    externalUrl: banner.externalUrl,
    isActive: banner.isActive,
    showOnHome: banner.showOnHome,
    position: banner.position,
    sortOrder: banner.sortOrder,
    startAt: banner.startAt,
    endAt: banner.endAt,
    createdAt: banner.createdAt ?? null,
    updatedAt: banner.updatedAt ?? null,
  };
}

export const setBannerActiveState = onCall<SetBannerActiveStateRequest>(
  {
    region: "asia-south1",
  },
  async (request): Promise<SetBannerActiveStateResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(
        request.auth?.uid,
        "canManageBanners",
      );

      const bannerId = asTrimmedString(request.data?.bannerId);
      const nextIsActive = asBoolOrThrow(request.data?.isActive, "isActive");
      const reason = normalizeNullableId(request.data?.reason);
      requireNonEmpty(bannerId, "bannerId");

      let auditLogId = "";

      await db.runTransaction(async (tx) => {
        const bannerRef = db.collection("banners").doc(bannerId);
        const existingSnap = await tx.get(bannerRef);
        if (!existingSnap.exists) {
          throw new HttpsError("not-found", "Banner not found.");
        }

        const existing = parseBannerState(existingSnap);
        if (existing.isActive === nextIsActive) {
          throw new HttpsError(
            "failed-precondition",
            `Banner is already ${nextIsActive ? "active" : "inactive"}.`,
          );
        }

        const afterState: BannerState = {
          ...existing,
          isActive: nextIsActive,
        };

        tx.set(
          bannerRef,
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
            action: nextIsActive ? "activate_banner" : "deactivate_banner",
            module: "banners",
            targetType: "banner",
            targetId: bannerId,
            targetTitle: existing.titleEn,
            status: "success",
            reason,
            beforeData: buildAuditState(existing),
            afterData: buildAuditState(afterState),
            metadata: {
              changedFields: ["isActive"],
              position: existing.position,
              sortOrder: existing.sortOrder,
              showOnHome: existing.showOnHome,
            },
            eventSource: "server_action",
          }),
        );
      });

      return {
        success: true,
        bannerId,
        isActive: nextIsActive,
        auditLogId,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("setBannerActiveState failed", error);
      throw new HttpsError(
        "internal",
        "Failed to change banner active state.",
      );
    }
  },
);
