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
exports.reorderCategoryGroup = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const db = admin.firestore();
function normalizeGroupId(input) {
    const value = String(input ?? "").trim();
    return value.length === 0 ? "root" : value;
}
exports.reorderCategoryGroup = (0, https_1.onCall)(async (request) => {
    const data = request.data ?? {};
    const groupIdRaw = data.groupId;
    const orderedCategoryIdsRaw = data.orderedCategoryIds;
    const groupId = normalizeGroupId(groupIdRaw);
    if (!Array.isArray(orderedCategoryIdsRaw) || orderedCategoryIdsRaw.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "orderedCategoryIds must be a non-empty array.");
    }
    const orderedCategoryIds = orderedCategoryIdsRaw
        .map((item) => String(item ?? "").trim())
        .filter((item) => item.length > 0);
    if (orderedCategoryIds.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "orderedCategoryIds must contain valid ids.");
    }
    const duplicateCheck = new Set();
    for (const id of orderedCategoryIds) {
        if (duplicateCheck.has(id)) {
            throw new https_1.HttpsError("invalid-argument", "orderedCategoryIds contains duplicates.");
        }
        duplicateCheck.add(id);
    }
    await db.runTransaction(async (tx) => {
        const snapshot = await tx.get(db.collection("categories").where("groupId", "==", groupId));
        const existingDocs = snapshot.docs;
        const existingIds = new Set(existingDocs.map((doc) => doc.id));
        const providedIds = new Set(orderedCategoryIds);
        if (existingIds.size !== providedIds.size) {
            throw new https_1.HttpsError("failed-precondition", "Category group changed. Please reload and try again.");
        }
        for (const id of orderedCategoryIds) {
            if (!existingIds.has(id)) {
                throw new https_1.HttpsError("failed-precondition", "Category group changed. Please reload and try again.");
            }
        }
        for (let index = 0; index < orderedCategoryIds.length; index++) {
            const id = orderedCategoryIds[index];
            const ref = db.collection("categories").doc(id);
            tx.update(ref, {
                sortOrder: index,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    });
    return {
        success: true,
        groupId,
        count: orderedCategoryIds.length,
    };
});
