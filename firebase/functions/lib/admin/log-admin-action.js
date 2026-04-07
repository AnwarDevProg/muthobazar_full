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
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("./audit-log-core");
const SERVER_ONLY_AUDIT_MODULES = new Set([
    "categories",
    "brands",
    "banners",
    "products",
]);
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asNullableString(value) {
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
function normalizeStatus(value) {
    const normalized = asTrimmedString(value).toLowerCase();
    if (normalized.length === 0) {
        return "success";
    }
    if (normalized === "success" || normalized === "failed") {
        return normalized;
    }
    throw new https_1.HttpsError("invalid-argument", "status must be either success or failed.");
}
exports.logAdminAction = (0, https_1.onCall)(async (request) => {
    try {
        const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid);
        const data = request.data ?? {};
        const action = asTrimmedString(data.action);
        const module = asTrimmedString(data.module).toLowerCase();
        const targetType = asTrimmedString(data.targetType);
        const targetId = asTrimmedString(data.targetId);
        const targetTitle = asTrimmedString(data.targetTitle);
        requireNonEmpty(action, "action");
        requireNonEmpty(module, "module");
        requireNonEmpty(targetType, "targetType");
        requireNonEmpty(targetId, "targetId");
        requireNonEmpty(targetTitle, "targetTitle");
        if (SERVER_ONLY_AUDIT_MODULES.has(module)) {
            throw new https_1.HttpsError("failed-precondition", "This module must be audited by its own server-side action.");
        }
        const id = await (0, audit_log_core_1.writeAdminAuditLog)(actor, {
            action,
            module,
            targetType,
            targetId,
            targetTitle,
            status: normalizeStatus(data.status),
            reason: asNullableString(data.reason),
            metadata: asPlainObject(data.metadata),
            eventSource: "manual_endpoint",
        });
        return {
            success: true,
            id,
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("logAdminAction failed", error);
        throw new https_1.HttpsError("internal", "Failed to write admin activity log.");
    }
});
