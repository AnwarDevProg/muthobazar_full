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
exports.fixCategoryGroupSort = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const db = admin.firestore();
function normalizeGroupId(input) {
    const value = String(input ?? "").trim();
    return value.length === 0 ? "root" : value;
}
exports.fixCategoryGroupSort = (0, https_1.onCall)(async (request) => {
    const data = request.data ?? {};
    const groupId = normalizeGroupId(data.groupId);
    await db.runTransaction(async (tx) => {
        const snapshot = await tx.get(db.collection("categories").where("groupId", "==", groupId));
        const ordered = snapshot.docs
            .map((doc) => ({
            id: doc.id,
            sortOrder: Number(doc.data().sortOrder ?? 0),
            nameEn: String(doc.data().nameEn ?? "").toLowerCase(),
        }))
            .sort((a, b) => {
            const bySort = a.sortOrder - b.sortOrder;
            if (bySort !== 0)
                return bySort;
            return a.nameEn.localeCompare(b.nameEn);
        });
        for (let i = 0; i < ordered.length; i++) {
            tx.update(db.collection("categories").doc(ordered[i].id), {
                sortOrder: i,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    });
    return {
        success: true,
        groupId,
    };
});
