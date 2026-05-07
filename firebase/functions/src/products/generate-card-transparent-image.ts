import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { getAuthorizedAdminActor } from "../admin/audit-log-core";
import {
  asTrimmedString,
  requireObjectRecord,
} from "../utils/callable-parsers";

type JsonMap = Record<string, unknown>;

type BgRemoveServiceResponse = {
  success?: boolean;
  imageBase64?: string;
  mimeType?: string;
  width?: number;
  height?: number;
  sizeBytes?: number;
  message?: string;
};

const maxInputBytes = 5 * 1024 * 1024;
const maxOutputBase64Length = 12 * 1024 * 1024;

function normalizeMimeType(value: unknown): string {
  const mimeType = asTrimmedString(value).toLowerCase();

  if (
    mimeType === "image/jpeg" ||
    mimeType === "image/jpg" ||
    mimeType === "image/png" ||
    mimeType === "image/webp"
  ) {
    return mimeType === "image/jpg" ? "image/jpeg" : mimeType;
  }

  throw new HttpsError(
    "invalid-argument",
    "mimeType must be image/jpeg, image/png, or image/webp.",
  );
}

function decodeInputImageBase64(value: unknown): Buffer {
  const raw = asTrimmedString(value);
  if (raw.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "imageBase64 is required.",
    );
  }

  const normalized = raw.includes(",") ? raw.split(",").pop() ?? "" : raw;
  const buffer = Buffer.from(normalized, "base64");

  if (buffer.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "imageBase64 could not be decoded.",
    );
  }

  if (buffer.length > maxInputBytes) {
    throw new HttpsError(
      "invalid-argument",
      `Image is too large. Maximum input size is ${maxInputBytes} bytes.`,
    );
  }

  return buffer;
}

function resolveServiceUrl(): string {
  const endpoint = asTrimmedString(process.env.MUTHOBAZAR_BG_REMOVER_URL);
  if (endpoint.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "MUTHOBAZAR_BG_REMOVER_URL is not configured for the background remover service.",
    );
  }
  return endpoint;
}

function buildServiceHeaders(): Record<string, string> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  const token = asTrimmedString(process.env.MUTHOBAZAR_BG_REMOVER_TOKEN);
  if (token.length > 0) {
    headers.Authorization = `Bearer ${token}`;
  }

  return headers;
}

function parseServiceJson(value: unknown): BgRemoveServiceResponse {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError(
      "internal",
      "Background remover returned an invalid response.",
    );
  }

  return value as BgRemoveServiceResponse;
}

function asPositiveNumberOrNull(value: unknown): number | null {
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    return null;
  }
  return Math.round(value);
}

export const generateProductCardTransparentImage = onCall(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request): Promise<JsonMap> => {
    const actor = await getAuthorizedAdminActor(
      request.auth?.uid,
      "canManageProducts",
    );

    const payload = requireObjectRecord(request.data, "request");
    const mimeType = normalizeMimeType(payload.mimeType);
    const originalFileName =
      asTrimmedString(payload.originalFileName) || "product-image";
    const inputBuffer = decodeInputImageBase64(payload.imageBase64);
    const serviceUrl = resolveServiceUrl();

    try {
      const response = await fetch(serviceUrl, {
        method: "POST",
        headers: buildServiceHeaders(),
        body: JSON.stringify({
          imageBase64: inputBuffer.toString("base64"),
          mimeType,
          originalFileName,
          outputFormat: "png",
          owner: "muthobazar_admin_web",
          requestedByUid: actor.uid,
        }),
      });

      const responseText = await response.text();
      let parsed: unknown;
      try {
        parsed = responseText.length > 0 ? JSON.parse(responseText) : {};
      } catch (_) {
        throw new HttpsError(
          "internal",
          "Background remover response was not valid JSON.",
        );
      }

      const body = parseServiceJson(parsed);
      if (!response.ok || body.success === false) {
        throw new HttpsError(
          "internal",
          asTrimmedString(body.message) ||
            `Background remover failed with status ${response.status}.`,
        );
      }

      const outputBase64 = asTrimmedString(body.imageBase64);
      if (outputBase64.length === 0) {
        throw new HttpsError(
          "internal",
          "Background remover did not return imageBase64.",
        );
      }

      if (outputBase64.length > maxOutputBase64Length) {
        throw new HttpsError(
          "internal",
          "Background remover output is too large.",
        );
      }

      logger.info("Generated transparent product-card image", {
        actorUid: actor.uid,
        inputBytes: inputBuffer.length,
        outputBase64Length: outputBase64.length,
        originalFileName,
      });

      return {
        success: true,
        imageBase64: outputBase64,
        mimeType: asTrimmedString(body.mimeType) || "image/png",
        width: asPositiveNumberOrNull(body.width),
        height: asPositiveNumberOrNull(body.height),
        sizeBytes: asPositiveNumberOrNull(body.sizeBytes),
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error("Failed to generate transparent product-card image", {
        actorUid: actor.uid,
        error,
      });

      throw new HttpsError(
        "internal",
        "Failed to generate transparent product-card image.",
      );
    }
  },
);
