"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAuthorizedAdminActor = getAuthorizedAdminActor;
exports.buildAdminAuditLogDoc = buildAdminAuditLogDoc;
exports.newAdminAuditLogRef = newAdminAuditLogRef;
exports.writeAdminAuditLog = writeAdminAuditLog;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const db = admin.firestore();
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asNullableTrimmedString(value) {
    const normalized = asTrimmedString(value);
    return normalized.length === 0 ? null : normalized;
}
function asPlainObject(value) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
        return value;
    }
    return null;
}
function requireNonEmpty(value, fieldName) {
    if (value.length === 0) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} is required.`);
    }
}
function resolveActorName(userData, adminData, uid) {
    const adminSideName = asTrimmedString(adminData?.name) ||
        asTrimmedString(adminData?.fullName) ||
        asTrimmedString(adminData?.displayName);
    if (adminSideName.length > 0) {
        return adminSideName;
    }
    const firstName = asTrimmedString(userData?.FirstName);
    const lastName = asTrimmedString(userData?.LastName);
    const fullName = `${firstName} ${lastName}`.trim();
    if (fullName.length > 0) {
        return fullName;
    }
    return uid;
}
function resolveActorPhone(userData, adminData) {
    return (asTrimmedString(userData?.PhoneNumber) ||
        asTrimmedString(adminData?.PhoneNumber) ||
        asTrimmedString(adminData?.phone));
}
function validateAdminPermissionDoc(permissionData, requiredPermission) {
    const role = asTrimmedString(permissionData.role).toLowerCase();
    const isActive = permissionData.isActive === true;
    const canAccessAdminPanel = permissionData.canAccessAdminPanel === true;
    if (!isActive || !canAccessAdminPanel) {
        throw new https_1.HttpsError("permission-denied", "User is not an active admin panel user.");
    }
    if (role !== "admin" && role !== "super_admin") {
        throw new https_1.HttpsError("permission-denied", "User is not allowed to perform admin actions.");
    }
    if (requiredPermission &&
        role !== "super_admin" &&
        permissionData[requiredPermission] !== true) {
        throw new https_1.HttpsError("permission-denied", `Missing required permission: ${requiredPermission}.`);
    }
    return role;
}
async function getAuthorizedAdminActor(authUid, requiredPermission) {
    const uid = asTrimmedString(authUid);
    if (uid.length === 0) {
        throw new https_1.HttpsError("unauthenticated", "Authentication is required.");
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
        throw new https_1.HttpsError("permission-denied", "Admin permission record was not found.");
    }
    const permissionData = (permissionSnap.data() ?? {});
    const role = validateAdminPermissionDoc(permissionData, requiredPermission);
    const userData = userSnap.exists
        ? (userSnap.data() ?? {})
        : null;
    const adminData = adminSnap.exists
        ? (adminSnap.data() ?? {})
        : null;
    return {
        uid,
        name: resolveActorName(userData, adminData, uid),
        phone: resolveActorPhone(userData, adminData),
        role,
    };
}
function buildAdminAuditLogDoc(logId, actor, input) {
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
function newAdminAuditLogRef() {
    return db.collection("admin_activity_logs").doc();
}
async function writeAdminAuditLog(actor, input) {
    const logRef = newAdminAuditLogRef();
    await logRef.set(buildAdminAuditLogDoc(logRef.id, actor, input));
    return logRef.id;
}
