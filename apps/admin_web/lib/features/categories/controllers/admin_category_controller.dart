import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/admin/admin_activity_logger.dart';

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
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
  }) async {
    if (isSaving.value) return;

    isSaving.value = true;
    operationError.value = null;

    try {
      Map<String, dynamic>? beforeData;

      if (isEdit) {
        final existingDoc = await _repo.categoriesCollection.doc(category.id).get();
        beforeData = existingDoc.data();
      }

      if (isEdit) {
        await _repo.updateCategory(category);
      } else {
        await _repo.createCategory(category);
      }

      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: isEdit ? 'category.update' : 'category.create',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        beforeData: beforeData,
        afterData: category.toMap(),
        metadata: {
          'parentId': category.parentId ?? '',
          'sortOrder': category.sortOrder,
          'isFeatured': category.isFeatured,
          'showOnHome': category.showOnHome,
          'isActive': category.isActive,
          'productsCount': category.productsCount,
        },
        status: 'success',
      );
    } catch (e) {
      operationError.value = e.toString();

      await _safeLogFailure(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: isEdit ? 'category.update' : 'category.create',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        reason: e.toString(),
      );

      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory({
    required MBCategory category,
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
  }) async {
    if (isDeleting.value) return;

    isDeleting.value = true;
    operationError.value = null;

    try {
      final Map<String, dynamic> beforeData = category.toMap();

      await _repo.deleteCategory(category.id);

      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.delete',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        beforeData: beforeData,
        metadata: {
          'parentId': category.parentId ?? '',
          'sortOrder': category.sortOrder,
          'productsCount': category.productsCount,
        },
        status: 'success',
      );
    } catch (e) {
      operationError.value = e.toString();

      await _safeLogFailure(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.delete',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        reason: e.toString(),
      );

      rethrow;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleActive({
    required MBCategory category,
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
  }) async {
    operationError.value = null;

    final bool nextIsActive = !category.isActive;
    final Map<String, dynamic> beforeData = category.toMap();
    final Map<String, dynamic> afterData = {
      ...beforeData,
      'isActive': nextIsActive,
    };

    try {
      await _repo.setCategoryActiveState(
        categoryId: category.id,
        isActive: nextIsActive,
      );

      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.toggle_active',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        beforeData: beforeData,
        afterData: afterData,
        metadata: {
          'previousIsActive': category.isActive,
          'nextIsActive': nextIsActive,
        },
        status: 'success',
      );
    } catch (e) {
      operationError.value = e.toString();

      await _safeLogFailure(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.toggle_active',
        module: 'catalog',
        targetType: 'category',
        targetId: category.id,
        targetTitle:
        category.nameEn.trim().isEmpty ? 'Unnamed Category' : category.nameEn,
        reason: e.toString(),
      );

      rethrow;
    }
  }

  Future<void> reorderGroup({
    required String? parentId,
    required List<String> orderedCategoryIds,
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
  }) async {
    if (isReordering.value) return;

    isReordering.value = true;
    operationError.value = null;

    final String normalizedParentId = parentId?.trim() ?? '';
    final String groupTargetId =
    normalizedParentId.isEmpty ? 'root' : normalizedParentId;

    try {
      await _repo.reorderCategoryGroup(
        parentId: parentId,
        orderedCategoryIds: orderedCategoryIds,
      );

      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.reorder',
        module: 'catalog',
        targetType: 'category_group',
        targetId: groupTargetId,
        targetTitle:
        normalizedParentId.isEmpty ? 'Root Categories' : 'Child Categories',
        afterData: {
          'parentId': normalizedParentId,
          'orderedCategoryIds': orderedCategoryIds,
        },
        metadata: {
          'groupId': groupTargetId,
          'itemsCount': orderedCategoryIds.length,
        },
        status: 'success',
      );
    } catch (e) {
      operationError.value = e.toString();

      await _safeLogFailure(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: 'category.reorder',
        module: 'catalog',
        targetType: 'category_group',
        targetId: groupTargetId,
        targetTitle:
        normalizedParentId.isEmpty ? 'Root Categories' : 'Child Categories',
        reason: e.toString(),
      );

      rethrow;
    } finally {
      isReordering.value = false;
    }
  }

  Future<void> _safeLogFailure({
    required String actorUid,
    required String actorName,
    required String actorPhone,
    required String actorRole,
    required String action,
    required String module,
    required String targetType,
    required String targetId,
    required String targetTitle,
    required String reason,
  }) async {
    try {
      await AdminActivityLogger.log(
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        action: action,
        module: module,
        targetType: targetType,
        targetId: targetId,
        targetTitle: targetTitle,
        status: 'failed',
        reason: reason,
      );
    } catch (_) {
      // Never block the main flow because of logging failure.
    }
  }
}