import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_banner_controller.dart';

class AdminBannerFormDialog extends StatefulWidget {
  const AdminBannerFormDialog({
    super.key,
    this.banner,
  });

  final MBBanner? banner;

  @override
  State<AdminBannerFormDialog> createState() => _AdminBannerFormDialogState();
}

class _AdminBannerFormDialogState extends State<AdminBannerFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AdminBannerController _controller;
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _subtitleEnController;
  late final TextEditingController _subtitleBnController;
  late final TextEditingController _buttonTextEnController;
  late final TextEditingController _buttonTextBnController;
  late final TextEditingController _targetIdController;
  late final TextEditingController _targetRouteController;
  late final TextEditingController _externalUrlController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _startAtController;
  late final TextEditingController _endAtController;

  late final String _generatedId;

  String _targetType = 'none';
  String _position = 'home_hero';
  bool _isActive = true;
  bool _showOnHome = true;

  bool _isSaving = false;
  String? _submitError;
  String? _sortErrorText;
  String? _dateErrorText;

  MBOriginalPickedImage? _wideOriginalImage;
  MBPreparedImageSet? _widePreparedImage;
  MBOriginalPickedImage? _mobileOriginalImage;
  MBPreparedImageSet? _mobilePreparedImage;

  late MBAdminImageResizePreset _widePreset;
  late MBAdminImageResizePreset _mobilePreset;

  bool get isEdit => widget.banner != null;

  String get _draftEntityId {
    final String existingId = widget.banner?.id.trim() ?? '';
    if (existingId.isNotEmpty) return existingId;
    return _generatedId;
  }

  bool get _hasExistingWideImage =>
      (widget.banner?.imageUrl.trim().isNotEmpty ?? false);
  bool get _hasExistingMobileImage =>
      (widget.banner?.mobileImageUrl.trim().isNotEmpty ?? false);

  bool get _hasAnyWideImage => _widePreparedImage != null || _hasExistingWideImage;
  bool get _hasAnyMobileImage =>
      _mobilePreparedImage != null || _hasExistingMobileImage;

  bool get _requiresTargetId =>
      _targetType == 'product' ||
          _targetType == 'category' ||
          _targetType == 'brand';

  bool get _requiresRoute => _targetType == 'route';
  bool get _requiresExternalUrl => _targetType == 'external';

  bool get _canSubmit {
    if (_isSaving) return false;
    if (!_hasAnyWideImage) return false;
    if (!_hasAnyMobileImage) return false;
    if ((_titleEnController.text.trim()).isEmpty) return false;
    if ((_sortErrorText ?? '').isNotEmpty) return false;
    if ((_dateErrorText ?? '').isNotEmpty) return false;
    if (_requiresTargetId && _targetIdController.text.trim().isEmpty) {
      return false;
    }
    if (_requiresRoute && _targetRouteController.text.trim().isEmpty) {
      return false;
    }
    if (_requiresExternalUrl && _externalUrlController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminBannerController>();
    _generatedId = FirebaseFirestore.instance.collection('banners').doc().id;
    _widePreset = MBAdminImageResizePresets.defaultBannerWide();
    _mobilePreset = MBAdminImageResizePresets.defaultBannerWide();

    final MBBanner? banner = widget.banner;

    _titleEnController = TextEditingController(text: banner?.titleEn ?? '');
    _titleBnController = TextEditingController(text: banner?.titleBn ?? '');
    _subtitleEnController = TextEditingController(text: banner?.subtitleEn ?? '');
    _subtitleBnController = TextEditingController(text: banner?.subtitleBn ?? '');
    _buttonTextEnController = TextEditingController(text: banner?.buttonTextEn ?? '');
    _buttonTextBnController = TextEditingController(text: banner?.buttonTextBn ?? '');
    _targetIdController = TextEditingController(text: banner?.targetId ?? '');
    _targetRouteController = TextEditingController(text: banner?.targetRoute ?? '');
    _externalUrlController = TextEditingController(text: banner?.externalUrl ?? '');
    _sortOrderController = TextEditingController(text: '${banner?.sortOrder ?? 0}');
    _startAtController = TextEditingController(
      text: banner?.startAt?.toIso8601String() ?? '',
    );
    _endAtController = TextEditingController(
      text: banner?.endAt?.toIso8601String() ?? '',
    );

    _targetType = banner?.targetType ?? 'none';
    _position = (banner?.position.trim().isNotEmpty ?? false)
        ? banner!.position.trim()
        : 'home_hero';
    _isActive = banner?.isActive ?? true;
    _showOnHome = banner?.showOnHome ?? true;

    _sortOrderController.addListener(_validateSort);
    _startAtController.addListener(_validateDates);
    _endAtController.addListener(_validateDates);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!isEdit) {
        try {
          final int sort = await _controller.suggestSortOrder();
          if (!mounted) return;
          _sortOrderController.text = '$sort';
        } catch (_) {}
      }
      _validateSort();
      _validateDates();
    });
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleBnController.dispose();
    _subtitleEnController.dispose();
    _subtitleBnController.dispose();
    _buttonTextEnController.dispose();
    _buttonTextBnController.dispose();
    _targetIdController.dispose();
    _targetRouteController.dispose();
    _externalUrlController.dispose();
    _sortOrderController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  void _validateSort() {
    final int? parsed = int.tryParse(_sortOrderController.text.trim());
    final String currentId = widget.banner?.id.trim() ?? '';

    String? error;
    if (parsed == null) {
      error = 'Enter a valid integer.';
    } else if (parsed < 0) {
      error = 'Sort order must be 0 or greater.';
    } else {
      final bool duplicate = _controller.banners.any((item) {
        if (currentId.isNotEmpty && item.id.trim() == currentId) return false;
        return item.sortOrder == parsed;
      });
      if (duplicate) {
        error = 'This sort order already exists.';
      }
    }

    if (mounted) {
      setState(() {
        _sortErrorText = error;
      });
    }
  }

  void _validateDates() {
    final DateTime? start = _nullableDate(_startAtController.text);
    final DateTime? end = _nullableDate(_endAtController.text);

    String? error;
    if (_startAtController.text.trim().isNotEmpty && start == null) {
      error = 'Start date is not valid ISO datetime.';
    } else if (_endAtController.text.trim().isNotEmpty && end == null) {
      error = 'End date is not valid ISO datetime.';
    } else if (start != null && end != null && end.isBefore(start)) {
      error = 'End date must be after start date.';
    }

    if (mounted) {
      setState(() {
        _dateErrorText = error;
      });
    }
  }

  String _cleanError(Object error) {
    final String raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return raw;
  }

  Future<void> _pickWideImage() async {
    try {
      final MBOriginalPickedImage? picked = await _controller.pickOriginalImage();
      if (!mounted || picked == null) return;
      setState(() {
        _wideOriginalImage = picked;
        _widePreparedImage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
      });
    }
  }

  Future<void> _resizeWideImage() async {
    if (_wideOriginalImage == null) return;
    try {
      final MBPreparedImageSet prepared = await _controller.resizeSelectedImage(
        original: _wideOriginalImage!,
        fullMaxWidth: _widePreset.fullMaxWidth,
        fullMaxHeight: _widePreset.fullMaxHeight,
        fullJpegQuality: _widePreset.fullJpegQuality,
        thumbSize: _widePreset.thumbSize,
        thumbJpegQuality: _widePreset.thumbJpegQuality,
        requestSquareCrop: _widePreset.requestSquareCrop,
      );
      if (!mounted) return;
      setState(() {
        _widePreparedImage = prepared;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
      });
    }
  }

  Future<void> _pickMobileImage() async {
    try {
      final MBOriginalPickedImage? picked = await _controller.pickOriginalImage();
      if (!mounted || picked == null) return;
      setState(() {
        _mobileOriginalImage = picked;
        _mobilePreparedImage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
      });
    }
  }

  Future<void> _resizeMobileImage() async {
    if (_mobileOriginalImage == null) return;
    try {
      final MBPreparedImageSet prepared = await _controller.resizeSelectedImage(
        original: _mobileOriginalImage!,
        fullMaxWidth: _mobilePreset.fullMaxWidth,
        fullMaxHeight: _mobilePreset.fullMaxHeight,
        fullJpegQuality: _mobilePreset.fullJpegQuality,
        thumbSize: _mobilePreset.thumbSize,
        thumbJpegQuality: _mobilePreset.thumbJpegQuality,
        requestSquareCrop: _mobilePreset.requestSquareCrop,
      );
      if (!mounted) return;
      setState(() {
        _mobilePreparedImage = prepared;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
      });
    }
  }

  Future<void> _closeDialogSuccessfully() async {
    if (!mounted) return;

    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop(true);
      return;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back(result: true);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitError = null;
      _isSaving = true;
    });

    try {
      String wideImageUrl = widget.banner?.imageUrl.trim() ?? '';
      String mobileImageUrl = widget.banner?.mobileImageUrl.trim() ?? '';

      if (_widePreparedImage != null) {
        final uploadedWide = await MBImagePipelineService.instance.uploadPreparedImageSet(
          prepared: _widePreparedImage!,
          storageFolder: 'banner_images',
          entityId: '${_draftEntityId}_wide',
          fileStem: 'banner_wide',
          customMetadata: const <String, String>{
            'entityType': 'banner',
            'slot': 'wide',
          },
        );
        wideImageUrl = uploadedWide.fullUrl;
      }

      if (_mobilePreparedImage != null) {
        final uploadedMobile = await MBImagePipelineService.instance.uploadPreparedImageSet(
          prepared: _mobilePreparedImage!,
          storageFolder: 'banner_images',
          entityId: '${_draftEntityId}_mobile',
          fileStem: 'banner_mobile',
          customMetadata: const <String, String>{
            'entityType': 'banner',
            'slot': 'mobile',
          },
        );
        mobileImageUrl = uploadedMobile.fullUrl;
      }

      if (wideImageUrl.trim().isEmpty) {
        throw Exception('Wide banner image is required.');
      }
      if (mobileImageUrl.trim().isEmpty) {
        throw Exception('Mobile banner image is required.');
      }

      final DateTime now = DateTime.now();
      final MBBanner banner = MBBanner(
        id: widget.banner?.id ?? _draftEntityId,
        titleEn: _titleEnController.text.trim(),
        titleBn: _titleBnController.text.trim(),
        subtitleEn: _subtitleEnController.text.trim(),
        subtitleBn: _subtitleBnController.text.trim(),
        buttonTextEn: _buttonTextEnController.text.trim(),
        buttonTextBn: _buttonTextBnController.text.trim(),
        imageUrl: wideImageUrl,
        mobileImageUrl: mobileImageUrl,
        targetType: _targetType,
        targetId: _requiresTargetId ? _emptyToNull(_targetIdController.text) : null,
        targetRoute: _requiresRoute ? _emptyToNull(_targetRouteController.text) : null,
        externalUrl: _requiresExternalUrl ? _emptyToNull(_externalUrlController.text) : null,
        isActive: _isActive,
        showOnHome: _showOnHome,
        position: _position,
        sortOrder: int.parse(_sortOrderController.text.trim()),
        startAt: _nullableDate(_startAtController.text),
        endAt: _nullableDate(_endAtController.text),
        createdAt: widget.banner?.createdAt ?? now,
        updatedAt: now,
      );

      if (isEdit) {
        await _controller.updateBanner(banner);
      } else {
        await _controller.createBanner(banner);
      }

      if (!mounted) return;
      await _closeDialogSuccessfully();
      return;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = _cleanError(error);
        _isSaving = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1220, maxHeight: 900),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MBSpacing.xl),
                child: Column(
                  children: [
                    if ((_submitError ?? '').isNotEmpty)
                      MBAdminFormErrorBanner(message: _submitError!),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 960) {
                          return Column(
                            children: [
                              _buildFormSection(),
                              MBSpacing.h(MBSpacing.lg),
                              _buildFlagsSection(),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildFormSection()),
                            MBSpacing.w(MBSpacing.lg),
                            Expanded(flex: 2, child: _buildFlagsSection()),
                          ],
                        );
                      },
                    ),
                    MBSpacing.h(MBSpacing.lg),
                    MBAdminDualImagePanels(
                      left: _buildWideImagePanel(),
                      right: _buildMobileImagePanel(),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            MBAdminFormActionFooter(
              primaryLabel: isEdit ? 'Update Banner' : 'Create Banner',
              isPrimaryEnabled: _canSubmit,
              onPrimaryTap: _submit,
              onCancelTap: _isSaving ? null : () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(MBSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Banner' : 'Create Banner',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  'Manage wide and mobile banner images, target behavior, scheduling, position, and display order.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSaving ? null : () => Get.back(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return MBAdminFormSectionCard(
      title: 'Banner details',
      subtitle: 'Text, target behavior, schedule, and ordering.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _titleEnController,
                    decoration: const InputDecoration(
                      labelText: 'Title (English)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'English title is required.'
                        : null,
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _titleBnController,
                    decoration: const InputDecoration(
                      labelText: 'Title (Bangla)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String>(
                    initialValue: _targetType,
                    decoration: const InputDecoration(
                      labelText: 'Target Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No action')),
                      DropdownMenuItem(value: 'product', child: Text('Product')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                      DropdownMenuItem(value: 'brand', child: Text('Brand')),
                      DropdownMenuItem(value: 'route', child: Text('Route')),
                      DropdownMenuItem(value: 'external', child: Text('Custom URL')),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) {
                      setState(() {
                        _targetType = value ?? 'none';
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String>(
                    initialValue: _position,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'home_hero', child: Text('Home Hero')),
                      DropdownMenuItem(value: 'home_secondary', child: Text('Home Secondary')),
                      DropdownMenuItem(value: 'home_strip', child: Text('Home Strip')),
                      DropdownMenuItem(value: 'category_top', child: Text('Category Top')),
                      DropdownMenuItem(value: 'brand_top', child: Text('Brand Top')),
                      DropdownMenuItem(value: 'generic', child: Text('Generic')),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) {
                      setState(() {
                        _position = value ?? 'home_hero';
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Sort Order',
                      border: const OutlineInputBorder(),
                      helperText: _sortErrorText ?? 'Unique display order for banners.',
                      helperStyle: TextStyle(
                        color: (_sortErrorText ?? '').isEmpty
                            ? MBColors.textSecondary
                            : MBColors.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _targetIdController,
                    decoration: const InputDecoration(
                      labelText: 'Target ID',
                      border: OutlineInputBorder(),
                      helperText: 'Used for product, category, or brand target.',
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _targetRouteController,
                    decoration: const InputDecoration(
                      labelText: 'Target Route',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _externalUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Custom URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _subtitleEnController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Subtitle (English)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _subtitleBnController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Subtitle (Bangla)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buttonTextEnController,
                    decoration: const InputDecoration(
                      labelText: 'Button Text (English)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _buttonTextBnController,
                    decoration: const InputDecoration(
                      labelText: 'Button Text (Bangla)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startAtController,
                    decoration: InputDecoration(
                      labelText: 'Start At (ISO datetime)',
                      border: const OutlineInputBorder(),
                      helperText: _dateErrorText ?? 'Example: 2026-04-10T00:00:00',
                      helperStyle: TextStyle(
                        color: (_dateErrorText ?? '').isEmpty
                            ? MBColors.textSecondary
                            : MBColors.error,
                      ),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _endAtController,
                    decoration: const InputDecoration(
                      labelText: 'End At (ISO datetime)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagsSection() {
    return MBAdminFormSectionCard(
      title: 'Display rules',
      subtitle: 'Visibility, home display, and schedule readiness.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChip(
                label: const Text('Active'),
                selected: _isActive,
                onSelected: _isSaving
                    ? null
                    : (value) => setState(() => _isActive = value),
              ),
              FilterChip(
                label: const Text('Show on home'),
                selected: _showOnHome,
                onSelected: _isSaving
                    ? null
                    : (value) => setState(() => _showOnHome = value),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MBSpacing.md),
            decoration: BoxDecoration(
              color: MBColors.background,
              borderRadius: BorderRadius.circular(MBRadius.lg),
              border: Border.all(
                color: MBColors.border.withValues(alpha: 0.90),
              ),
            ),
            child: Text(
              _canSubmit
                  ? 'Ready to submit.'
                  : 'Save stays locked until both wide and mobile images are available and all required target/date rules are valid.',
              style: MBTextStyles.caption.copyWith(
                color: _canSubmit ? MBColors.success : MBColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideImagePanel() {
    Widget preview;
    final List<Widget> infoRows = <Widget>[];
    final List<Widget> actions = <Widget>[];
    final List<Widget> bottom = <Widget>[];

    if (_widePreparedImage != null) {
      preview = MBAdminImagePreviewBox(
        aspectRatio: 16 / 9,
        child: Image.memory(_widePreparedImage!.previewBytes, fit: BoxFit.cover),
      );
      infoRows.addAll([
        MBAdminInfoRow(
          label: 'Prepared',
          value: '${_widePreparedImage!.fullWidth} × ${_widePreparedImage!.fullHeight}',
        ),
        MBAdminInfoRow(
          label: 'Thumb',
          value: '${_widePreparedImage!.thumbWidth} × ${_widePreparedImage!.thumbHeight}',
        ),
      ]);
    } else if (_hasExistingWideImage) {
      preview = MBAdminImagePreviewBox(
        aspectRatio: 16 / 9,
        child: Image.network(
          widget.banner!.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const MBAdminEmptyImageBox(
            icon: Icons.broken_image_outlined,
            text: 'Existing wide image could not be loaded.',
            aspectRatio: 16 / 9,
          ),
        ),
      );
      infoRows.add(MBAdminInfoRow(label: 'Current', value: widget.banner!.imageUrl));
    } else {
      preview = const MBAdminEmptyImageBox(
        icon: Icons.photo_size_select_large_outlined,
        text: 'Select a wide banner image.',
        aspectRatio: 16 / 9,
      );
    }

    actions.add(
      FilledButton.icon(
        onPressed: _isSaving ? null : _pickWideImage,
        icon: const Icon(Icons.image_search_rounded),
        label: Text(_widePreparedImage != null || _hasExistingWideImage
            ? 'Replace Wide Image'
            : 'Select Wide Image'),
      ),
    );

    if (_wideOriginalImage != null) {
      actions.add(
        MBAdminImagePresetSelector(
          presets: MBAdminImageResizePresets.bannerWide,
          selectedPreset: _widePreset,
          onSelected: (preset) {
            setState(() {
              _widePreset = preset;
            });
          },
        ),
      );
      bottom.add(
        FilledButton.tonalIcon(
          onPressed: _isSaving ? null : _resizeWideImage,
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: Text(_widePreparedImage == null ? 'Resize Wide Image' : 'Resize Wide Again'),
        ),
      );
    }

    return MBAdminImagePanel(
      title: 'Wide banner image',
      subtitle: 'Primary banner image for desktop or wide layout usage.',
      preview: preview,
      infoRows: infoRows,
      actions: actions,
      bottom: bottom,
    );
  }

  Widget _buildMobileImagePanel() {
    Widget preview;
    final List<Widget> infoRows = <Widget>[];
    final List<Widget> actions = <Widget>[];
    final List<Widget> bottom = <Widget>[];

    if (_mobilePreparedImage != null) {
      preview = MBAdminImagePreviewBox(
        aspectRatio: 4 / 5,
        child: Image.memory(_mobilePreparedImage!.previewBytes, fit: BoxFit.cover),
      );
      infoRows.addAll([
        MBAdminInfoRow(
          label: 'Prepared',
          value: '${_mobilePreparedImage!.fullWidth} × ${_mobilePreparedImage!.fullHeight}',
        ),
        MBAdminInfoRow(
          label: 'Thumb',
          value: '${_mobilePreparedImage!.thumbWidth} × ${_mobilePreparedImage!.thumbHeight}',
        ),
      ]);
    } else if (_hasExistingMobileImage) {
      preview = MBAdminImagePreviewBox(
        aspectRatio: 4 / 5,
        child: Image.network(
          widget.banner!.mobileImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const MBAdminEmptyImageBox(
            icon: Icons.broken_image_outlined,
            text: 'Existing mobile image could not be loaded.',
            aspectRatio: 4 / 5,
          ),
        ),
      );
      infoRows.add(MBAdminInfoRow(label: 'Current', value: widget.banner!.mobileImageUrl));
    } else {
      preview = const MBAdminEmptyImageBox(
        icon: Icons.stay_current_portrait_rounded,
        text: 'Select a mobile banner image.',
        aspectRatio: 4 / 5,
      );
    }

    actions.add(
      FilledButton.icon(
        onPressed: _isSaving ? null : _pickMobileImage,
        icon: const Icon(Icons.image_search_rounded),
        label: Text(_mobilePreparedImage != null || _hasExistingMobileImage
            ? 'Replace Mobile Image'
            : 'Select Mobile Image'),
      ),
    );

    if (_mobileOriginalImage != null) {
      actions.add(
        MBAdminImagePresetSelector(
          presets: MBAdminImageResizePresets.bannerWide,
          selectedPreset: _mobilePreset,
          onSelected: (preset) {
            setState(() {
              _mobilePreset = preset;
            });
          },
        ),
      );
      bottom.add(
        FilledButton.tonalIcon(
          onPressed: _isSaving ? null : _resizeMobileImage,
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: Text(_mobilePreparedImage == null ? 'Resize Mobile Image' : 'Resize Mobile Again'),
        ),
      );
    }

    return MBAdminImagePanel(
      title: 'Mobile banner image',
      subtitle: 'Separate image for mobile layout presentation.',
      preview: preview,
      infoRows: infoRows,
      actions: actions,
      bottom: bottom,
    );
  }

  String? _emptyToNull(String raw) {
    final String value = raw.trim();
    return value.isEmpty ? null : value;
  }

  DateTime? _nullableDate(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
