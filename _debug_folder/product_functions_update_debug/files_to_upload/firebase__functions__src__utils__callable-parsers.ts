import { HttpsError } from "firebase-functions/v2/https";

// Shared callable request parsing and normalization helpers.
// Category and brand functions can both reuse these helpers.

export function asTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function asBool(value: unknown, defaultValue = false): boolean {
  if (typeof value === "boolean") return value;

  if (typeof value === "string") {
    const normalized = value.trim().toLowerCase();
    if (normalized === "true") return true;
    if (normalized === "false") return false;
  }

  return defaultValue;
}

export function asBoolOrThrow(value: unknown, fieldName: string): boolean {
  if (typeof value === "boolean") {
    return value;
  }

  throw new HttpsError(
    "invalid-argument",
    `${fieldName} must be a boolean.`,
  );
}

export function asInt(value: unknown, defaultValue = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }

  const parsed = Number.parseInt(String(value ?? "").trim(), 10);
  return Number.isNaN(parsed) ? defaultValue : parsed;
}

export function requireNonEmpty(value: string, fieldName: string): void {
  if (value.length === 0) {
    throw new HttpsError("invalid-argument", `${fieldName} is required.`);
  }
}

export function slugify(value: string): string {
  return value
    .toLowerCase()
    .trim()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");
}

export function normalizeNullableId(value: unknown): string | null {
  const normalized = asTrimmedString(value);
  return normalized.length === 0 ? null : normalized;
}

export function groupIdFromParentId(parentId: string | null): string {
  return parentId == null || parentId.length === 0 ? "root" : parentId;
}

export function requireNonNegativeInt(value: number, fieldName: string): void {
  if (value < 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} must be 0 or greater.`,
    );
  }
}

export function requireObjectRecord(
  input: unknown,
  fieldName: string,
): Record<string, unknown> {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} payload is required.`,
    );
  }

  return input as Record<string, unknown>;
}
