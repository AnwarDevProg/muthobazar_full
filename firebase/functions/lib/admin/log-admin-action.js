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
exports.logAdminAction = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asNullableString(value) {
    const result = typeof value === "string" ? value.trim() : "";
    return result.length === 0 ? null : result;
}
function asPlainObject(value) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
        return value;
    }
    return null;
}
function requireNonEmpty(value, fieldName) {
    if (value.length === 0) {
        throw new functions.https.HttpsError("invalid-argument", `${fieldName} is required.`);
    }
}
function normalizeStatus(value) {
    const normalized = asTrimmedString(value).toLowerCase();
    if (normalized.length === 0) {
        return "success";
    }
    if (normalized === "success" || normalized === "failed") {
        return normalized;
    }
    throw new functions.https.HttpsError("invalid-argument", "status must be either success or failed.");
}
function sanitizePhone(value) {
    return value.replace(/\s+/g, " ").trim();
}
exports.logAdminAction = functions.https.onCall(async (data, context) => {
    try {
        if (!context.auth) {
            throw new functions.https.HttpsError("unauthenticated", "Authentication is required.");
        }
        const authUid = context.auth.uid;
        const db = admin.firestore();
        const actorUid = asTrimmedString(data.actorUid);
        const actorName = asTrimmedString(data.actorName);
        const actorPhone = sanitizePhone(asTrimmedString(data.actorPhone));
        const actorRoleFromClient = asTrimmedString(data.actorRole).toLowerCase();
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
            throw new functions.https.HttpsError("permission-denied", "actorUid must match the authenticated user.");
        }
        const permissionSnap = await db
            .collection("admin_permissions")
            .doc(authUid)
            .get();
        if (!permissionSnap.exists) {
            throw new functions.https.HttpsError("permission-denied", "Admin permission record was not found.");
        }
        const permissionData = permissionSnap.data() ?? {};
        const roleFromDb = asTrimmedString(permissionData.role).toLowerCase();
        const canAccessAdminPanel = permissionData.canAccessAdminPanel === true;
        const isAllowedAdmin = canAccessAdminPanel ||
            roleFromDb === "admin" ||
            roleFromDb === "super_admin";
        if (!isAllowedAdmin) {
            throw new functions.https.HttpsError("permission-denied", "User is not allowed to write admin activity logs.");
        }
        const actorRole = actorRoleFromClient.length > 0 ? actorRoleFromClient : roleFromDb;
        requireNonEmpty(actorRole, "actorRole");
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
    }
    catch (error) {
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        functions.logger.error("logAdminAction failed", error);
        throw new functions.https.HttpsError("internal", "Failed to write admin activity log.");
    }
});
// Deploy commands
// Run from repo root:
// cd firebase/functions
// npm run build
// firebase deploy --only functions:logAdminAction
// Optional logs check:
// firebase functions:log --only logAdminAction
