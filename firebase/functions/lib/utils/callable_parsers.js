"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.asTrimmedString = asTrimmedString;
exports.asBool = asBool;
exports.asBoolOrThrow = asBoolOrThrow;
exports.asInt = asInt;
exports.requireNonEmpty = requireNonEmpty;
exports.slugify = slugify;
exports.normalizeNullableId = normalizeNullableId;
exports.groupIdFromParentId = groupIdFromParentId;
exports.requireNonNegativeInt = requireNonNegativeInt;
exports.requireObjectRecord = requireObjectRecord;
const https_1 = require("firebase-functions/v2/https");
// Shared callable request parsing and normalization helpers.
// Category and brand functions can both reuse these helpers.
function asTrimmedString(value) {
    return typeof value === "string" ? value.trim() : "";
}
function asBool(value, defaultValue = false) {
    if (typeof value === "boolean")
        return value;
    if (typeof value === "string") {
        const normalized = value.trim().toLowerCase();
        if (normalized === "true")
            return true;
        if (normalized === "false")
            return false;
    }
    return defaultValue;
}
function asBoolOrThrow(value, fieldName) {
    if (typeof value === "boolean") {
        return value;
    }
    throw new https_1.HttpsError("invalid-argument", `${fieldName} must be a boolean.`);
}
function asInt(value, defaultValue = 0) {
    if (typeof value === "number" && Number.isFinite(value)) {
        return Math.trunc(value);
    }
    const parsed = Number.parseInt(String(value ?? "").trim(), 10);
    return Number.isNaN(parsed) ? defaultValue : parsed;
}
function requireNonEmpty(value, fieldName) {
    if (value.length === 0) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} is required.`);
    }
}
function slugify(value) {
    return value
        .toLowerCase()
        .trim()
        .replace(/&/g, " and ")
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .replace(/-{2,}/g, "-");
}
function normalizeNullableId(value) {
    const normalized = asTrimmedString(value);
    return normalized.length === 0 ? null : normalized;
}
function groupIdFromParentId(parentId) {
    return parentId == null || parentId.length === 0 ? "root" : parentId;
}
function requireNonNegativeInt(value, fieldName) {
    if (value < 0) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} must be 0 or greater.`);
    }
}
function requireObjectRecord(input, fieldName) {
    if (!input || typeof input !== "object" || Array.isArray(input)) {
        throw new https_1.HttpsError("invalid-argument", `${fieldName} payload is required.`);
    }
    return input;
}
