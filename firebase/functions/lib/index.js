"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logAdminAction = exports.fixCategoryGroupSort = exports.reorderCategoryGroup = exports.setCategoryActiveState = exports.deleteCategory = exports.updateCategory = exports.createCategory = exports.onProductDeletedUpdateCategoryCount = exports.onProductUpdatedUpdateCategoryCount = exports.onProductCreatedUpdateCategoryCount = exports.checkPhoneAuthEligibility = void 0;
const app_1 = require("firebase-admin/app");
const options_1 = require("firebase-functions/v2/options");
(0, app_1.initializeApp)();
(0, options_1.setGlobalOptions)({
    region: "asia-south1",
});
var check_phone_auth_eligibility_1 = require("./check-phone-auth-eligibility");
Object.defineProperty(exports, "checkPhoneAuthEligibility", { enumerable: true, get: function () { return check_phone_auth_eligibility_1.checkPhoneAuthEligibility; } });
var category_product_count_1 = require("./category-product-count");
Object.defineProperty(exports, "onProductCreatedUpdateCategoryCount", { enumerable: true, get: function () { return category_product_count_1.onProductCreatedUpdateCategoryCount; } });
Object.defineProperty(exports, "onProductUpdatedUpdateCategoryCount", { enumerable: true, get: function () { return category_product_count_1.onProductUpdatedUpdateCategoryCount; } });
Object.defineProperty(exports, "onProductDeletedUpdateCategoryCount", { enumerable: true, get: function () { return category_product_count_1.onProductDeletedUpdateCategoryCount; } });
var create_category_1 = require("./categories/create-category");
Object.defineProperty(exports, "createCategory", { enumerable: true, get: function () { return create_category_1.createCategory; } });
var update_category_1 = require("./categories/update-category");
Object.defineProperty(exports, "updateCategory", { enumerable: true, get: function () { return update_category_1.updateCategory; } });
var delete_category_1 = require("./categories/delete-category");
Object.defineProperty(exports, "deleteCategory", { enumerable: true, get: function () { return delete_category_1.deleteCategory; } });
var set_category_active_state_1 = require("./categories/set-category-active-state");
Object.defineProperty(exports, "setCategoryActiveState", { enumerable: true, get: function () { return set_category_active_state_1.setCategoryActiveState; } });
var reorder_categories_1 = require("./categories/reorder-categories");
Object.defineProperty(exports, "reorderCategoryGroup", { enumerable: true, get: function () { return reorder_categories_1.reorderCategoryGroup; } });
var fix_category_group_sort_1 = require("./categories/fix-category-group-sort");
Object.defineProperty(exports, "fixCategoryGroupSort", { enumerable: true, get: function () { return fix_category_group_sort_1.fixCategoryGroupSort; } });
var log_admin_action_1 = require("./admin/log-admin-action");
Object.defineProperty(exports, "logAdminAction", { enumerable: true, get: function () { return log_admin_action_1.logAdminAction; } });
