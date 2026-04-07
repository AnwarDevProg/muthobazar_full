import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/v2/https";

const db = admin.firestore();

type PlainObject = Record<string, unknown>;

export type AdminAuditPermission =
  | "canManageUsers"
  | "canManageCategories"
  | "canManageBrands"
  | "canManageProducts"
  | "canManageBanners"
  | "canManageCoupons"
  | "canManageOffers"
  | "canManageAdmins"
  | "canManageAdminInvites"
  | "canManageAdminPermissions"
  | "canDeleteProducts"
  | "canRestoreProducts"
  | "canViewActivityLogs";

export type AdminActorRole = "admin" | "super_admin";

export type AdminAuditActor = {
  uid: string;
  name: string;
  phone: string;
  role: AdminActorRole;
};

export type AdminAuditInput = {
  action: string;
  module: string;
  targetType: string;
  targetId: string;
  targetTitle: string;
  status?: "success" | "failed";
  reason?: string | null;
  beforeData?: PlainObject | null;
  afterData?: PlainObject | null;
  metadata?: PlainObject | null;
  eventSource?: "server_action" | "manual_endpoint";
};

function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function asNullableTrimmedString(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length === 0 ? null : normalized;
}

function asPlainObject(value: unknown): PlainObject | null {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as PlainObject;
  }
  return null;
}

function requireNonEmpty(value: string, fieldName: string): void {
  if (value.length === 0) {
    throw new HttpsError("invalid-argument", `${fieldName} is required.`);
  }
}

function resolveActorName(
  userData: PlainObject | null,
  adminData: PlainObject | null,
  uid: string,
): string {
  const adminName =
    asTrimmedString(adminData?.name) ||
    asTrimmedString(adminData?.fullName) ||
    asTrimmedString(adminData?.displayName);

  if (adminName.length > 0) {
    return adminName;
  }

  const firstName = asTrimmedString(userData?.FirstName);
  const lastName = asTrimmedString(userData?.LastName);
  const combined = `${firstName} ${lastName}`.trim();

  if (combined.length > 0) {
    return combined;
  }

  return uid;
}

function resolveActorPhone(
  userData: PlainObject | null,
  adminData: PlainObject | null,
): string {
  return (
    asTrimmedString(userData?.PhoneNumber) ||
    asTrimmedString(adminData?.PhoneNumber) ||
    asTrimmedString(adminData?.phone)
  );
}

function validateAdminPermissionDoc(
  permissionData: PlainObject,
  requiredPermission?: AdminAuditPermission,
): AdminActorRole {
  const role = asTrimmedString(permissionData.role).toLowerCase();
  const isActive = permissionData.isActive === true;
  const canAccessAdminPanel = permissionData.canAccessAdminPanel === true;

  if (!isActive || !canAccessAdminPanel) {
    throw new HttpsError(
      "permission-denied",
      "User is not an active admin panel user.",
    );
  }

  if (role !== "admin" && role !== "super_admin") {
    throw new HttpsError(
      "permission-denied",
      "User is not allowed to perform admin actions.",
    );
  }

  if (
    requiredPermission &&
    role !== "super_admin" &&
    permissionData[requiredPermission] !== true
  ) {
    throw new HttpsError(
      "permission-denied",
      `Missing required permission: ${requiredPermission}.`,
    );
  }

  return role as AdminActorRole;
}

export async function getAuthorizedAdminActor(
  authUid: string | null | undefined,
  requiredPermission?: AdminAuditPermission,
): Promise<AdminAuditActor> {
  const uid = asTrimmedString(authUid);

  if (uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  const permissionRef = db.collection("admin_permissions").doc(uid);
  const userRef = db.collection("users").doc(uid);
  const adminRef = db.collection("admins").doc(uid);

  const [permissionSnap, userSnap, adminSnap] = await Promise.all([
    permissionRef.get(),
    userRef.get(),
    adminRef.get(),
  ]);

  if (!permissionSnap.exists) {
    throw new HttpsError(
      "permission-denied",
      "Admin permission record was not found.",
    );
  }

  const permissionData = (permissionSnap.data() ?? {}) as PlainObject;
  const role = validateAdminPermissionDoc(permissionData, requiredPermission);

  const userData = userSnap.exists
    ? ((userSnap.data() ?? {}) as PlainObject)
    : null;

  const adminData = adminSnap.exists
    ? ((adminSnap.data() ?? {}) as PlainObject)
    : null;

  return {
    uid,
    name: resolveActorName(userData, adminData, uid),
    phone: resolveActorPhone(userData, adminData),
    role,
  };
}

export function buildAdminAuditLogDoc(
  logId: string,
  actor: AdminAuditActor,
  input: AdminAuditInput,
): admin.firestore.DocumentData {
  const action = asTrimmedString(input.action);
  const module = asTrimmedString(input.module);
  const targetType = asTrimmedString(input.targetType);
  const targetId = asTrimmedString(input.targetId);
  const targetTitle = asTrimmedString(input.targetTitle);

  requireNonEmpty(action, "action");
  requireNonEmpty(module, "module");
  requireNonEmpty(targetType, "targetType");
  requireNonEmpty(targetId, "targetId");
  requireNonEmpty(targetTitle, "targetTitle");

  return {
    id: logId,
    actorUid: actor.uid,
    actorName: actor.name,
    actorPhone: actor.phone,
    actorRole: actor.role,
    action,
    module,
    targetType,
    targetId,
    targetTitle,
    status: input.status === "failed" ? "failed" : "success",
    reason: asNullableTrimmedString(input.reason),
    beforeData: asPlainObject(input.beforeData),
    afterData: asPlainObject(input.afterData),
    metadata: asPlainObject(input.metadata),
    eventSource: input.eventSource ?? "server_action",
    app: "admin_web",
    authUid: actor.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

export function newAdminAuditLogRef(): admin.firestore.DocumentReference {
  return db.collection("admin_activity_logs").doc();
}

export async function writeAdminAuditLog(
  actor: AdminAuditActor,
  input: AdminAuditInput,
): Promise<string> {
  const logRef = newAdminAuditLogRef();
  await logRef.set(buildAdminAuditLogDoc(logRef.id, actor, input));
  return logRef.id;
}