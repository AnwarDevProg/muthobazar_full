import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

type ActivityLogPayload = {
  actorUid?: string;
  actorName?: string;
  actorPhone?: string;
  actorRole?: string;
  action?: string;
  module?: string;
  targetType?: string;
  targetId?: string;
  targetTitle?: string;
  status?: string;
  reason?: string | null;
  beforeData?: Record<string, unknown> | null;
  afterData?: Record<string, unknown> | null;
  metadata?: Record<string, unknown> | null;
};

type PlainObject = Record<string, unknown>;

type LogAdminActionResponse = {
  success: true;
  id: string;
};

const db = admin.firestore();

function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function asNullableString(value: unknown): string | null {
  const result = asTrimmedString(value);
  return result.length === 0 ? null : result;
}

function asPlainObject(value: unknown): PlainObject | null {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as PlainObject;
  }
  return null;
}

function requireNonEmpty(value: string, fieldName: string): void {
  if (value.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} is required.`,
    );
  }
}

function normalizeStatus(value: unknown): "success" | "failed" {
  const normalized = asTrimmedString(value).toLowerCase();

  if (normalized.length === 0) {
    return "success";
  }

  if (normalized === "success" || normalized === "failed") {
    return normalized;
  }

  throw new HttpsError(
    "invalid-argument",
    "status must be either success or failed.",
  );
}

function sanitizePhone(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

export const logAdminAction = onCall<ActivityLogPayload>(
  async (request): Promise<LogAdminActionResponse> => {
    try {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Authentication is required.",
        );
      }

      const authUid = request.auth.uid;
      const data = request.data ?? {};

      const actorUid = asTrimmedString(data.actorUid);
      const actorName = asTrimmedString(data.actorName);
      const actorPhone = sanitizePhone(asTrimmedString(data.actorPhone));

      const action = asTrimmedString(data.action);
      const module = asTrimmedString(data.module);
      const targetType = asTrimmedString(data.targetType);
      const targetId = asTrimmedString(data.targetId);
      const targetTitle = asTrimmedString(data.targetTitle);
      const status = normalizeStatus(data.status);
      const reason = asNullableString(data.reason);

      const beforeData = asPlainObject(data.beforeData);
      const afterData = asPlainObject(data.afterData);
      const metadata = asPlainObject(data.metadata);

      requireNonEmpty(actorUid, "actorUid");
      requireNonEmpty(actorName, "actorName");
      requireNonEmpty(action, "action");
      requireNonEmpty(module, "module");
      requireNonEmpty(targetType, "targetType");
      requireNonEmpty(targetId, "targetId");
      requireNonEmpty(targetTitle, "targetTitle");

      if (actorUid !== authUid) {
        throw new HttpsError(
          "permission-denied",
          "actorUid must match the authenticated user.",
        );
      }

      const permissionSnap = await db
        .collection("admin_permissions")
        .doc(authUid)
        .get();

      if (!permissionSnap.exists) {
        throw new HttpsError(
          "permission-denied",
          "Admin permission record was not found.",
        );
      }

      const permissionData = permissionSnap.data() ?? {};
      const roleFromDb = asTrimmedString(permissionData.role).toLowerCase();
      const isActive = permissionData.isActive === true;
      const canAccessAdminPanel =
        permissionData.canAccessAdminPanel === true;

      const isAllowedRole =
        roleFromDb === "admin" || roleFromDb === "super_admin";

      if (!isActive || !canAccessAdminPanel || !isAllowedRole) {
        throw new HttpsError(
          "permission-denied",
          "User is not allowed to write admin activity logs.",
        );
      }

      const actorRole = roleFromDb;

      const logRef = db.collection("admin_activity_logs").doc();

      await logRef.set({
        id: logRef.id,
        actorUid,
        actorName,
        actorPhone,
        actorRole,
        action,
        module,
        targetType,
        targetId,
        targetTitle,
        status,
        reason,
        beforeData,
        afterData,
        metadata,
        authUid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        id: logRef.id,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("logAdminAction failed", error);

      throw new HttpsError(
        "internal",
        "Failed to write admin activity log.",
      );
    }
  },
);