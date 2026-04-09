import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2/options";

initializeApp();

setGlobalOptions({
  region: "asia-south1",
});

export { checkPhoneAuthEligibility } from "./auth/check-phone-auth-eligibility";

export {
  onProductCreatedUpdateCategoryCount,
  onProductUpdatedUpdateCategoryCount,
  onProductDeletedUpdateCategoryCount,
} from "./categories/category-product-count";

export { createCategory } from "./categories/create-category";
export { updateCategory } from "./categories/update-category";
export { deleteCategory } from "./categories/delete-category";
export { setCategoryActiveState } from "./categories/set-category-active-state";
export { reorderCategoryGroup } from "./categories/reorder-categories";
export { fixCategoryGroupSort } from "./categories/fix-category-group-sort";

export { createBrand } from "./brands/create-brand";
export { updateBrand } from "./brands/update-brand";
export { deleteBrand } from "./brands/delete-brand";
export { setBrandActiveState } from "./brands/set-brand-active-state";

export { logAdminAction } from "./admin/log-admin-action";
