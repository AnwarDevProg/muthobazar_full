"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkPhoneAuthEligibility = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const db = (0, firestore_1.getFirestore)();
function normalizeBangladeshPhone(input) {
    const bengaliToEnglish = {
        "০": "0",
        "১": "1",
        "২": "2",
        "৩": "3",
        "৪": "4",
        "৫": "5",
        "৬": "6",
        "৭": "7",
        "৮": "8",
        "৯": "9",
    };
    let value = (input || "").trim();
    value = value
        .split("")
        .map((ch) => bengaliToEnglish[ch] ?? ch)
        .join("");
    value = value.replace(/[^\d+]/g, "");
    if (value.startsWith("+880")) {
        value = `0${value.slice(4)}`;
    }
    else if (value.startsWith("880")) {
        value = `0${value.slice(3)}`;
    }
    return value;
}
function isValidBangladeshPhone(phone) {
    return /^01[3-9]\d{8}$/.test(phone);
}
function emptyResponse(app, intent, normalizedPhone = "") {
    return {
        ok: false,
        normalizedPhone,
        app,
        intent,
        existsInPhoneIndex: false,
        userExists: false,
        userUid: null,
        userRole: null,
        bootstrapOpen: false,
        superAdminExists: false,
        hasAdminProfile: false,
        hasAdminPermission: false,
        canAccessAdminPanel: false,
        authMode: "blocked",
        allowSendOtp: false,
        showSuperAdminCreation: false,
        code: "INTERNAL_ERROR",
        message: "Unable to process eligibility right now.",
    };
}
exports.checkPhoneAuthEligibility = (0, https_1.onCall)({
    region: "asia-south1",
    cors: true,
}, async (request) => {
    const data = request.data;
    if (!data || typeof data !== "object") {
        throw new https_1.HttpsError("invalid-argument", "Request body is required.");
    }
    const app = data.app;
    const intent = data.intent;
    const normalizedPhone = normalizeBangladeshPhone(data.phoneNumber ?? "");
    if (app !== "customer_app" && app !== "admin_web") {
        return {
            ...emptyResponse("customer_app", "login", normalizedPhone),
            code: "INVALID_APP",
            message: "Invalid app value.",
        };
    }
    if (intent !== "login" && intent !== "register") {
        return {
            ...emptyResponse(app, "login", normalizedPhone),
            app,
            code: "INVALID_INTENT",
            message: "Invalid intent value.",
        };
    }
    if (!isValidBangladeshPhone(normalizedPhone)) {
        return {
            ...emptyResponse(app, intent, normalizedPhone),
            app,
            intent,
            code: "INVALID_PHONE_NUMBER",
            message: "Enter a valid Bangladesh phone number.",
        };
    }
    const base = emptyResponse(app, intent, normalizedPhone);
    base.app = app;
    base.intent = intent;
    base.normalizedPhone = normalizedPhone;
    try {
        const bootstrapRef = db.collection("system").doc("bootstrap");
        const phoneRef = db.collection("phone_index").doc(normalizedPhone);
        const [bootstrapSnap, phoneSnap, superAdminQuerySnap] = await Promise.all([
            bootstrapRef.get(),
            phoneRef.get(),
            db.collection("admin_permissions")
                .where("role", "==", "super_admin")
                .where("isActive", "==", true)
                .limit(1)
                .get(),
        ]);
        const bootstrapData = bootstrapSnap.data() ?? {};
        const bootstrapOpen = bootstrapSnap.exists &&
            bootstrapData.allowFirstSuperAdminSetup === true &&
            bootstrapData.bootstrapCompleted === false;
        const superAdminExists = superAdminQuerySnap.size > 0 ||
            bootstrapData.bootstrapCompleted === true ||
            !!bootstrapData.firstSuperAdminUid;
        const existsInPhoneIndex = phoneSnap.exists;
        const phoneData = phoneSnap.data() ?? {};
        const userUid = existsInPhoneIndex ?
            String(phoneData.Uid ?? "").trim() || null :
            null;
        let userExists = false;
        let userRole = null;
        let hasAdminProfile = false;
        let hasAdminPermission = false;
        let canAccessAdminPanel = false;
        if (userUid) {
            const [userSnap, adminSnap, permissionSnap] = await Promise.all([
                db.collection("users").doc(userUid).get(),
                db.collection("admins").doc(userUid).get(),
                db.collection("admin_permissions").doc(userUid).get(),
            ]);
            userExists = userSnap.exists;
            if (userSnap.exists) {
                const userData = userSnap.data() ?? {};
                const rawRole = String(userData.Role ?? "").trim().toLowerCase();
                if (rawRole === "customer" ||
                    rawRole === "admin" ||
                    rawRole === "super_admin") {
                    userRole = rawRole;
                }
            }
            hasAdminProfile = adminSnap.exists;
            hasAdminPermission = permissionSnap.exists;
            if (permissionSnap.exists) {
                const permissionData = permissionSnap.data() ?? {};
                canAccessAdminPanel =
                    permissionData.isActive === true &&
                        permissionData.canAccessAdminPanel === true;
            }
        }
        const response = {
            ok: true,
            normalizedPhone,
            app,
            intent,
            existsInPhoneIndex,
            userExists,
            userUid,
            userRole,
            bootstrapOpen,
            superAdminExists,
            hasAdminProfile,
            hasAdminPermission,
            canAccessAdminPanel,
            authMode: "blocked",
            allowSendOtp: false,
            showSuperAdminCreation: false,
            code: "INTERNAL_ERROR",
            message: "Unable to determine eligibility.",
        };
        if (app === "customer_app" && intent === "login") {
            if (existsInPhoneIndex) {
                response.authMode = "customer_login";
                response.allowSendOtp = true;
                response.code = "CUSTOMER_LOGIN_ALLOWED";
                response.message = "Phone number is eligible for customer login.";
                return response;
            }
            response.authMode = "blocked";
            response.allowSendOtp = false;
            response.code = "CUSTOMER_LOGIN_NOT_REGISTERED";
            response.message = "This number is not registered yet.";
            return response;
        }
        if (app === "customer_app" && intent === "register") {
            if (!existsInPhoneIndex) {
                response.authMode = "customer_register";
                response.allowSendOtp = true;
                response.code = "CUSTOMER_REGISTER_ALLOWED";
                response.message =
                    "Phone number is eligible for customer registration.";
                return response;
            }
            response.authMode = "blocked";
            response.allowSendOtp = false;
            response.code = "CUSTOMER_REGISTER_ALREADY_EXISTS";
            response.message =
                "This number is already registered. Please login instead.";
            return response;
        }
        if (app === "admin_web" && intent === "login") {
            if (!existsInPhoneIndex) {
                response.authMode = "blocked";
                response.allowSendOtp = false;
                response.showSuperAdminCreation = false;
                response.code = "ADMIN_LOGIN_NOT_REGISTERED";
                response.message = "This phone number is not registered.";
                return response;
            }
            if (userRole === "customer") {
                response.authMode = "blocked";
                response.allowSendOtp = false;
                response.showSuperAdminCreation = false;
                response.code = "ADMIN_LOGIN_CUSTOMER_ONLY_BLOCKED";
                response.message =
                    "This number belongs to a customer account, not an admin account.";
                return response;
            }
            if ((userRole === "admin" || userRole === "super_admin") &&
                canAccessAdminPanel) {
                response.authMode = "admin_login";
                response.allowSendOtp = true;
                response.showSuperAdminCreation = false;
                response.code = "ADMIN_LOGIN_ALLOWED";
                response.message = "Phone number is eligible for admin login.";
                return response;
            }
            response.authMode = "blocked";
            response.allowSendOtp = false;
            response.showSuperAdminCreation = false;
            response.code = "ADMIN_LOGIN_NOT_ASSIGNED";
            response.message =
                "This number is not assigned to any active admin account.";
            return response;
        }
        if (app === "admin_web" && intent === "register") {
            if (existsInPhoneIndex) {
                if (userRole === "admin" || userRole === "super_admin") {
                    response.authMode = "blocked";
                    response.allowSendOtp = false;
                    response.showSuperAdminCreation = false;
                    response.code = "ADMIN_REGISTER_ALREADY_HAS_ADMIN_ACCESS";
                    response.message =
                        "This number is already linked to an admin-side account.";
                    return response;
                }
                response.authMode = "blocked";
                response.allowSendOtp = false;
                response.showSuperAdminCreation = false;
                response.code = "ADMIN_REGISTER_ALREADY_EXISTS";
                response.message =
                    "This number is already registered. Please login instead.";
                return response;
            }
            if (bootstrapOpen && !superAdminExists) {
                response.authMode = "super_admin_bootstrap";
                response.allowSendOtp = true;
                response.showSuperAdminCreation = true;
                response.code = "SUPER_ADMIN_BOOTSTRAP_ALLOWED";
                response.message =
                    "Bootstrap is open. Continue to create the first super admin.";
                return response;
            }
            response.authMode = "admin_register";
            response.allowSendOtp = true;
            response.showSuperAdminCreation = false;
            response.code = "ADMIN_REGISTER_ALLOWED";
            response.message = "Phone number is eligible for admin registration.";
            return response;
        }
        return response;
    }
    catch (error) {
        console.error("checkPhoneAuthEligibility error:", error);
        return {
            ...base,
            code: "INTERNAL_ERROR",
            message: "Internal server error while checking phone eligibility.",
        };
    }
});
