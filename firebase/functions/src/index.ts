import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();

setGlobalOptions({
  region: "asia-south1",
});

export { checkPhoneAuthEligibility } from "./check-phone-auth-eligibility";
export {
  onProductCreatedUpdateCategoryCount,
  onProductUpdatedUpdateCategoryCount,
  onProductDeletedUpdateCategoryCount,
} from "./category-product-count";
export { reorderCategoryGroup } from "./categories/reorder-categories";
export { fixCategoryGroupSort } from "./categories/fix-category-group-sort";
export { logAdminAction } from "./admin/log-admin-action";