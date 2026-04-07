import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminCategoryController extends GetxController {
  final AdminCategoryRepository _repo = AdminCategoryRepository.instance;

  final RxBool isDeleting = false.obs;
  final RxBool isReordering = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isResizingImage = false.obs;
  final RxnString operationError = RxnString();

  bool get isAnyBusy =>
      isDeleting.value ||
          isReordering.value ||
          isSaving.value ||
          isPickingImage.value ||
          isResizingImage.value;

  void clearOperationError() {
    operationError.value = null;
  }

  Future<MBOriginalPickedImage?> pickOriginalImage() async {
    if (isPickingImage.value || isSaving.value || isResizingImage.value) {
      return null;
    }

    isPickingImage.value = true;
    operationError.value = null;

    try {
      return await MBImagePipelineService.instance.pickOriginalImage();
    } catch (e) {
      operationError.value = 'Image selection failed: $e';
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
    if (isResizingImage.value || isSaving.value) {
      throw Exception('Another operation is already running.');
    }

    isResizingImage.value = true;
    operationError.value = null;

    try {
      return await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: fullMaxWidth,
        fullMaxHeight: fullMaxHeight,
        fullJpegQuality: fullJpegQuality,
        thumbSize: thumbSize,
        thumbJpegQuality: thumbJpegQuality,
        requestSquareCrop: requestSquareCrop,
      );
    } catch (e) {
      operationError.value = 'Image resize failed: $e';
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
    operationError.value = null;

    try {
      if (isEdit) {
        await _repo.updateCategory(category);
      } else {
        await _repo.createCategory(category);
      }
    } catch (e) {
      operationError.value = e.toString();
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
    operationError.value = null;

    try {
      await _repo.deleteCategory(
        category.id,
        reason: reason,
      );
    } catch (e) {
      operationError.value = e.toString();
      rethrow;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleActive({
    required MBCategory category,
    String? reason,
  }) async {
    operationError.value = null;

    final bool nextIsActive = !category.isActive;

    try {
      await _repo.setCategoryActiveState(
        categoryId: category.id,
        isActive: nextIsActive,
        reason: reason,
      );
    } catch (e) {
      operationError.value = e.toString();
      rethrow;
    }
  }

  Future<void> reorderGroup({
    required String? parentId,
    required List<String> orderedCategoryIds,
  }) async {
    if (isReordering.value) return;

    isReordering.value = true;
    operationError.value = null;

    try {
      await _repo.reorderCategoryGroup(
        parentId: parentId,
        orderedCategoryIds: orderedCategoryIds,
      );
    } catch (e) {
      operationError.value = e.toString();
      rethrow;
    } finally {
      isReordering.value = false;
    }
  }
}
