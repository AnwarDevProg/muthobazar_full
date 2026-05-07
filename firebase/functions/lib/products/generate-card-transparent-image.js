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
exports.generateProductCardTransparentImage = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const audit_log_core_1 = require("../admin/audit-log-core");
const callable_parsers_1 = require("../utils/callable-parsers");
const maxInputBytes = 5 * 1024 * 1024;
const maxOutputBase64Length = 12 * 1024 * 1024;
function normalizeMimeType(value) {
    const mimeType = (0, callable_parsers_1.asTrimmedString)(value).toLowerCase();
    if (mimeType === "image/jpeg" ||
        mimeType === "image/jpg" ||
        mimeType === "image/png" ||
        mimeType === "image/webp") {
        return mimeType === "image/jpg" ? "image/jpeg" : mimeType;
    }
    throw new https_1.HttpsError("invalid-argument", "mimeType must be image/jpeg, image/png, or image/webp.");
}
function decodeInputImageBase64(value) {
    const raw = (0, callable_parsers_1.asTrimmedString)(value);
    if (raw.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "imageBase64 is required.");
    }
    const normalized = raw.includes(",") ? raw.split(",").pop() ?? "" : raw;
    const buffer = Buffer.from(normalized, "base64");
    if (buffer.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "imageBase64 could not be decoded.");
    }
    if (buffer.length > maxInputBytes) {
        throw new https_1.HttpsError("invalid-argument", `Image is too large. Maximum input size is ${maxInputBytes} bytes.`);
    }
    return buffer;
}
function resolveServiceUrl() {
    const endpoint = (0, callable_parsers_1.asTrimmedString)(process.env.MUTHOBAZAR_BG_REMOVER_URL);
    if (endpoint.length === 0) {
        throw new https_1.HttpsError("failed-precondition", "MUTHOBAZAR_BG_REMOVER_URL is not configured for the background remover service.");
    }
    return endpoint;
}
function buildServiceHeaders() {
    const headers = {
        "Content-Type": "application/json",
    };
    const token = (0, callable_parsers_1.asTrimmedString)(process.env.MUTHOBAZAR_BG_REMOVER_TOKEN);
    if (token.length > 0) {
        headers.Authorization = `Bearer ${token}`;
    }
    return headers;
}
function parseServiceJson(value) {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new https_1.HttpsError("internal", "Background remover returned an invalid response.");
    }
    return value;
}
function asPositiveNumberOrNull(value) {
    if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
        return null;
    }
    return Math.round(value);
}
exports.generateProductCardTransparentImage = (0, https_1.onCall)({
    timeoutSeconds: 120,
    memory: "512MiB",
}, async (request) => {
    const actor = await (0, audit_log_core_1.getAuthorizedAdminActor)(request.auth?.uid, "canManageProducts");
    const payload = (0, callable_parsers_1.requireObjectRecord)(request.data, "request");
    const mimeType = normalizeMimeType(payload.mimeType);
    const originalFileName = (0, callable_parsers_1.asTrimmedString)(payload.originalFileName) || "product-image";
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
        let parsed;
        try {
            parsed = responseText.length > 0 ? JSON.parse(responseText) : {};
        }
        catch (_) {
            throw new https_1.HttpsError("internal", "Background remover response was not valid JSON.");
        }
        const body = parseServiceJson(parsed);
        if (!response.ok || body.success === false) {
            throw new https_1.HttpsError("internal", (0, callable_parsers_1.asTrimmedString)(body.message) ||
                `Background remover failed with status ${response.status}.`);
        }
        const outputBase64 = (0, callable_parsers_1.asTrimmedString)(body.imageBase64);
        if (outputBase64.length === 0) {
            throw new https_1.HttpsError("internal", "Background remover did not return imageBase64.");
        }
        if (outputBase64.length > maxOutputBase64Length) {
            throw new https_1.HttpsError("internal", "Background remover output is too large.");
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
            mimeType: (0, callable_parsers_1.asTrimmedString)(body.mimeType) || "image/png",
            width: asPositiveNumberOrNull(body.width),
            height: asPositiveNumberOrNull(body.height),
            sizeBytes: asPositiveNumberOrNull(body.sizeBytes),
        };
    }
    catch (error) {
        if (error instanceof https_1.HttpsError) {
            throw error;
        }
        logger.error("Failed to generate transparent product-card image", {
            actorUid: actor.uid,
            error,
        });
        throw new https_1.HttpsError("internal", "Failed to generate transparent product-card image.");
    }
});
