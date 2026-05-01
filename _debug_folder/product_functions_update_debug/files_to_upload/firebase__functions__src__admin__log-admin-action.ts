import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {
  getAuthorizedAdminActor,
  writeAdminAuditLog,
} from "./audit-log-core";

type PlainObject = Record<string, unknown>;

type ManualAdminLogPayload = {
  action?: string;
  module?: string;
  targetType?: string;
  targetId?: string;
  targetTitle?: string;
  status?: string;
  reason?: string | null;
  metadata?: PlainObject | null;
};

type LogAdminActionResponse = {
  success: true;
  id: string;
};

const SERVER_ONLY_AUDIT_MODULES = new Set<string>([
  "categories",
  "brands",
  "banners",
  "products",
]);

function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function asNullableString(value: unknown): string | null {
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

export const logAdminAction = onCall<ManualAdminLogPayload>(
  async (request): Promise<LogAdminActionResponse> => {
    try {
      const actor = await getAuthorizedAdminActor(request.auth?.uid);

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
        throw new HttpsError(
          "failed-precondition",
          "This module must be audited by its own server-side action.",
        );
      }

      const id = await writeAdminAuditLog(actor, {
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
