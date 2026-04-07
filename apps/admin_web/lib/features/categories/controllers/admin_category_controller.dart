import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminCategoryController extends GetxController {
  final AdminCategoryRepository _repo = AdminCategoryRepository.instance;

  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isReordering = false.obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isResizingImage = false.obs;
  final RxnString operationError = RxnString();

  bool get isAnyBusy =>
      isSaving.value ||
          isDeleting.value ||
          isReordering.value ||
          isPickingImage.value ||
          isResizingImage.value;

  void clearOperationError() {
    operationError.value = null;
  }

  void _setOperationError(Object error) {
    operationError.value = error.toString();
  }

  Future<MBOriginalPickedImage?> pickOriginalImage() async {
    if (isSaving.value || isDeleting.value || isPickingImage.value) {
      return null;
    }

    isPickingImage.value = true;
    clearOperationError();

    try {
      final result = await MBImagePipelineService.instance.pickOriginalImage();
      return result;
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isPickingImage.value = false;
    }
  }

  Future<MBPreparedImageSet> resizeSelectedImage({
    required MBOriginalPickedImage original,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    bool requestSquareCrop = true,
  }) async {
    if (isSaving.value || isDeleting.value || isResizingImage.value) {
      throw Exception('Another category operation is already running.');
    }

    isResizingImage.value = true;
    clearOperationError();

    try {
      final result = await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: fullMaxWidth,
        fullMaxHeight: fullMaxHeight,
        fullJpegQuality: fullJpegQuality,
        thumbSize: thumbSize,
        thumbJpegQuality: thumbJpegQuality,
        requestSquareCrop: requestSquareCrop,
      );
      return result;
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isResizingImage.value = false;
    }
  }

  Future<void> saveCategory({
    required MBCategory category,
    required bool isEdit,
  }) async {
    if (isSaving.value) return;

    isSaving.value = true;
    clearOperationError();

    try {
      if (isEdit) {
        await _repo.updateCategory(category);
      } else {
        await _repo.createCategory(category);
      }
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory({
    required MBCategory category,
    String? reason,
  }) async {
    if (isDeleting.value) return;

    isDeleting.value = true;
    clearOperationError();

    try {
      await _repo.deleteCategory(
        category.id,
        reason: reason,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleActive({
    required MBCategory category,
    String? reason,
  }) async {
    clearOperationError();

    try {
      await _repo.setCategoryActiveState(
        categoryId: category.id,
        isActive: !category.isActive,
        reason: reason,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    }
  }

  Future<void> reorderGroup({
    required String? parentId,
    required List<String> orderedCategoryIds,
  }) async {
    if (isReordering.value) return;

    isReordering.value = true;
    clearOperationError();

    try {
      await _repo.reorderCategoryGroup(
        parentId: parentId,
        orderedCategoryIds: orderedCategoryIds,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isReordering.value = false;
    }
  }

  Future<void> fixGroupSort({
    required String? parentId,
  }) async {
    if (isReordering.value) return;

    isReordering.value = true;
    clearOperationError();

    try {
      await _repo.fixCategoryGroupSort(
        parentId: parentId,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isReordering.value = false;
    }
  }
}
