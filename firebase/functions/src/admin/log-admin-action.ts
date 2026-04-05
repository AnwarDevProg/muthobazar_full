import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

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

function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function asNullableString(value: unknown): string | null {
  const result = typeof value === "string" ? value.trim() : "";
  return result.isEmpty ? null : result;
}

function asPlainObject(
  value: unknown
): Record<string, unknown> | null {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return null;
}

export const logAdminAction = functions.https.onCall(
  async (data: ActivityLogPayload, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication is required."
      );
    }

    const authUid = context.auth.uid;

    const actorUid = asTrimmedString(data.actorUid);
    const actorName = asTrimmedString(data.actorName);
    const actorPhone = asTrimmedString(data.actorPhone);
    const actorRole = asTrimmedString(data.actorRole);

    const action = asTrimmedString(data.action);
    const module = asTrimmedString(data.module);
    const targetType = asTrimmedString(data.targetType);
    const targetId = asTrimmedString(data.targetId);
    const targetTitle = asTrimmedString(data.targetTitle);
    const status = asTrimmedString(data.status) || "success";
    const reason = asNullableString(data.reason);

    const beforeData = asPlainObject(data.beforeData);
    const afterData = asPlainObject(data.afterData);
    const metadata = asPlainObject(data.metadata);

    if (actorUid.isEmpty || actorUid != authUid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "actorUid must match the authenticated user."
      );
    }

    if (actorName.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "actorName is required."
      );
    }

    if (actorRole.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "actorRole is required."
      );
    }

    if (action.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "action is required."
      );
    }

    if (module.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "module is required."
      );
    }

    if (targetType.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetType is required."
      );
    }

    if (targetId.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetId is required."
      );
    }

    if (targetTitle.isEmpty) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetTitle is required."
      );
    }

    if (status !== "success" && status !== "failed") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "status must be either success or failed."
      );
    }

    const db = admin.firestore();
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
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      id: logRef.id,
    };
  }
);